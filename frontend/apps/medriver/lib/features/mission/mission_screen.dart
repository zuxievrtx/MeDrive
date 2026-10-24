import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../router.dart';
import '../../services/location_ping.dart';
import '../../state/chat_state.dart';
import '../../state/driver_state.dart';
import '../../state/session.dart';
import '../../widgets/feedback.dart';
import 'mission_state.dart';

/// Misi aktif (konsep Figma "Info Spot"): peta + rute jalan, kartu ETA & jarak, data laporan dan
/// pelapor, serta satu tombol aksi bertahap sebagai fokus layar. Layar dijaga tetap menyala.
///
/// Kanal `report.{id}` hanya diotorisasi untuk pelapor (routes/channels.php), jadi status dan
/// data laporan di-poll ringan tiap 15 detik; rute diambil ulang tiap 30 detik (cache OSRM server).
class MissionScreen extends ConsumerStatefulWidget {
  const MissionScreen({super.key, required this.reportId});

  final int reportId;

  @override
  ConsumerState<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends ConsumerState<MissionScreen> {
  static const _reportEvery = Duration(seconds: 15);
  static const _routeEvery = Duration(seconds: 30);

  final _map = MapController();
  bool _mapReady = false;
  bool _follow = true;
  RouteResult? _route;
  ApiError? _routeError;
  bool _advancing = false;
  Timer? _reportTimer;
  Timer? _routeTimer;
  RealtimeSubscription? _chatChannel;
  late final AppLifecycleListener _lifecycle;

  MissionController get _mission => ref.read(missionProvider(widget.reportId).notifier);

  @override
  void initState() {
    super.initState();
    unawaited(_keepScreenOn(true));
    _lifecycle = AppLifecycleListener(onResume: () {
      unawaited(_mission.reload());
      unawaited(_loadRoute());
      ref.invalidate(unreadProvider);
    });
    _reportTimer = Timer.periodic(_reportEvery, (_) => unawaited(_mission.reload().catchError((Object _) {})));
    _routeTimer = Timer.periodic(_routeEvery, (_) => unawaited(_loadRoute()));
    unawaited(_loadRoute());
    unawaited(_subscribeChat());
  }

  @override
  void dispose() {
    _reportTimer?.cancel();
    _routeTimer?.cancel();
    _chatChannel?.cancel();
    _lifecycle.dispose();
    _map.dispose();
    unawaited(_keepScreenOn(false));
    super.dispose();
  }

  Future<void> _keepScreenOn(bool on) async {
    try {
      await WakelockPlus.toggle(enable: on);
    } on Object {
      // Plugin tidak tersedia (mis. test); layar mengikuti pengaturan perangkat.
    }
  }

  Future<void> _subscribeChat() async {
    try {
      final channel = await ref.read(realtimeServiceProvider).subscribe('chat.${widget.reportId}', {
        'ChatMessageSent': (data) {
          final sender = (data['sender_id'] as num?)?.toInt();
          if (sender != null && sender != ref.read(sessionProvider).user?.id && mounted) {
            ref.invalidate(unreadProvider);
          }
        },
      });
      if (!mounted) {
        channel.cancel();
        return;
      }
      _chatChannel = channel;
    } on Object {
      // Badge chat tetap diperbarui saat layar dibuka ulang / polling unread.
    }
  }

  Future<void> _loadRoute() async {
    final report = ref.read(missionProvider(widget.reportId)).value;
    if (report != null && !report.isActive) {
      return;
    }
    try {
      final route = await ref.read(driverRepositoryProvider).route();
      if (!mounted) {
        return;
      }
      setState(() {
        _route = route.reportId == null || route.reportId == widget.reportId ? route : null;
        _routeError = null;
      });
      if (_follow) {
        _fitCamera();
      }
    } on ApiError catch (error) {
      if (mounted) {
        setState(() => _routeError = error);
      }
    }
  }

  LatLng? _me() {
    final fix = ref.read(locationPingProvider).status.value.lastFix;
    return fix == null ? null : LatLng(fix.latitude, fix.longitude);
  }

  void _fitCamera() {
    final report = ref.read(missionProvider(widget.reportId)).value;
    if (!_mapReady || report == null) {
      return;
    }
    final target = _target(report, _route);
    final geometry = _route?.geometry ?? const [];
    final points = [
      ?_me(),
      if (geometry.isNotEmpty) LatLng(geometry.first[0], geometry.first[1]),
      target,
    ];
    if (points.length == 1) {
      _map.move(points.single, 16);
      return;
    }
    _map.fitCamera(CameraFit.coordinates(coordinates: points, padding: const EdgeInsets.fromLTRB(48, 48, 64, 40), maxZoom: 17));
  }

  static LatLng _pickup(Report report) => LatLng(report.latitude, report.longitude);

  static LatLng? _destination(Report report) {
    final destination = report.destination;
    return destination?.latitude == null || destination?.longitude == null
        ? null
        : LatLng(destination!.latitude!, destination.longitude!);
  }

  static LatLng _target(Report report, RouteResult? route) {
    final toDestination = route?.toDestination ?? report.statusValue == ReportStatus.mengantarPasien;
    return toDestination ? (_destination(report) ?? _pickup(report)) : _pickup(report);
  }

  Future<void> _runStep(Report report, MissionStep step) async {
    if (_advancing) {
      return;
    }
    if (step.completes) {
      if (!report.allPatientsHandedOver) {
        await _askForHandover(report);
        return;
      }
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'Selesaikan laporan?',
        message: 'Pastikan semua pasien sudah diserahterimakan. Chat dengan pelapor akan ditutup.',
        confirmLabel: 'Selesai',
        icon: Icons.check_circle_outline_rounded,
      );
      if (!confirmed) {
        return;
      }
    }

    setState(() => _advancing = true);
    try {
      final updated = await _mission.advance(step.status);
      if (updated.isActive) {
        unawaited(_loadRoute());
      } else {
        unawaited(ref.read(driverProvider.notifier).refresh());
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      final apiError = asApiError(error);
      if (apiError.code == 'patient_handover_required') {
        await _askForHandover(report, serverMessage: apiError.message);
      } else {
        showError(context, apiError);
        if (apiError.code == 'invalid_transition' || apiError.code == 'status_changed') {
          unawaited(_mission.reload());
        }
      }
    } finally {
      if (mounted) {
        setState(() => _advancing = false);
      }
    }
  }

  /// Gate serah terima: setiap pasien wajib punya "diserahkan kepada" sebelum laporan selesai.
  Future<void> _askForHandover(Report report, {String? serverMessage}) async {
    final missing = report.patients.where((patient) => (patient.handedOverTo ?? '').trim().isEmpty).length;
    final message = serverMessage ??
        (report.patients.isEmpty
            ? 'Belum ada data pasien. Isi minimal satu pasien beserta nama penerima serah terimanya.'
            : '$missing pasien belum diisi "Diserahkan kepada". Lengkapi serah terima sebelum menyelesaikan laporan.');
    final open = await ConfirmDialog.show(
      context,
      title: 'Serah terima belum lengkap',
      message: message,
      confirmLabel: 'Isi Form Pasien',
      icon: Icons.assignment_ind_outlined,
    );
    if (open && mounted) {
      unawaited(context.push(Routes.patients(widget.reportId)));
    }
  }

  Future<void> _call(String phone) async {
    final launched = await launchUrl(Uri(scheme: 'tel', path: phone));
    if (!launched && mounted) {
      showMessage(context, 'Tidak bisa membuka aplikasi telepon. Nomor pelapor: $phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mission = ref.watch(missionProvider(widget.reportId));

    return mission.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => Scaffold(appBar: AppBar(title: const Text('Info Spot')), body: const _MissionSkeleton()),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Info Spot')),
        body: AsyncErrorView(error: error, onRetry: () => ref.invalidate(missionProvider(widget.reportId))),
      ),
      data: (report) => report.isActive ? _buildActive(report) : _Finished(report: report),
    );
  }

  Widget _buildActive(Report report) {
    final step = nextMissionStep(report);
    final unread = ref.watch(unreadProvider).value?.forReport(report.id) ?? 0;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoSpotHeader(report: report),
          // Kartu ETA di atas peta (bukan menumpuk) agar kontrol zoom peta tidak tertutup.
          ColoredBox(
            color: MedColors.canvas,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(MedSpace.md, MedSpace.md, MedSpace.md, MedSpace.sm),
              child: _EtaCard(report: report, route: _route, error: _routeError),
            ),
          ),
          Expanded(flex: 6, child: _buildMap(report)),
          Expanded(
            flex: 5,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: MedColors.surface,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2))],
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.lg, MedSpace.gutter, MedSpace.lg),
                children: [
                  StatusStepper(
                    steps: [for (final status in missionStatuses(report)) StatusStep(status, ReportStatus.label(status))],
                    current: report.statusValue,
                  ),
                  const SizedBox(height: MedSpace.lg),
                  _ReportCard(report: report),
                  const SizedBox(height: MedSpace.md),
                  _ReporterRow(report: report, onCall: _call),
                  const SizedBox(height: MedSpace.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _ToolButton(
                          key: const Key('mission-chat'),
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Chat',
                          badge: unread,
                          onTap: () async {
                            await context.push(Routes.chat(report.id));
                            ref.invalidate(unreadProvider);
                          },
                        ),
                      ),
                      const SizedBox(width: MedSpace.sm),
                      Expanded(
                        child: _ToolButton(
                          key: const Key('mission-patients'),
                          icon: Icons.assignment_ind_outlined,
                          label: 'Pasien',
                          caption: report.patients.isEmpty
                              ? 'Belum ada'
                              : report.allPatientsHandedOver
                                  ? 'Lengkap'
                                  : '${report.patients.length} pasien',
                          warn: report.patients.isNotEmpty && !report.allPatientsHandedOver,
                          onTap: () => context.push(Routes.patients(report.id)),
                        ),
                      ),
                      const SizedBox(width: MedSpace.sm),
                      Expanded(
                        child: _ToolButton(
                          key: const Key('mission-photos'),
                          icon: Icons.photo_camera_outlined,
                          label: 'Foto',
                          caption: '${report.attachments.where((item) => item.type.value == 'foto_penanganan').length} foto',
                          onTap: () => context.push(Routes.photos(report.id)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (step != null)
            Material(
              color: MedColors.surface,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.sm, MedSpace.gutter, MedSpace.md),
                  child: SizedBox(
                    height: 62,
                    child: PrimaryButton(
                      key: const Key('mission-next'),
                      label: step.label,
                      icon: step.icon,
                      loading: _advancing,
                      onPressed: () => _runStep(report, step),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap(Report report) {
    final route = _route;
    final destination = _destination(report);

    return ValueListenableBuilder<PingStatus>(
      valueListenable: ref.watch(locationPingProvider).status,
      builder: (context, status, _) {
        final fix = status.lastFix;
        final me = fix == null ? null : LatLng(fix.latitude, fix.longitude);
        return MedMapView(
          controller: _map,
          initialCenter: me ?? _pickup(report),
          initialZoom: 15,
          userAgentPackageName: 'com.medrive.driver',
          controlsBottomPadding: 12,
          onMapReady: () {
            _mapReady = true;
            _fitCamera();
          },
          onPositionChanged: (_, hasGesture) {
            if (hasGesture) {
              _follow = false;
            }
          },
          onRecenter: () {
            _follow = true;
            _fitCamera();
          },
          polylines: [
            if (route != null && route.geometry.length > 1)
              Polyline(
                points: [for (final point in route.geometry) LatLng(point[0], point[1])],
                color: MedColors.brand,
                strokeWidth: 6,
                borderColor: Colors.white,
                borderStrokeWidth: 2,
              ),
          ],
          markers: [
            Marker(point: _pickup(report), width: 46, height: 46, alignment: Alignment.topCenter, child: const PickupPin(size: 46)),
            if (destination != null)
              Marker(point: destination, width: 40, height: 40, child: const _DestinationMarker()),
            if (me != null)
              Marker(
                point: me,
                width: 54,
                height: 54,
                child: AmbulanceMarker(heading: fix!.heading != null && fix.heading! >= 0 ? fix.heading : null, size: 54),
              ),
          ],
        );
      },
    );
  }
}

/// Pita merah "Info Spot" (Figma) dengan tombol kembali dan status laporan.
class _InfoSpotHeader extends StatelessWidget {
  const _InfoSpotHeader({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) => Container(
        color: MedColors.brand,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(MedSpace.xs, MedSpace.xs, MedSpace.lg, MedSpace.md),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Kembali ke beranda',
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home),
                ),
                const Expanded(
                  child: Text('Info Spot', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                ),
                StatusBadge(status: report.statusValue, label: report.status.label),
              ],
            ),
          ),
        ),
      );
}

class _EtaCard extends StatelessWidget {
  const _EtaCard({required this.report, required this.route, required this.error});

  final Report report;
  final RouteResult? route;
  final ApiError? error;

  @override
  Widget build(BuildContext context) {
    final route = this.route;
    final arrived = report.statusValue == ReportStatus.tibaDiLokasi;
    final String targetLabel = (route?.toDestination ?? false) || report.statusValue == ReportStatus.mengantarPasien
        ? 'Menuju tujuan antar'
        : 'Menuju titik jemput';

    Widget content;
    if (arrived) {
      content = const _EtaMessage(
        title: 'Anda di lokasi kejadian',
        message: 'Tangani pasien, isi form pasien, lalu lanjutkan langkah berikutnya.',
      );
    } else if (route == null && error != null) {
      content = _EtaMessage(
        title: 'Rute belum tersedia',
        message: error!.code == 'driver_location_unavailable'
            ? 'Menunggu posisi GPS ambulans terkirim ke server.'
            : '${error!.message} Dicoba lagi otomatis.',
      );
    } else if (route == null) {
      content = const Row(
        children: [
          Expanded(child: Skeleton(height: 44)),
          SizedBox(width: MedSpace.md),
          Expanded(child: Skeleton(height: 44)),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            route.stale ? '$targetLabel · perkiraan terakhir' : targetLabel,
            style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(height: MedSpace.xs),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _EtaValue(label: 'Perkiraan tiba', value: formatDuration(route.durationMin), valueKey: const Key('mission-eta'))),
                const VerticalDivider(width: MedSpace.xl),
                Expanded(child: _EtaValue(label: 'Sisa jarak', value: formatDistance(route.distanceKm))),
              ],
            ),
          ),
        ],
      );
    }

    return Semantics(
      liveRegion: true,
      child: Material(
        color: MedColors.surface,
        elevation: 2,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(MedRadius.lg),
        child: Padding(padding: const EdgeInsets.all(MedSpace.lg), child: content),
      ),
    );
  }
}

class _EtaValue extends StatelessWidget {
  const _EtaValue({required this.label, required this.value, this.valueKey});

  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: MedColors.inkMuted, fontSize: 12.5, fontWeight: FontWeight.w700)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, key: valueKey, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: MedColors.ink)),
          ),
        ],
      );
}

class _EtaMessage extends StatelessWidget {
  const _EtaMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(message, style: const TextStyle(color: MedColors.inkMuted)),
        ],
      );
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final type = report.reportType;
    final destination = report.destination;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ReportTypeTile(icon: reportTypeIcon(type?.icon, code: type?.code), color: colorFromHex(type?.color), size: 48),
            const SizedBox(width: MedSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.typeName, style: Theme.of(context).textTheme.titleMedium),
                  SelectableText(report.code, style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: MedSpace.sm),
        if ((report.description ?? '').isNotEmpty) InfoRow(icon: Icons.notes_rounded, label: 'Deskripsi', value: report.description!),
        InfoRow(icon: Icons.location_on_outlined, label: 'Alamat kejadian', value: report.address ?? report.shortAddress ?? '-'),
        if (destination?.name != null || destination?.address != null)
          InfoRow(
            icon: Icons.flag_outlined,
            label: 'Tujuan antar',
            value: [destination?.name, destination?.address].whereType<String>().join(', '),
          ),
      ],
    );
  }
}

class _ReporterRow extends StatelessWidget {
  const _ReporterRow({required this.report, required this.onCall});

  final Report report;
  final ValueChanged<String> onCall;

  @override
  Widget build(BuildContext context) {
    final reporter = report.reporter;
    final phone = reporter?.phone;

    return Container(
      padding: const EdgeInsets.all(MedSpace.md),
      decoration: BoxDecoration(color: MedColors.field, borderRadius: BorderRadius.circular(MedRadius.md)),
      child: Row(
        children: [
          const Icon(Icons.person_outline_rounded, color: MedColors.inkMuted),
          const SizedBox(width: MedSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pelapor', style: TextStyle(color: MedColors.inkMuted, fontSize: 12.5, fontWeight: FontWeight.w700)),
                Text(reporter?.name ?? '-', style: Theme.of(context).textTheme.titleSmall),
                if (phone != null) Text(phone, style: const TextStyle(color: MedColors.ink)),
              ],
            ),
          ),
          if (phone != null)
            FilledButton.icon(
              key: const Key('mission-call'),
              onPressed: () => onCall(phone),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48), padding: const EdgeInsets.symmetric(horizontal: MedSpace.lg)),
              icon: const Icon(Icons.call_rounded),
              label: const Text('PANGGIL'),
            ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.caption,
    this.badge = 0,
    this.warn = false,
  });

  final IconData icon;
  final String label;
  final String? caption;
  final int badge;
  final bool warn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: [label, ?caption, if (badge > 0) '$badge pesan baru'].join(', '),
        excludeSemantics: true,
        child: Material(
          color: MedColors.surface,
          borderRadius: BorderRadius.circular(MedRadius.md),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(MedRadius.md),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: MedSpace.md, horizontal: MedSpace.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MedRadius.md),
                border: Border.all(color: warn ? MedColors.warning : MedColors.line, width: warn ? 2 : 1),
              ),
              child: Column(
                children: [
                  CountBadge(count: badge, child: Icon(icon, color: MedColors.brand, size: 26)),
                  const SizedBox(height: 4),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
                  if (caption != null)
                    Text(
                      caption!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: warn ? MedColors.warning : MedColors.inkMuted, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker();

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Tujuan antar',
        child: Container(
          decoration: BoxDecoration(
            color: MedColors.ink,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: const Icon(Icons.flag_rounded, color: Colors.white, size: 20),
        ),
      );
}

/// Laporan sudah selesai (atau dibatalkan): ringkasan dan kembali ke standby.
class _Finished extends ConsumerWidget {
  const _Finished({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = report.statusValue == ReportStatus.selesai;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MedSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: done ? const Color(0xFFDCFCE7) : MedColors.field, shape: BoxShape.circle),
                child: Icon(done ? Icons.check_rounded : Icons.block_rounded, size: 52, color: done ? MedColors.success : MedColors.inkMuted),
              ),
              const SizedBox(height: MedSpace.lg),
              Text(
                done ? 'Misi selesai' : 'Laporan ditutup',
                key: const Key('mission-finished'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: MedSpace.sm),
              Text(
                '${report.typeName} · ${report.code}\n${formatDateTime(report.completedAt)}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: MedSpace.md),
              Text(
                done
                    ? 'Shift Anda masih aktif. Anda kembali standby dan bisa menerima tawaran berikutnya.'
                    : 'Laporan ini tidak lagi aktif.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Kembali ke Standby',
                icon: Icons.home_rounded,
                onPressed: () {
                  unawaited(ref.read(driverProvider.notifier).refresh());
                  context.go(Routes.home);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionSkeleton extends StatelessWidget {
  const _MissionSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(MedSpace.gutter),
        children: const [
          Skeleton(height: 260, radius: MedRadius.lg),
          SizedBox(height: MedSpace.lg),
          Skeleton(height: 40),
          SizedBox(height: MedSpace.md),
          Skeleton(height: 140, radius: MedRadius.lg),
        ],
      );
}

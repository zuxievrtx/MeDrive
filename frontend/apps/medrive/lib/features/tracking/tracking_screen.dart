import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../router.dart';
import '../../state/session.dart';
import '../../widgets/feedback.dart';
import '../../widgets/media.dart';

/// Pelacakan ambulans.
///
/// - `menunggu`: kanal `report.{id}` belum boleh di-subscribe (backend hanya mengizinkan status
///   aktif), jadi detail laporan di-poll tiap 10 detik sampai ada driver yang mengambil.
/// - Aktif: posisi lewat event `DriverLocationUpdated`, status lewat `ReportStatusChanged`.
///   Bila WebSocket putus atau kanal ditolak, posisi dan status di-poll tiap 10 detik.
/// - Rute dan ETA diambil ulang tiap 30 detik (backend menyimpan cache OSRM).
class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key, required this.reportId});

  final int reportId;

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> with SingleTickerProviderStateMixin {
  static const _pollEvery = Duration(seconds: 10);
  static const _routeEvery = Duration(seconds: 30);

  final _map = MapController();
  late final AnimationController _motion = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  late final AppLifecycleListener _lifecycle;

  Report? _report;
  Object? _error;
  RouteResult? _route;
  int _unread = 0;

  LatLng? _from;
  LatLng? _to;
  double _headingFrom = 0;
  double _headingTo = 0;
  bool _hasHeading = false;

  bool _mapReady = false;
  bool _followCamera = true;

  RealtimeSubscription? _reportChannel;
  RealtimeSubscription? _chatChannel;
  bool _subscribing = false;
  bool _channelRejected = false;
  Timer? _poll;
  Timer? _routeTimer;

  ReportRepository get _reports => ref.read(reportRepositoryProvider);
  RealtimeService get _realtime => ref.read(realtimeServiceProvider);

  bool get _realtimeLive => _reportChannel != null && !_channelRejected && _realtime.isConnected;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(_loadReport()));
    _poll = Timer.periodic(_pollEvery, (_) => unawaited(_tick()));
    unawaited(_loadReport());
  }

  @override
  void dispose() {
    _poll?.cancel();
    _stopLive();
    _lifecycle.dispose();
    _motion.dispose();
    _map.dispose();
    super.dispose();
  }

  Future<void> _tick() async {
    final report = _report;
    if (report == null || report.isClosed) {
      return;
    }
    if (report.isWaiting || !_realtimeLive) {
      await _loadReport();
    }
    if ((_report?.isActive ?? false) && !_realtimeLive) {
      await _loadLocation();
    }
  }

  Future<void> _loadReport() async {
    try {
      final report = await _reports.detail(widget.reportId);
      if (mounted) {
        _applyReport(report);
      }
    } on ApiError catch (error) {
      if (mounted && _report == null) {
        setState(() => _error = error);
      }
    }
  }

  void _applyReport(Report report) {
    final statusChanged = _report?.statusValue != report.statusValue;
    setState(() {
      _report = report;
      _error = null;
    });

    if (report.isActive) {
      unawaited(_subscribe());
      _routeTimer ??= Timer.periodic(_routeEvery, (_) => unawaited(_loadRoute()));
      if (statusChanged) {
        unawaited(_loadRoute());
        unawaited(_loadUnread());
      }
      if (_to == null) {
        unawaited(_loadLocation());
      }
    } else if (report.isClosed) {
      _stopLive();
    }
  }

  Future<void> _subscribe() async {
    if (_subscribing || _reportChannel != null) {
      return;
    }
    _subscribing = true;
    final id = widget.reportId;
    try {
      final reportChannel = await _realtime.subscribe(
        'report.$id',
        {
          'DriverLocationUpdated': _onLocationEvent,
          'ReportStatusChanged': (_) => unawaited(_loadReport()),
        },
        onAuthFailed: () => _channelRejected = true,
      );
      final chatChannel = await _realtime.subscribe('chat.$id', {'ChatMessageSent': _onChatEvent});
      if (!mounted) {
        reportChannel.cancel();
        chatChannel.cancel();
        return;
      }
      _reportChannel = reportChannel;
      _chatChannel = chatChannel;
    } on Object {
      // Polling tetap berjalan; WebSocket hanya mempercepat pembaruan.
      _channelRejected = true;
    } finally {
      _subscribing = false;
    }
  }

  void _stopLive() {
    _routeTimer?.cancel();
    _routeTimer = null;
    _reportChannel?.cancel();
    _reportChannel = null;
    _chatChannel?.cancel();
    _chatChannel = null;
  }

  void _onLocationEvent(Map<String, dynamic> data) {
    try {
      _moveAmbulance(DriverLocation.fromJson(data));
    } on Object {
      // Payload tidak lengkap: abaikan, posisi berikutnya akan datang.
    }
  }

  void _onChatEvent(Map<String, dynamic> data) {
    final senderId = (data['sender_id'] as num?)?.toInt();
    if (senderId != null && senderId != ref.read(sessionProvider).user?.id && mounted) {
      setState(() => _unread++);
    }
  }

  Future<void> _loadLocation() async {
    try {
      final location = await _reports.driverLocation(widget.reportId);
      if (location != null && mounted) {
        _moveAmbulance(location);
      }
    } on ApiError {
      // Dicoba lagi pada tick berikutnya.
    }
  }

  Future<void> _loadRoute() async {
    try {
      final route = await _reports.route(widget.reportId);
      if (!mounted) {
        return;
      }
      setState(() => _route = route);
      if (_followCamera) {
        _fitCamera();
      }
    } on ApiError {
      // Rute lama tetap ditampilkan (mis. dibatasi throttle atau OSRM sedang sibuk).
    }
  }

  Future<void> _loadUnread() async {
    try {
      final summary = await ref.read(chatRepositoryProvider).unreadCount();
      if (mounted) {
        setState(() => _unread = summary.forReport(widget.reportId));
      }
    } on ApiError {
      // Badge tidak kritis.
    }
  }

  // Posisi dan arah ambulans yang sedang tampil (di tengah animasi).
  LatLng? get _ambulancePoint {
    final from = _from;
    final to = _to;
    if (from == null || to == null) {
      return to;
    }
    final t = _motion.value;
    return LatLng(from.latitude + (to.latitude - from.latitude) * t, from.longitude + (to.longitude - from.longitude) * t);
  }

  double get _heading {
    final delta = ((_headingTo - _headingFrom + 540) % 360) - 180;
    return (_headingFrom + delta * _motion.value) % 360;
  }

  void _moveAmbulance(DriverLocation location) {
    final next = LatLng(location.lat, location.lng);
    final first = _to == null;

    _from = _ambulancePoint ?? next;
    _headingFrom = _heading;
    _to = next;
    if (location.heading != null) {
      _headingTo = location.heading!.toDouble();
      _hasHeading = true;
    }
    if (first) {
      _headingFrom = _headingTo;
    }

    if (first || MediaQuery.of(context).disableAnimations) {
      _motion.value = 1;
      setState(() {});
    } else {
      unawaited(_motion.forward(from: 0));
    }

    if (first && _followCamera) {
      _fitCamera();
    }
  }

  LatLng? get _pickup => _report == null ? null : LatLng(_report!.latitude, _report!.longitude);

  LatLng? get _destination {
    final destination = _report?.destination;
    return destination?.latitude == null || destination?.longitude == null
        ? null
        : LatLng(destination!.latitude!, destination.longitude!);
  }

  void _fitCamera() {
    if (!_mapReady) {
      return;
    }
    final target = (_route?.toDestination ?? false) ? (_destination ?? _pickup) : _pickup;
    final points = [?_to, ?target];
    if (points.isEmpty) {
      return;
    }
    if (points.length == 1) {
      _map.move(points.single, 16);
      return;
    }
    _map.fitCamera(
      CameraFit.coordinates(coordinates: points, padding: const EdgeInsets.fromLTRB(56, 120, 56, 56), maxZoom: 17),
    );
  }

  Future<void> _openChat() async {
    await context.push(Routes.chat(widget.reportId));
    if (mounted) {
      setState(() => _unread = 0);
      unawaited(_loadUnread());
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lacak Ambulans')),
        body: _error == null
            ? const Center(child: CircularProgressIndicator())
            : AsyncErrorView(
                error: _error!,
                onRetry: () {
                  setState(() => _error = null);
                  unawaited(_loadReport());
                },
              ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: _buildMap(report)),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(child: _TopBar(report: report)),
                ),
              ],
            ),
          ),
          _Panel(
            child: switch (report) {
              Report(isClosed: true) => _ClosedPanel(report: report),
              Report(isWaiting: true) => _WaitingPanel(report: report),
              _ => _ActivePanel(report: report, route: _route, unread: _unread, onChat: _openChat),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMap(Report report) {
    final pickup = _pickup!;
    final destination = _destination;
    final route = _route;

    return AnimatedBuilder(
      animation: _motion,
      builder: (context, _) {
        final ambulance = _ambulancePoint;
        return MedMapView(
          controller: _map,
          initialCenter: pickup,
          initialZoom: 15,
          onMapReady: () {
            _mapReady = true;
            _fitCamera();
          },
          onPositionChanged: (_, hasGesture) {
            if (hasGesture) {
              _followCamera = false;
            }
          },
          onRecenter: () {
            _followCamera = true;
            _fitCamera();
          },
          polylines: [
            if (route != null && route.geometry.length > 1 && report.isActive)
              Polyline(
                points: [for (final point in route.geometry) LatLng(point[0], point[1])],
                color: MedColors.brand,
                strokeWidth: 5,
                borderColor: Colors.white,
                borderStrokeWidth: 2,
              ),
          ],
          markers: [
            Marker(
              point: pickup,
              width: 44,
              height: 44,
              alignment: Alignment.topCenter,
              child: const PickupPin(size: 44),
            ),
            if (destination != null)
              Marker(point: destination, width: 40, height: 40, child: const _DestinationMarker()),
            if (ambulance != null && report.isActive)
              Marker(
                point: ambulance,
                width: 56,
                height: 56,
                child: AmbulanceMarker(heading: _hasHeading ? _heading : null, size: 56),
              ),
          ],
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(MedSpace.md, MedSpace.sm, MedSpace.md, 0),
        child: Row(
          children: [
            Material(
              color: MedColors.surface,
              shape: const CircleBorder(),
              elevation: 4,
              shadowColor: Colors.black26,
              child: IconButton(
                tooltip: 'Kembali',
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home),
              ),
            ),
            const SizedBox(width: MedSpace.sm),
            Flexible(
              child: Material(
                color: MedColors.surface,
                borderRadius: BorderRadius.circular(MedRadius.pill),
                elevation: 4,
                shadowColor: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: MedSpace.md, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          report.code,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900, color: MedColors.ink),
                        ),
                      ),
                      const SizedBox(width: MedSpace.sm),
                      StatusBadge(status: report.statusValue, label: report.status.label),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

/// Panel bawah putih dengan sudut besar seperti sheet di Figma.
class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.56),
        decoration: const BoxDecoration(
          color: MedColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(MedRadius.lg)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.lg, MedSpace.gutter, MedSpace.lg),
            child: child,
          ),
        ),
      );
}

class _WaitingPanel extends StatelessWidget {
  const _WaitingPanel({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final created = report.createdAt;
    final minutes = created == null ? report.waitingMinutes : DateTime.now().difference(created).inMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Mencari ambulans terdekat', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: MedSpace.sm),
        const ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(MedRadius.pill)),
          child: LinearProgressIndicator(minHeight: 6, color: MedColors.brand, backgroundColor: MedColors.brandSoft),
        ),
        const SizedBox(height: MedSpace.md),
        Text(
          'Laporan sudah diterima. Driver ambulans di sekitar Anda sedang dihubungi, dan admin pusat ikut '
          'memantau. Halaman ini diperbarui otomatis.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MedColors.inkMuted),
        ),
        if (minutes != null) ...[
          const SizedBox(height: MedSpace.sm),
          Text(
            minutes < 1 ? 'Dikirim baru saja' : 'Menunggu $minutes menit',
            style: const TextStyle(fontWeight: FontWeight.w800, color: MedColors.ink),
          ),
        ],
        const SizedBox(height: MedSpace.lg),
        SecondaryButton(
          label: 'Lihat detail laporan',
          icon: Icons.description_outlined,
          onPressed: () => context.push(Routes.reportDetail(report.id)),
        ),
      ],
    );
  }
}

class _ActivePanel extends StatelessWidget {
  const _ActivePanel({required this.report, required this.route, required this.unread, required this.onChat});

  final Report report;
  final RouteResult? route;
  final int unread;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EtaRow(report: report, route: route),
          const SizedBox(height: MedSpace.md),
          _StatusSteps(current: report.statusValue),
          if (report.driver != null) ...[
            const SizedBox(height: MedSpace.lg),
            _DriverRow(report: report, unread: unread, onChat: onChat),
          ],
        ],
      );
}

class _EtaRow extends StatelessWidget {
  const _EtaRow({required this.report, required this.route});

  final Report report;
  final RouteResult? route;

  @override
  Widget build(BuildContext context) {
    final route = this.route;
    final arrived = report.statusValue == ReportStatus.tibaDiLokasi;

    if (arrived) {
      return const _EtaText(title: 'Ambulans sudah tiba', subtitle: 'Petugas berada di lokasi penjemputan.');
    }
    if (route == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Skeleton(width: 140, height: 28), SizedBox(height: MedSpace.sm), Skeleton(width: 220)],
      );
    }

    final target = route.toDestination ? 'menuju tujuan antar' : 'menuju lokasi Anda';
    return _EtaText(
      title: formatDuration(route.durationMin),
      subtitle: '${formatDistance(route.distanceKm)} $target${route.stale ? ' · perkiraan terakhir' : ''}',
    );
  }
}

class _EtaText extends StatelessWidget {
  const _EtaText({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: MedColors.ink)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

/// Chip urutan status: yang sudah lewat bertanda centang, yang sedang berjalan berwarna.
class _StatusSteps extends StatelessWidget {
  const _StatusSteps({required this.current});

  final String current;

  static const _steps = [
    ReportStatus.diambil,
    ReportStatus.dalamPerjalanan,
    ReportStatus.tibaDiLokasi,
    ReportStatus.mengantarPasien,
    ReportStatus.selesai,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexOf(current);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < _steps.length; index++) ...[
            if (index > 0) const SizedBox(width: 6),
            _StepChip(
              label: ReportStatus.label(_steps[index]),
              status: _steps[index],
              done: index < currentIndex,
              current: index == currentIndex,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({required this.label, required this.status, required this.done, required this.current});

  final String label;
  final String status;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final tone = StatusTone.of(status);
    final foreground = current ? tone.foreground : (done ? MedColors.ink : MedColors.inkFaint);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: current ? tone.background : MedColors.surface,
        borderRadius: BorderRadius.circular(MedRadius.pill),
        border: Border.all(color: current ? tone.background : MedColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (done) ...[
            const Icon(Icons.check_rounded, size: 15, color: MedColors.success),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w800, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({required this.report, required this.unread, required this.onChat});

  final Report report;
  final int unread;
  final VoidCallback onChat;

  Future<void> _call(BuildContext context, String phone) async {
    final launched = await launchUrl(Uri(scheme: 'tel', path: phone));
    if (!launched && context.mounted) {
      showMessage(context, 'Tidak bisa membuka aplikasi telepon. Nomor driver: $phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    final driver = report.driver!;
    final ambulance = report.ambulance;
    final clinic = ambulance?.clinic ?? driver.clinic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            DriverAvatar(name: driver.name, photoUrl: driver.photoUrl, size: 52),
            const SizedBox(width: MedSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: MedSpace.sm,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(driver.name, style: Theme.of(context).textTheme.titleMedium),
                      if (driver.isVerified) const VerifiedBadge(),
                    ],
                  ),
                  if (ambulance != null)
                    Text(
                      ambulance.plateNumber,
                      style: const TextStyle(color: MedColors.ink, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  if (clinic != null)
                    Text(clinic, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: MedColors.inkMuted)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: MedSpace.md),
        Row(
          children: [
            Expanded(
              child: CountBadge(
                count: unread,
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onChat,
                    icon: const Icon(Icons.chat_bubble_rounded),
                    label: Text(unread > 0 ? 'Chat ($unread baru)' : 'Chat Driver'),
                  ),
                ),
              ),
            ),
            if (driver.phone != null) ...[
              const SizedBox(width: MedSpace.sm),
              IconButton.outlined(
                tooltip: 'Telepon driver',
                iconSize: 24,
                constraints: const BoxConstraints.tightFor(width: 52, height: 52),
                onPressed: () => _call(context, driver.phone!),
                icon: const Icon(Icons.call_rounded, color: MedColors.brand),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ClosedPanel extends StatelessWidget {
  const _ClosedPanel({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final done = report.statusValue == ReportStatus.selesai;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: done ? const Color(0xFFDCFCE7) : MedColors.field,
                shape: BoxShape.circle,
              ),
              child: Icon(
                done ? Icons.check_rounded : Icons.block_rounded,
                color: done ? MedColors.success : MedColors.inkMuted,
              ),
            ),
            const SizedBox(width: MedSpace.md),
            Expanded(
              child: Text(
                done ? 'Penanganan selesai' : 'Laporan dibatalkan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: MedSpace.md),
        Text(
          done
              ? 'Terima kasih sudah melapor. Ringkasan penanganan dan data pasien tersimpan di detail laporan.'
              : 'Laporan ini dibatalkan oleh admin pusat. Bila masih membutuhkan bantuan, buat laporan baru atau '
                  'hubungi 112.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MedColors.inkMuted),
        ),
        if (report.completedAt != null) ...[
          const SizedBox(height: MedSpace.sm),
          Text(formatDateTime(report.completedAt), style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
        const SizedBox(height: MedSpace.lg),
        PrimaryButton(
          label: 'Lihat Detail Laporan',
          icon: Icons.description_outlined,
          onPressed: () => context.pushReplacement(Routes.reportDetail(report.id)),
        ),
      ],
    );
  }
}

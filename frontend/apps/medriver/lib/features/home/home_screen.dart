import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../router.dart';
import '../../services/location_ping.dart';
import '../../state/chat_state.dart';
import '../../state/dispatch_state.dart';
import '../../state/driver_state.dart';
import '../../state/session.dart';
import '../../widgets/connection_banner.dart';
import '../../widgets/driver_drawer.dart';
import '../../widgets/feedback.dart';
import '../../widgets/media.dart';
import 'duty_toggle.dart';
import 'shift_sheets.dart';

/// Beranda driver. Fokus layar: sakelar Aktif/Nonaktif di pita merah. Saat aktif: peta posisi
/// sendiri, kartu shift, status standby, tawaran yang menunggu, dan tombol Tutup Shift.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scaffold = GlobalKey<ScaffoldState>();
  bool _busy = false;

  Future<void> _toggle(DriverSnapshot snapshot) async {
    if (_busy) {
      return;
    }
    if (snapshot.hasMission) {
      showMessage(context, 'Selesaikan laporan yang sedang ditangani sebelum menutup shift.');
      return;
    }
    setState(() => _busy = true);
    try {
      if (snapshot.isActive) {
        final closed = await showCloseShiftSheet(context);
        if (closed && mounted) {
          showMessage(context, 'Shift ditutup. Pengiriman lokasi berhenti.');
        }
      } else {
        final allowed = await ensureShiftPermissions(context, ref);
        if (!allowed || !mounted) {
          return;
        }
        final opened = await showOpenShiftSheet(context);
        if (opened && mounted) {
          showMessage(context, 'Shift dimulai. Anda standby menunggu tawaran.');
          unawaited(ref.read(dispatchProvider.notifier).pull());
        }
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _closeShiftFromMenu() async {
    final snapshot = ref.read(driverProvider).value;
    if (snapshot != null) {
      await _toggle(snapshot);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(retryTickProvider, (_, _) => unawaited(ref.read(driverProvider.notifier).refresh()));
    final driver = ref.watch(driverProvider);
    final user = ref.watch(sessionProvider).user;
    final snapshot = driver.value;

    return Scaffold(
      key: _scaffold,
      drawer: DriverDrawer(onCloseShiftRequested: () => unawaited(_closeShiftFromMenu())),
      onDrawerChanged: (open) {
        if (open) {
          ref.invalidate(unreadProvider);
        }
      },
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(
              name: snapshot?.account.name ?? user?.name ?? '',
              initials: snapshot?.account.initials ?? user?.initials,
              clinic: snapshot?.account.driverProfile?.clinic?.name,
              onMenu: () => _scaffold.currentState?.openDrawer(),
            ),
            Expanded(
              child: driver.when(
                skipLoadingOnRefresh: true,
                skipLoadingOnReload: true,
                loading: () => const _HomeSkeleton(),
                error: (error, _) => AsyncErrorView(error: error, onRetry: () => ref.invalidate(driverProvider)),
                data: (snapshot) => RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(driverProvider.notifier).refresh();
                    await ref.read(dispatchProvider.notifier).pull();
                  },
                  child: _HomeBody(snapshot: snapshot, busy: _busy, onToggle: () => _toggle(snapshot)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.name, required this.initials, required this.clinic, required this.onMenu});

  final String name;
  final String? initials;
  final String? clinic;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(MedSpace.md, MedSpace.md, MedSpace.gutter, MedSpace.md),
        child: Row(
          children: [
            Semantics(
              button: true,
              label: 'Buka menu',
              child: InkWell(
                onTap: onMenu,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: InitialsAvatar(name: name, initials: initials, size: 48),
                ),
              ),
            ),
            const SizedBox(width: MedSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge),
                  if (clinic != null)
                    Text(clinic!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: MedColors.inkMuted)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.snapshot, required this.busy, required this.onToggle});

  final DriverSnapshot snapshot;
  final bool busy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shift = snapshot.shift;
    final mission = snapshot.mission;
    final offers = ref.watch(dispatchProvider).pending;

    return ListView(
      padding: EdgeInsets.zero,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Pita merah "Info Spot" (Figma) berisi sakelar shift: satu fokus utama di layar.
        Container(
          margin: const EdgeInsets.symmetric(horizontal: MedSpace.md),
          padding: const EdgeInsets.fromLTRB(MedSpace.xl, MedSpace.md, MedSpace.lg, MedSpace.md),
          decoration: BoxDecoration(color: MedColors.brand, borderRadius: BorderRadius.circular(MedRadius.lg)),
          child: DutyToggle(
            key: const Key('duty-toggle'),
            active: snapshot.isActive,
            busy: busy,
            onPressed: onToggle,
          ),
        ),
        const SizedBox(height: MedSpace.lg),
        if (shift == null)
          const _InactiveInfo()
        else ...[
          if (mission != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(MedSpace.gutter, 0, MedSpace.gutter, MedSpace.lg),
              child: _MissionCard(report: mission),
            )
          else
            const Padding(
              padding: EdgeInsets.fromLTRB(MedSpace.gutter, 0, MedSpace.gutter, MedSpace.md),
              child: _StandbyBanner(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MedSpace.gutter),
            child: _LiveMap(fallback: _fallbackCenter(snapshot)),
          ),
          const SizedBox(height: MedSpace.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MedSpace.gutter),
            child: _ShiftCard(shift: shift),
          ),
          if (mission == null && offers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.xl, MedSpace.gutter, MedSpace.sm),
              child: Text('Tawaran menunggu jawaban', style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final offer in offers)
              Padding(
                padding: const EdgeInsets.fromLTRB(MedSpace.gutter, 0, MedSpace.gutter, MedSpace.sm),
                child: DispatchOfferCard(
                  typeName: offer.report?.typeName ?? 'Laporan',
                  typeColor: colorFromHex(offer.report?.reportType?.color),
                  typeIcon: reportTypeIcon(offer.report?.reportType?.icon, code: offer.report?.reportType?.code),
                  code: offer.report?.code,
                  distanceKm: offer.distanceKm,
                  address: offer.report?.shortAddress ?? offer.report?.address,
                  priority: offer.report?.reportType?.priority,
                  onTap: () => context.push(Routes.offer(offer.id)),
                ),
              ),
          ],
          if (mission == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.xl, MedSpace.gutter, MedSpace.xl),
              child: SecondaryButton(
                key: const Key('close-shift'),
                label: 'Tutup Shift',
                icon: Icons.stop_circle_outlined,
                onPressed: busy ? null : onToggle,
              ),
            )
          else
            const SizedBox(height: MedSpace.xl),
        ],
        SizedBox(height: MediaQuery.paddingOf(context).bottom),
      ],
    );
  }

  /// Sebelum titik GPS pertama: koordinat klinik (asumsi backend: shift dibuka di klinik),
  /// atau Simpang Lima Semarang.
  static LatLng _fallbackCenter(DriverSnapshot snapshot) {
    final clinic = snapshot.account.driverProfile?.clinic;
    if (clinic?.latitude != null && clinic?.longitude != null) {
      return LatLng(clinic!.latitude!, clinic.longitude!);
    }
    return const LatLng(-6.9904, 110.4229);
  }
}

class _InactiveInfo extends StatelessWidget {
  const _InactiveInfo();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: MedSpace.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Step(number: 1, text: 'Ketuk sakelar di atas, lalu pilih ambulans klinik yang Anda bawa hari ini.'),
            _Step(number: 2, text: 'Selama aktif, lokasi ambulans dikirim ke admin pusat dan tawaran laporan terdekat masuk dengan alarm.'),
            _Step(number: 3, text: 'Tutup shift dengan alasan saat selesai bertugas. Shift tidak pernah ditutup otomatis.'),
          ],
        ),
      );
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: MedSpace.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: MedColors.brandSoft, shape: BoxShape.circle),
              child: Text('$number', style: const TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: MedSpace.md),
            Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
          ],
        ),
      );
}

class _StandbyBanner extends StatelessWidget {
  const _StandbyBanner();

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: MedSpace.lg, vertical: MedSpace.md),
          decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(MedRadius.md)),
          child: const Row(
            children: [
              Icon(Icons.hourglass_top_rounded, color: Color(0xFF1E40AF)),
              SizedBox(width: MedSpace.md),
              Expanded(
                child: Text(
                  'Standby: menunggu tawaran order',
                  key: Key('standby-banner'),
                  style: TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      );
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: () => context.push(Routes.mission(report.id)),
        color: MedColors.brandSoft,
        child: Row(
          children: [
            ReportTypeTile(
              icon: reportTypeIcon(report.reportType?.icon, code: report.reportType?.code),
              color: colorFromHex(report.reportType?.color),
              size: 48,
            ),
            const SizedBox(width: MedSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Misi berjalan', style: TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w900)),
                  Text('${report.typeName} · ${report.code}', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  StatusBadge(status: report.statusValue, label: report.status.label),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: MedColors.brandDeep, semanticLabel: 'Buka misi'),
          ],
        ),
      );
}

class _ShiftCard extends ConsumerWidget {
  const _ShiftCard({required this.shift});

  final Shift shift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambulance = shift.ambulance;

    return ValueListenableBuilder<PingStatus>(
      valueListenable: ref.watch(locationPingProvider).status,
      builder: (context, status, _) {
        final sent = status.lastSentAt;
        final label = !status.hasFix
            ? 'Mencari sinyal GPS'
            : status.queued > 0
                ? 'GPS aktif · ${status.queued} titik menunggu koneksi'
                : sent == null
                    ? 'GPS aktif'
                    : 'GPS aktif · terkirim ${formatTime(sent)}';

        return ShiftStatusCard(
          plateNumber: ambulance?.plateNumber ?? '-',
          vehicleName: ambulance?.vehicleName,
          ambulanceType: ambulance?.ambulanceType?.name,
          startedAt: shift.startedAt,
          gpsActive: status.hasFix,
          gpsLabel: label,
          batteryLevel: status.batteryLevel,
        );
      },
    );
  }
}

/// Peta posisi sendiri dari titik GPS terakhir pengirim lokasi.
class _LiveMap extends ConsumerStatefulWidget {
  const _LiveMap({required this.fallback});

  final LatLng fallback;

  @override
  ConsumerState<_LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends ConsumerState<_LiveMap> {
  final _map = MapController();
  bool _ready = false;
  bool _follow = true;

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(MedRadius.lg),
        child: SizedBox(
          height: 240,
          child: ValueListenableBuilder<PingStatus>(
            valueListenable: ref.watch(locationPingProvider).status,
            builder: (context, status, _) {
              final fix = status.lastFix;
              final me = fix == null ? null : LatLng(fix.latitude, fix.longitude);
              if (me != null && _ready && _follow) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _map.move(me, _map.camera.zoom);
                  }
                });
              }
              return MedMapView(
                controller: _map,
                initialCenter: me ?? widget.fallback,
                initialZoom: 15,
                userAgentPackageName: 'com.medrive.driver',
                onMapReady: () => _ready = true,
                onPositionChanged: (_, hasGesture) {
                  if (hasGesture) {
                    _follow = false;
                  }
                },
                onRecenter: me == null
                    ? null
                    : () {
                        _follow = true;
                        _map.move(me, 16);
                      },
                markers: [
                  if (me != null)
                    Marker(point: me, width: 52, height: 52, child: AmbulanceMarker(heading: fix!.heading != null && fix.heading! >= 0 ? fix.heading : null)),
                ],
              );
            },
          ),
        ),
      );
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: MedSpace.md),
        children: const [
          Skeleton(height: 96, radius: MedRadius.lg),
          SizedBox(height: MedSpace.lg),
          Skeleton(height: 240, radius: MedRadius.lg),
          SizedBox(height: MedSpace.md),
          Skeleton(height: 170, radius: MedRadius.lg),
        ],
      );
}

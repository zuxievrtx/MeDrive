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
      showMessage(
        context,
        'Selesaikan laporan yang sedang ditangani sebelum menutup shift.',
      );
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
    ref.listen(
      retryTickProvider,
      (_, _) => unawaited(ref.read(driverProvider.notifier).refresh()),
    );
    final driver = ref.watch(driverProvider);
    final user = ref.watch(sessionProvider).user;
    final snapshot = driver.value;

    return Scaffold(
      key: _scaffold,
      drawer: DriverDrawer(
        onCloseShiftRequested: () => unawaited(_closeShiftFromMenu()),
        onDutyToggleRequested: () {
          final current = ref.read(driverProvider).value;
          if (current != null) {
            unawaited(_toggle(current));
          }
        },
      ),
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
                error: (error, _) => AsyncErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(driverProvider),
                ),
                data: (snapshot) => RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(driverProvider.notifier).refresh();
                    await ref.read(dispatchProvider.notifier).pull();
                  },
                  child: _HomeBody(snapshot: snapshot),
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
  const _TopBar({
    required this.name,
    required this.initials,
    required this.clinic,
    required this.onMenu,
  });

  final String name;
  final String? initials;
  final String? clinic;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      MedSpace.md,
      MedSpace.md,
      MedSpace.gutter,
      MedSpace.md,
    ),
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
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (clinic != null)
                Text(
                  clinic!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: MedColors.inkMuted),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _HomeBody extends ConsumerStatefulWidget {
  const _HomeBody({required this.snapshot});

  final DriverSnapshot snapshot;

  @override
  ConsumerState<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends ConsumerState<_HomeBody> {
  bool _showReports = false;

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    final offers = ref.watch(dispatchProvider).pending;
    final mapHeight = (MediaQuery.sizeOf(context).height * 0.58)
        .clamp(360.0, 620.0)
        .toDouble();

    return ListView(
      padding: EdgeInsets.zero,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _HomeTabs(
          showReports: _showReports,
          onChanged: (showReports) =>
              setState(() => _showReports = showReports),
        ),
        const SizedBox(height: MedSpace.sm),
        if (_showReports)
          _ReportsContent(snapshot: snapshot, offers: offers)
        else ...[
          if (snapshot.shift != null && snapshot.mission == null)
            const Padding(
              padding: EdgeInsets.fromLTRB(
                MedSpace.gutter,
                0,
                MedSpace.gutter,
                MedSpace.md,
              ),
              child: _StandbyBanner(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MedSpace.md),
            child: _LiveMap(
              fallback: _fallbackCenter(snapshot),
              height: mapHeight,
            ),
          ),
          const SizedBox(height: MedSpace.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MedSpace.gutter),
            child: _VehicleInfo(snapshot: snapshot),
          ),
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

class _ReportsContent extends StatelessWidget {
  const _ReportsContent({required this.snapshot, required this.offers});

  final DriverSnapshot snapshot;
  final List<Dispatch> offers;

  @override
  Widget build(BuildContext context) {
    final shift = snapshot.shift;
    final mission = snapshot.mission;

    return Column(
      children: [
        if (mission != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              MedSpace.gutter,
              0,
              MedSpace.gutter,
              MedSpace.lg,
            ),
            child: _MissionCard(report: mission),
          ),
        if (mission == null && offers.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              MedSpace.gutter,
              MedSpace.xl,
              MedSpace.gutter,
              MedSpace.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tawaran menunggu jawaban',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          for (final offer in offers)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MedSpace.gutter,
                0,
                MedSpace.gutter,
                MedSpace.sm,
              ),
              child: DispatchOfferCard(
                typeName: offer.report?.typeName ?? 'Laporan',
                typeColor: colorFromHex(offer.report?.reportType?.color),
                typeIcon: reportTypeIcon(
                  offer.report?.reportType?.icon,
                  code: offer.report?.reportType?.code,
                ),
                code: offer.report?.code,
                distanceKm: offer.distanceKm,
                address: offer.report?.shortAddress ?? offer.report?.address,
                priority: offer.report?.reportType?.priority,
                onTap: () => context.push(Routes.offer(offer.id)),
              ),
            ),
        ],
        if (shift == null && mission == null)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: MedSpace.gutter),
            child: _InactiveInfo(),
          ),
        const SizedBox(height: MedSpace.xl),
      ],
    );
  }
}

class _HomeTabs extends StatelessWidget {
  const _HomeTabs({required this.showReports, required this.onChanged});

  final bool showReports;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: MedSpace.gutter),
    child: Row(
      children: [
        _TabItem(
          label: 'Maps',
          active: !showReports,
          onTap: () => onChanged(false),
        ),
        _TabItem(
          label: 'Daftar Laporan',
          active: showReports,
          onTap: () => onChanged(true),
        ),
      ],
    ),
  );
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: active ? MedColors.brand : MedColors.inkMuted,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: MedSpace.sm),
            Container(
              height: 3,
              color: active ? MedColors.brand : Colors.transparent,
            ),
          ],
        ),
      ),
    ),
  );
}

class _VehicleInfo extends StatelessWidget {
  const _VehicleInfo({required this.snapshot});

  final DriverSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final ambulance = snapshot.shift?.ambulance;
    final vehicle = ambulance == null
        ? 'Belum ada kendaraan aktif'
        : [
            ambulance.vehicleName,
            ambulance.ambulanceType?.name,
          ].whereType<String>().where((value) => value.isNotEmpty).join(' · ');

    return Container(
      padding: const EdgeInsets.all(MedSpace.md),
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: BorderRadius.circular(MedRadius.md),
        border: Border.all(color: MedColors.line),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            color: MedColors.brand,
            size: 28,
          ),
          const SizedBox(width: MedSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kendaraan aktif',
                  style: TextStyle(color: MedColors.inkMuted, fontSize: 12),
                ),
                Text(
                  vehicle.isEmpty ? 'Belum ada kendaraan aktif' : vehicle,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  'Plat nomor: ${ambulance?.plateNumber ?? '-'}',
                  style: const TextStyle(
                    color: MedColors.inkMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        _Step(
          number: 1,
          text: 'Buka menu Profil, nyalakan shift, lalu pilih ambulans klinik yang akan dibawa.',
        ),
        _Step(
          number: 2,
          text: 'Selama aktif, lokasi ambulans dikirim ke admin pusat dan tawaran laporan terdekat masuk dengan alarm.',
        ),
        _Step(
          number: 3,
          text: 'Tutup shift dengan alasan saat selesai bertugas. Shift tidak pernah ditutup otomatis.',
        ),
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
          decoration: const BoxDecoration(
            color: MedColors.brandSoft,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: MedColors.brandDeep,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: MedSpace.md),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: MedSpace.lg,
        vertical: MedSpace.md,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(MedRadius.md),
      ),
      child: const Row(
        children: [
          Icon(Icons.hourglass_top_rounded, color: Color(0xFF1E40AF)),
          SizedBox(width: MedSpace.md),
          Expanded(
            child: Text(
              'Standby: menunggu tawaran order',
              key: Key('standby-banner'),
              style: TextStyle(
                color: Color(0xFF1E40AF),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
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
          icon: reportTypeIcon(
            report.reportType?.icon,
            code: report.reportType?.code,
          ),
          color: colorFromHex(report.reportType?.color),
          size: 48,
        ),
        const SizedBox(width: MedSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Misi berjalan',
                style: TextStyle(
                  color: MedColors.brandDeep,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${report.typeName} · ${report.code}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              StatusBadge(
                status: report.statusValue,
                label: report.status.label,
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: MedColors.brandDeep,
          semanticLabel: 'Buka misi',
        ),
      ],
    ),
  );
}

// Kept for compatibility with the existing driver status component.
// ignore: unused_element
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
  const _LiveMap({required this.fallback, required this.height});

  final LatLng fallback;
  final double height;

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
      height: widget.height,
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
                Marker(
                  point: me,
                  width: 52,
                  height: 52,
                  child: AmbulanceMarker(
                    heading: fix!.heading != null && fix.heading! >= 0
                        ? fix.heading
                        : null,
                  ),
                ),
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

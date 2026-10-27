import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';
import 'package:uuid/uuid.dart';

import '../../router.dart';
import '../../services/dispatch_alarm.dart';
import '../../state/dispatch_state.dart';
import '../../state/driver_state.dart';
import '../../widgets/feedback.dart';

enum _OfferOutcome { open, lost, expired, unavailable }

/// Tawaran dispatch layar penuh. Latar merah penuh karena layar ini harus terbaca sekilas dari
/// kursi pengemudi; satu fokus: tombol TERIMA. Alarm (suara berulang + getar) berbunyi selama
/// layar terbuka dan berhenti saat dijawab atau diabaikan.
class OfferScreen extends ConsumerStatefulWidget {
  const OfferScreen({super.key, required this.dispatchId});

  final int dispatchId;

  @override
  ConsumerState<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends ConsumerState<OfferScreen> {
  /// Satu kunci per tawaran: retry jaringan setelah menang tidak berubah jadi error.
  final _idempotencyKey = const Uuid().v4();

  Dispatch? _dispatch;
  Object? _loadError;
  bool _accepting = false;
  _OfferOutcome _outcome = _OfferOutcome.open;
  String? _outcomeMessage;
  bool _alarmOn = false;
  late final DispatchController _dispatches = ref.read(dispatchProvider.notifier);
  late final DispatchAlarm _alarm = ref.read(dispatchAlarmProvider);

  @override
  void initState() {
    super.initState();
    _dispatches.showing = widget.dispatchId;
    unawaited(_load());
  }

  @override
  void dispose() {
    if (_dispatches.showing == widget.dispatchId) {
      _dispatches.showing = null;
    }
    unawaited(_stopAlarm());
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loadError = null);
    try {
      final dispatch = await ref.read(driverRepositoryProvider).dispatch(widget.dispatchId);
      if (!mounted) {
        return;
      }
      final stillOpen = dispatch.isPending && (dispatch.report?.isWaiting ?? true);
      setState(() {
        _dispatch = dispatch;
        if (!stillOpen) {
          _outcome = _OfferOutcome.unavailable;
          _outcomeMessage = 'Tawaran ini sudah tidak berlaku. Laporan sudah diambil atau broadcast sudah diperluas.';
        }
      });
      if (stillOpen) {
        _alarmOn = true;
        await _alarm.start(dispatch);
      } else {
        _dispatches.resolved(widget.dispatchId);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _loadError = error);
      }
    }
  }

  Future<void> _stopAlarm() async {
    if (_alarmOn) {
      _alarmOn = false;
      await _alarm.stop(widget.dispatchId);
    }
  }

  Future<void> _accept() async {
    if (_accepting) {
      return;
    }
    setState(() => _accepting = true);
    try {
      final report = await ref.read(driverRepositoryProvider).accept(widget.dispatchId, idempotencyKey: _idempotencyKey);
      await _stopAlarm();
      _dispatches.resolved(widget.dispatchId);
      ref.read(driverProvider.notifier).setMission(report);
      unawaited(ref.read(driverProvider.notifier).refresh());
      if (mounted) {
        final router = GoRouter.of(context)..go(Routes.home);
        unawaited(router.push(Routes.mission(report.id)));
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      final apiError = asApiError(error);
      final outcome = switch (apiError.code) {
        'too_late' => _OfferOutcome.lost,
        'offer_expired' => _OfferOutcome.expired,
        'already_on_duty' || 'no_open_shift' => _OfferOutcome.unavailable,
        _ => null,
      };
      if (outcome == null) {
        // Gangguan jaringan atau server: tawaran mungkin masih bisa diambil, biarkan driver mencoba lagi.
        showError(context, apiError);
        setState(() => _accepting = false);
        return;
      }
      await _stopAlarm();
      _dispatches.resolved(widget.dispatchId);
      setState(() {
        _accepting = false;
        _outcome = outcome;
        _outcomeMessage = switch (outcome) {
          _OfferOutcome.lost => 'Kalah cepat: driver lain lebih dulu mengambil laporan ini.',
          _OfferOutcome.expired => apiError.message,
          _ => apiError.message,
        };
      });
    }
  }

  Future<void> _dismiss() async {
    await _stopAlarm();
    _dispatches.dismiss(widget.dispatchId);
    if (mounted) {
      _leave();
    }
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            if (_outcome == _OfferOutcome.open) {
              unawaited(_dismiss());
            } else {
              _leave();
            }
          }
        },
        child: Scaffold(
          backgroundColor: MedColors.brand,
          body: SafeArea(child: _buildBody()),
        ),
      );

  Widget _buildBody() {
    final dispatch = _dispatch;
    if (dispatch == null) {
      if (_loadError != null) {
        final error = asApiError(_loadError!);
        return _Result(
          icon: error.isNetwork ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
          title: error.isNetwork ? 'Tidak ada koneksi' : 'Tawaran tidak bisa dibuka',
          message: error.message,
          primaryLabel: 'Coba lagi',
          onPrimary: _load,
          onBack: _leave,
        );
      }
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return switch (_outcome) {
      _OfferOutcome.open => _OfferDetails(dispatch: dispatch, accepting: _accepting, onAccept: _accept, onDismiss: _dismiss),
      _OfferOutcome.lost => _Result(
          key: const Key('offer-lost'),
          icon: Icons.timer_off_outlined,
          title: 'Kalah cepat',
          message: _outcomeMessage!,
          primaryLabel: 'Kembali ke standby',
          onPrimary: _leave,
        ),
      _ => _Result(
          icon: Icons.event_busy_rounded,
          title: 'Tawaran berakhir',
          message: _outcomeMessage ?? 'Tawaran ini sudah tidak berlaku.',
          primaryLabel: 'Kembali ke standby',
          onPrimary: _leave,
        ),
    };
  }
}

class _OfferDetails extends StatelessWidget {
  const _OfferDetails({required this.dispatch, required this.accepting, required this.onAccept, required this.onDismiss});

  final Dispatch dispatch;
  final bool accepting;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final report = dispatch.report;
    final type = report?.reportType;
    final typeColor = colorFromHex(type?.color);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.xl, MedSpace.gutter, MedSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  liveRegion: true,
                  header: true,
                  child: const Text(
                    'Laporan darurat masuk',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: MedSpace.xs),
                Text(
                  formatDistance(dispatch.distanceKm),
                  key: const Key('offer-distance'),
                  style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900, height: 1.05),
                ),
                const Text('dari posisi ambulans Anda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: MedSpace.xl),
                Container(
                  padding: const EdgeInsets.all(MedSpace.lg),
                  decoration: BoxDecoration(color: MedColors.surface, borderRadius: BorderRadius.circular(MedRadius.lg)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ReportTypeTile(icon: reportTypeIcon(type?.icon, code: type?.code), color: typeColor, size: 52),
                          const SizedBox(width: MedSpace.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(report?.typeName ?? 'Laporan', style: Theme.of(context).textTheme.titleLarge),
                                Text(
                                  priorityLabel(type?.priority),
                                  style: TextStyle(color: (type?.priority ?? 9) <= 1 ? MedColors.brandDeep : MedColors.inkMuted, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: MedSpace.md),
                      if (report != null) InfoRow(icon: Icons.confirmation_number_outlined, label: 'Kode laporan', value: report.code),
                      InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Lokasi kejadian',
                        value: report?.address ?? report?.shortAddress ?? '-',
                      ),
                      if ((report?.description ?? '').isNotEmpty)
                        InfoRow(icon: Icons.notes_rounded, label: 'Deskripsi', value: report!.description!),
                      if (report?.destination?.name != null)
                        InfoRow(icon: Icons.flag_outlined, label: 'Tujuan antar', value: report!.destination!.name!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.sm, MedSpace.gutter, MedSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                button: true,
                label: accepting ? 'Menerima laporan, sedang diproses' : 'Terima laporan',
                excludeSemantics: true,
                child: FilledButton(
                  key: const Key('offer-accept'),
                  onPressed: accepting ? null : onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: MedColors.brandDeep,
                    disabledBackgroundColor: Colors.white70,
                    minimumSize: const Size.fromHeight(76),
                    textStyle: const TextStyle(fontFamily: 'Nunito', package: 'medrive_ui', fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
                  child: accepting
                      ? const SizedBox.square(dimension: 28, child: CircularProgressIndicator(strokeWidth: 3))
                      : const Text('TERIMA'),
                ),
              ),
              const SizedBox(height: MedSpace.sm),
              TextButton(
                key: const Key('offer-dismiss'),
                onPressed: accepting ? null : onDismiss,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Abaikan'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.onBack,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(MedSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(icon, size: 72, color: Colors.white),
            const SizedBox(height: MedSpace.lg),
            Semantics(
              liveRegion: true,
              child: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: MedSpace.sm),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const Spacer(),
            FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: MedColors.brandDeep),
              child: Text(primaryLabel),
            ),
            if (onBack != null) ...[
              const SizedBox(height: MedSpace.sm),
              TextButton(onPressed: onBack, style: TextButton.styleFrom(foregroundColor: Colors.white), child: const Text('Kembali')),
            ],
          ],
        ),
      );
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../services/permissions.dart';
import '../../state/driver_state.dart';
import '../../widgets/feedback.dart';

/// Penjelasan singkat izin sebelum shift pertama. Hasil `true` = izin lokasi siap.
Future<bool> ensureShiftPermissions(BuildContext context, WidgetRef ref) async {
  final gate = ref.read(permissionGateProvider);
  var status = await gate.check();
  if (status.allGranted) {
    return true;
  }
  if (!context.mounted) {
    return false;
  }

  final proceed = await showAppBottomSheet<bool>(
    context,
    title: 'Izin untuk shift',
    builder: (sheetContext) => _PermissionExplainer(status: status),
  );
  if (proceed != true) {
    return status.canOpenShift;
  }

  status = await gate.request();
  if (!status.canOpenShift && context.mounted) {
    final openSettings = await ConfirmDialog.show(
      context,
      title: status.locationServiceOn ? 'Izin lokasi ditolak' : 'GPS mati',
      message: status.locationServiceOn
          ? 'Shift tidak bisa dibuka tanpa izin lokasi, karena tawaran dikirim ke ambulans terdekat.'
          : 'Nyalakan GPS perangkat agar posisi ambulans bisa dikirim selama shift.',
      confirmLabel: 'Buka Pengaturan',
      icon: Icons.location_off_outlined,
    );
    if (openSettings) {
      await gate.openSettings(locationService: !status.locationServiceOn);
    }
  }
  return status.canOpenShift;
}

class _PermissionExplainer extends StatelessWidget {
  const _PermissionExplainer({required this.status});

  final ShiftPermissions status;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(MedSpace.gutter, 0, MedSpace.gutter, MedSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Reason(
                icon: Icons.my_location_rounded,
                title: 'Lokasi (wajib)',
                text: 'Posisi ambulans dikirim selama shift agar tawaran datang dari laporan terdekat.',
                granted: status.location && status.locationServiceOn,
              ),
              _Reason(
                icon: Icons.notifications_active_outlined,
                title: 'Notifikasi',
                text: 'Alarm tawaran tetap berbunyi saat layar terkunci.',
                granted: status.notifications,
              ),
              _Reason(
                icon: Icons.battery_charging_full_rounded,
                title: 'Abaikan optimasi baterai',
                text: 'Supaya Android tidak menghentikan pengiriman lokasi saat aplikasi di latar belakang.',
                granted: status.ignoreBatteryOptimizations,
              ),
              const SizedBox(height: MedSpace.lg),
              PrimaryButton(label: 'Izinkan', onPressed: () => Navigator.of(context).pop(true)),
              const SizedBox(height: MedSpace.sm),
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Nanti saja')),
            ],
          ),
        ),
      );
}

class _Reason extends StatelessWidget {
  const _Reason({required this.icon, required this.title, required this.text, required this.granted});

  final IconData icon;
  final String title;
  final String text;
  final bool granted;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: MedSpace.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: MedColors.brand),
            const SizedBox(width: MedSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  Text(text, style: const TextStyle(color: MedColors.inkMuted)),
                ],
              ),
            ),
            if (granted) const Icon(Icons.check_circle_rounded, color: MedColors.success, semanticLabel: 'Sudah diizinkan'),
          ],
        ),
      );
}

/// Ambulans tersedia di klinik driver (`GET /driver/ambulances/available`).
final availableAmbulancesProvider = FutureProvider.autoDispose<List<Ambulance>>(
  (ref) => ref.watch(driverRepositoryProvider).availableAmbulances(),
);

/// Bottom sheet pilih ambulans lalu buka shift. Hasil `true` = shift terbuka.
Future<bool> showOpenShiftSheet(BuildContext context) async =>
    await showAppBottomSheet<bool>(context, title: 'Pilih ambulans', builder: (_) => const _AmbulancePicker()) ?? false;

class _AmbulancePicker extends ConsumerStatefulWidget {
  const _AmbulancePicker();

  @override
  ConsumerState<_AmbulancePicker> createState() => _AmbulancePickerState();
}

class _AmbulancePickerState extends ConsumerState<_AmbulancePicker> {
  int? _selected;
  bool _opening = false;
  ApiError? _error;

  Future<void> _open() async {
    final id = _selected;
    if (id == null) {
      return;
    }
    setState(() {
      _opening = true;
      _error = null;
    });
    try {
      await ref.read(driverProvider.notifier).openShift(id);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      final apiError = asApiError(error);
      setState(() {
        _error = apiError;
        _opening = false;
        if (apiError.code == 'ambulance_in_use' || apiError.code == 'ambulance_unavailable') {
          _selected = null;
          ref.invalidate(availableAmbulancesProvider);
        }
      });
      if (apiError.code == 'shift_already_open') {
        unawaited(ref.read(driverProvider.notifier).refresh());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ambulances = ref.watch(availableAmbulancesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(MedSpace.gutter, 0, MedSpace.gutter, MedSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Hanya ambulans klinik Anda yang berstatus tersedia dan tidak sedang dipakai driver lain.',
              style: TextStyle(color: MedColors.inkMuted),
            ),
            const SizedBox(height: MedSpace.md),
            Flexible(
              child: ambulances.when(
                loading: () => const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [Skeleton(height: 72, radius: MedRadius.lg), SizedBox(height: MedSpace.sm), Skeleton(height: 72, radius: MedRadius.lg)],
                ),
                error: (error, _) => AsyncErrorView(error: error, onRetry: () => ref.invalidate(availableAmbulancesProvider)),
                data: (items) => items.isEmpty
                    ? EmptyState(
                        icon: Icons.local_shipping_outlined,
                        title: 'Tidak ada ambulans tersedia',
                        message: 'Semua ambulans klinik sedang dipakai atau dalam perawatan. Hubungi admin klinik.',
                        action: SizedBox(
                          width: 220,
                          child: SecondaryButton(
                            label: 'Muat ulang',
                            icon: Icons.refresh_rounded,
                            onPressed: () => ref.invalidate(availableAmbulancesProvider),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: MedSpace.sm),
                        itemBuilder: (context, index) => _AmbulanceTile(
                          ambulance: items[index],
                          selected: items[index].id == _selected,
                          onTap: _opening ? null : () => setState(() => _selected = items[index].id),
                        ),
                      ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: MedSpace.md),
              Text(_error!.message, key: const Key('open-shift-error'), style: const TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w800)),
            ],
            const SizedBox(height: MedSpace.lg),
            PrimaryButton(
              key: const Key('open-shift-submit'),
              label: 'Mulai Shift',
              icon: Icons.play_arrow_rounded,
              loading: _opening,
              onPressed: _selected == null ? null : _open,
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbulanceTile extends StatelessWidget {
  const _AmbulanceTile({required this.ambulance, required this.selected, required this.onTap});

  final Ambulance ambulance;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final details = [ambulance.vehicleName, ambulance.ambulanceType?.name, if (ambulance.year != null) '${ambulance.year}']
        .whereType<String>()
        .join(' · ');

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? MedColors.brandSoft : MedColors.surface,
        borderRadius: BorderRadius.circular(MedRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(MedRadius.lg),
          child: Ink(
            padding: const EdgeInsets.all(MedSpace.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(MedRadius.lg),
              border: Border.all(color: selected ? MedColors.brand : MedColors.line, width: selected ? 2 : 1),
            ),
            child: Row(
              children: [
                Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, color: selected ? MedColors.brand : MedColors.inkMuted),
                const SizedBox(width: MedSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ambulance.plateNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      if (details.isNotEmpty) Text(details, style: const TextStyle(color: MedColors.inkMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet alasan tutup shift (wajib di backend, 3-255 karakter). Hasil `true` = shift tertutup.
Future<bool> showCloseShiftSheet(BuildContext context) async =>
    await showAppBottomSheet<bool>(context, title: 'Tutup shift', builder: (_) => const _CloseShiftForm()) ?? false;

class _CloseShiftForm extends ConsumerStatefulWidget {
  const _CloseShiftForm();

  @override
  ConsumerState<_CloseShiftForm> createState() => _CloseShiftFormState();
}

class _CloseShiftFormState extends ConsumerState<_CloseShiftForm> {
  static const _presets = ['Jam shift selesai', 'Istirahat', 'Ambulans perlu perawatan'];
  static const _other = 'Lainnya';

  final _note = TextEditingController();
  String? _choice;
  bool _closing = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String get _reason => _choice == _other ? _note.text.trim() : (_choice ?? '');

  Future<void> _submit() async {
    final reason = _reason;
    if (reason.length < 3) {
      setState(() => _error = _choice == null ? 'Pilih alasan menutup shift.' : 'Tulis alasan minimal 3 karakter.');
      return;
    }
    setState(() {
      _closing = true;
      _error = null;
    });
    try {
      await ref.read(driverProvider.notifier).closeShift(reason);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = asApiError(error).message;
          _closing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(MedSpace.gutter, 0, MedSpace.gutter, MedSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Setelah shift ditutup, pengiriman lokasi berhenti dan Anda tidak menerima tawaran laporan.',
                style: TextStyle(color: MedColors.inkMuted),
              ),
              const SizedBox(height: MedSpace.lg),
              ChoiceGroup<String>(
                options: [for (final option in [..._presets, _other]) ChoiceOption(option, option)],
                value: _choice,
                onChanged: (value) => setState(() {
                  _choice = value;
                  _error = null;
                }),
              ),
              if (_choice == _other) ...[
                const SizedBox(height: MedSpace.md),
                MedTextField(
                  label: 'Alasan',
                  controller: _note,
                  maxLength: 255,
                  hint: 'Tulis alasan singkat',
                  onChanged: (_) => setState(() => _error = null),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: MedSpace.md),
                Text(_error!, style: const TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w800)),
              ],
              const SizedBox(height: MedSpace.lg),
              PrimaryButton(label: 'Tutup Shift', icon: Icons.stop_circle_outlined, loading: _closing, onPressed: _submit),
            ],
          ),
        ),
      );
}

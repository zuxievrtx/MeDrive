import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';
import 'package:uuid/uuid.dart';

import '../../router.dart';
import '../../state/session.dart';
import '../../widgets/feedback.dart';
import '../../widgets/photo_picker.dart';
import '../home/pickup_controller.dart';
import 'destination_picker.dart';
import 'report_form_data.dart';
import 'report_providers.dart';

/// Form laporan per jenis (satu template, field dinamis). Dikirim multipart dengan
/// Idempotency-Key yang tetap selama form terbuka, sehingga kirim ulang tidak membuat laporan ganda.
class ReportFormScreen extends ConsumerWidget {
  const ReportFormScreen({super.key, required this.typeCode});

  final String typeCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(reportTypeByCodeProvider(typeCode));

    return type.when(
      loading: () => Scaffold(appBar: AppBar(), body: const SkeletonList(count: 5)),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AsyncErrorView(error: error, onRetry: () => ref.invalidate(reportTypeByCodeProvider(typeCode))),
      ),
      data: (type) => _ReportForm(type: type),
    );
  }
}

class _ReportForm extends ConsumerStatefulWidget {
  const _ReportForm({required this.type});

  final ReportType type;

  @override
  ConsumerState<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends ConsumerState<_ReportForm> {
  final _data = ReportFormData();
  final _idempotencyKey = const Uuid().v4();
  final _scroll = ScrollController();
  Map<String, String> _errors = {};
  bool _submitting = false;
  bool _pickingPhoto = false;

  ReportType get _type => widget.type;

  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionProvider).user;
    if (_type.kind == ReportKind.funeral && user != null) {
      _data
        ..familyName = user.name
        ..familyPhone = user.phone;
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _update(VoidCallback change) => setState(() {
        change();
        _errors = {};
      });

  Future<void> _addPhoto({bool certificate = false}) async {
    setState(() => _pickingPhoto = true);
    try {
      final path = await ref.read(photoPickerProvider).pick(context);
      if (path != null) {
        _update(() => certificate ? _data.deathCertificatePath = path : _data.photos.add(path));
      }
    } catch (error) {
      if (mounted) {
        showMessage(context, 'Foto tidak bisa diambil. Periksa izin kamera/galeri.');
      }
    } finally {
      if (mounted) {
        setState(() => _pickingPhoto = false);
      }
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final pickup = ref.read(pickupProvider);
    final errors = _data.validate(_type);
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      showMessage(context, 'Periksa kembali isian yang ditandai.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final report = await ref.read(reportRepositoryProvider).create(
            _data.toDraft(
              type: _type,
              latitude: pickup.point.latitude,
              longitude: pickup.point.longitude,
              address: pickup.address,
            ),
            idempotencyKey: _idempotencyKey,
          );
      if (mounted) {
        context.pushReplacement(Routes.reportSuccess(report.id));
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      final apiError = asApiError(error);
      if (apiError.isValidation) {
        setState(() => _errors = {for (final entry in apiError.details.entries) entry.key: entry.value.first});
        showMessage(context, 'Periksa kembali isian yang ditandai.');
      } else {
        // Kirim ulang aman: kunci idempotensi sama, server tidak membuat laporan ganda.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiError.message),
            duration: const Duration(seconds: 8),
            action: SnackBarAction(label: 'Kirim ulang', onPressed: _submit),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String? _error(String key) => _errors[key];

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(_type.color);

    return LoadingOverlay(
      visible: _submitting,
      message: 'Mengirim laporan...',
      child: Scaffold(
        appBar: AppBar(
          title: Text('Laporan ${_type.name}'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: MedSpace.lg),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.14),
                child: Icon(reportTypeIcon(_type.icon, code: _type.code), color: color),
              ),
            ),
          ],
        ),
        body: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.sm, MedSpace.gutter, 120),
          children: [
            const _LocationSection(),
            const SizedBox(height: MedSpace.xl),
            ..._kindFields(),
            if (_type.requiresDestination) ...[
              const SizedBox(height: MedSpace.xl),
              _destinationField(),
            ],
            const SizedBox(height: MedSpace.xl),
            const SectionLabel(icon: Icons.description_outlined, title: 'Keterangan Tambahan', optional: true),
            TextField(
              maxLines: 4,
              maxLength: 500,
              onChanged: (value) => _data.description = value,
              decoration: InputDecoration(
                hintText: 'Contoh: korban di bahu jalan dekat halte, masih bernapas.',
                errorText: _error('description'),
              ),
            ),
            const SizedBox(height: MedSpace.lg),
            const SectionLabel(
              icon: Icons.photo_camera_outlined,
              title: 'Tambahkan Foto',
              optional: true,
              subtitle: 'Foto kondisi di lokasi membantu tim ambulans bersiap.',
            ),
            PhotoPickerGrid(
              paths: _data.photos,
              busy: _pickingPhoto,
              onAdd: _addPhoto,
              onRemove: (index) => _update(() => _data.photos.removeAt(index)),
            ),
            if (_error('photos') != null || _error('photos.0') != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_error('photos') ?? _error('photos.0')!, style: const TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.sm, MedSpace.gutter, MedSpace.md),
            child: PrimaryButton(
              key: const Key('report-submit'),
              label: 'Kirim Laporan',
              icon: Icons.send_rounded,
              loading: _submitting,
              onPressed: _submit,
            ),
          ),
        ),
      ),
    );
  }

  Widget _numberField(String label, String key, String value, ValueChanged<String> onChanged, {String? hint, String? suffix}) => TextFormField(
        initialValue: value,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (text) => _update(() => onChanged(text)),
        decoration: InputDecoration(labelText: label, hintText: hint, suffixText: suffix, errorText: _error(key)),
      );

  List<Widget> _kindFields() => switch (_type.kind) {
        ReportKind.accident => [
            const SectionLabel(icon: Icons.car_crash_outlined, title: 'Jenis Kecelakaan'),
            ChoiceGroup<String>(
              options: ReportOptions.accidentTypes,
              value: _data.accidentType,
              errorText: _error('details.accident_type'),
              onChanged: (value) => _update(() => _data.accidentType = value),
            ),
            const SizedBox(height: MedSpace.xl),
            const SectionLabel(icon: Icons.groups_outlined, title: 'Jumlah Korban', optional: true),
            _numberField('Perkiraan jumlah korban', 'details.estimated_victim_count', _data.victimCount, (value) => _data.victimCount = value, hint: 'Contoh: 1'),
            const SizedBox(height: MedSpace.xl),
            const SectionLabel(icon: Icons.warning_amber_rounded, title: 'Kondisi di Lokasi'),
            YesNoTile(label: 'Ada korban terjepit', value: _data.trappedVictim, onChanged: (value) => _update(() => _data.trappedVictim = value)),
            const SizedBox(height: MedSpace.sm),
            YesNoTile(label: 'Ada potensi api / kebakaran', value: _data.fireHazard, onChanged: (value) => _update(() => _data.fireHazard = value)),
            const SizedBox(height: MedSpace.sm),
            YesNoTile(label: 'Jalan tertutup', value: _data.roadBlocked, onChanged: (value) => _update(() => _data.roadBlocked = value)),
          ],
        ReportKind.medical => [
            const SectionLabel(icon: Icons.monitor_heart_outlined, title: 'Kondisi Pasien'),
            ChoiceGroup<String>(
              options: ReportOptions.medicalCategories,
              value: _data.medicalCategory,
              errorText: _error('details.medical_category'),
              onChanged: (value) => _update(() => _data.medicalCategory = value),
            ),
            const SizedBox(height: MedSpace.xl),
            const SectionLabel(icon: Icons.schedule_rounded, title: 'Gejala Mulai', optional: true),
            ChoiceGroup<int?>(
              options: ReportOptions.symptomOnset,
              value: _data.symptomOnsetMinutes,
              errorText: _error('details.symptom_onset_at'),
              onChanged: (value) => _update(() => _data.symptomOnsetMinutes = value),
            ),
            const SizedBox(height: MedSpace.xl),
            YesNoTile(
              label: 'Punya riwayat penyakit',
              value: _data.hasMedicalHistory,
              onChanged: (value) => _update(() => _data.hasMedicalHistory = value),
            ),
            if (_data.hasMedicalHistory) ...[
              const SizedBox(height: MedSpace.sm),
              TextFormField(
                initialValue: _data.medicalHistoryNotes,
                maxLength: 255,
                onChanged: (value) => _data.medicalHistoryNotes = value,
                decoration: InputDecoration(
                  labelText: 'Riwayat penyakit',
                  hintText: 'Contoh: hipertensi, diabetes',
                  errorText: _error('details.medical_history_notes'),
                ),
              ),
            ],
          ],
        ReportKind.maternity => [
            const SectionLabel(icon: Icons.pregnant_woman_rounded, title: 'Kondisi Ibu Hamil'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _numberField('Usia kehamilan', 'details.gestational_age_weeks', _data.gestationalWeeks, (value) => _data.gestationalWeeks = value, suffix: 'minggu'),
                ),
                const SizedBox(width: MedSpace.md),
                Expanded(
                  child: _numberField('Kehamilan ke-', 'details.pregnancy_number', _data.pregnancyNumber, (value) => _data.pregnancyNumber = value),
                ),
              ],
            ),
            const SizedBox(height: MedSpace.md),
            _numberField(
              'Jarak antar kontraksi',
              'details.contraction_interval_minutes',
              _data.contractionMinutes,
              (value) => _data.contractionMinutes = value,
              suffix: 'menit',
              hint: 'Kosongkan bila belum kontraksi',
            ),
            const SizedBox(height: MedSpace.md),
            YesNoTile(label: 'Ketuban sudah pecah', value: _data.waterBroken, onChanged: (value) => _update(() => _data.waterBroken = value)),
            const SizedBox(height: MedSpace.sm),
            YesNoTile(label: 'Ada perdarahan', value: _data.bleeding, onChanged: (value) => _update(() => _data.bleeding = value)),
          ],
        ReportKind.funeral => [
            const SectionLabel(icon: Icons.person_outline_rounded, title: 'Data Jenazah'),
            TextFormField(
              initialValue: _data.deceasedName,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) => _update(() => _data.deceasedName = value),
              decoration: InputDecoration(labelText: 'Nama almarhum/almarhumah', errorText: _error('details.deceased_name')),
            ),
            const SizedBox(height: MedSpace.lg),
            const SectionLabel(icon: Icons.place_outlined, title: 'Tempat Penjemputan'),
            ChoiceGroup<String>(
              options: ReportOptions.pickupPlaces,
              value: _data.pickupPlace,
              errorText: _error('details.pickup_place_type'),
              onChanged: (value) => _update(() => _data.pickupPlace = value),
            ),
            const SizedBox(height: MedSpace.xl),
            const SectionLabel(icon: Icons.event_outlined, title: 'Jadwal Penjemputan'),
            _ScheduleField(
              value: _data.scheduledPickup,
              errorText: _error('details.scheduled_pickup_at'),
              onChanged: (value) => _update(() => _data.scheduledPickup = value),
            ),
            const SizedBox(height: MedSpace.xl),
            YesNoTile(
              label: 'Surat kematian sudah ada',
              value: _data.hasDeathCertificate,
              onChanged: (value) => _update(() => _data.hasDeathCertificate = value),
            ),
            if (_data.hasDeathCertificate) ...[
              const SizedBox(height: MedSpace.sm),
              OutlinedButton.icon(
                onPressed: _pickingPhoto ? null : () => _addPhoto(certificate: true),
                icon: Icon(_data.deathCertificatePath == null ? Icons.upload_file_rounded : Icons.check_circle_rounded),
                label: Text(_data.deathCertificatePath == null ? 'Foto surat kematian (opsional)' : 'Surat kematian terlampir'),
              ),
            ],
            const SizedBox(height: MedSpace.xl),
            const SectionLabel(icon: Icons.contact_phone_outlined, title: 'Kontak Keluarga'),
            TextFormField(
              initialValue: _data.familyName,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) => _update(() => _data.familyName = value),
              decoration: InputDecoration(labelText: 'Nama', errorText: _error('details.family_contact_name')),
            ),
            const SizedBox(height: MedSpace.md),
            TextFormField(
              initialValue: _data.familyPhone,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]'))],
              onChanged: (value) => _update(() => _data.familyPhone = value),
              decoration: InputDecoration(labelText: 'Nomor telepon', errorText: _error('details.family_contact_phone')),
            ),
          ],
        ReportKind.unknown => const [],
      };

  Widget _destinationField() {
    final destination = _data.destination;
    final error = _error('destination') ?? _error('destination_clinic_id') ?? _error('destination_name') ?? _error('destination_lat');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(
          icon: Icons.local_hospital_outlined,
          title: 'Tujuan Antar',
          subtitle: _type.kind == ReportKind.maternity ? 'Faskes tempat ibu akan dibawa.' : 'Ke mana jenazah diantar.',
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: MedSpace.lg, vertical: MedSpace.md),
          onTap: () async {
            final choice = await showDestinationPicker(context);
            if (choice != null) {
              _update(() => _data.destination = choice);
            }
          },
          child: Row(
            children: [
              Icon(destination == null ? Icons.add_location_alt_outlined : Icons.local_hospital_rounded, color: MedColors.brand),
              const SizedBox(width: MedSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(destination?.title ?? 'Pilih faskes atau alamat tujuan', style: Theme.of(context).textTheme.titleSmall),
                    if (destination?.subtitle != null)
                      Text(destination!.subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: MedColors.inkMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(error, style: const TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }
}

/// Peta kecil titik jemput + alamat (Figma bagian "Lokasi"). Ketuk untuk mengubah titik.
class _LocationSection extends ConsumerWidget {
  const _LocationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickup = ref.watch(pickupProvider);

    Future<void> change() async {
      await context.push<bool>(Routes.pickLocation);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(icon: Icons.my_location_rounded, title: 'Lokasi Jemput'),
        ClipRRect(
          borderRadius: BorderRadius.circular(MedRadius.lg),
          child: SizedBox(
            height: 140,
            child: Stack(
              children: [
                MedMapView(
                  key: ValueKey(pickup.point),
                  initialCenter: pickup.point,
                  initialZoom: 16,
                  interactive: false,
                  showControls: false,
                  markers: [
                    Marker(
                      point: pickup.point,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: const PickupPin(size: 44),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(onTap: change, child: const SizedBox.expand()),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: MedSpace.sm),
        Material(
          color: MedColors.field,
          borderRadius: BorderRadius.circular(MedRadius.md),
          child: ListTile(
            onTap: change,
            minTileHeight: 52,
            leading: const Icon(Icons.location_on_rounded, color: MedColors.brand),
            title: Text(
              pickup.resolving ? 'Mencari alamat...' : (pickup.address ?? 'Titik di peta'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),
      ],
    );
  }
}

/// Jadwal jemput jenazah: "Secepatnya" (kosong) atau tanggal + jam tertentu.
class _ScheduleField extends StatelessWidget {
  const _ScheduleField({required this.value, required this.onChanged, this.errorText});

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? errorText;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      initialDate: value ?? now,
    );
    if (date == null || !context.mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value ?? now.add(const Duration(hours: 1))),
    );
    if (time == null) {
      return;
    }
    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    onChanged(picked.isBefore(now) ? now.add(const Duration(minutes: 5)) : picked);
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MedSpace.sm,
            runSpacing: MedSpace.sm,
            children: [
              ChoiceChip(label: const Text('Secepatnya'), selected: value == null, onSelected: (_) => onChanged(null)),
              ChoiceChip(
                label: Text(value == null ? 'Pilih jadwal' : formatDateTime(value)),
                selected: value != null,
                onSelected: (_) => unawaited(_pick(context)),
              ),
            ],
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(errorText!, style: const TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w700)),
            ),
        ],
      );
}

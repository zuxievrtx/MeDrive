import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../widgets/feedback.dart';
import 'mission_state.dart';

/// Form pasien & serah terima: pasien dari laporan pelapor bisa dilengkapi, pasien baru di TKP
/// bisa ditambah. "Diserahkan kepada" setiap pasien wajib diisi sebelum laporan diselesaikan.
class PatientsScreen extends ConsumerWidget {
  const PatientsScreen({super.key, required this.reportId});

  final int reportId;

  Future<void> _edit(BuildContext context, Report report, {ReportPatient? patient}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PatientForm(reportId: reportId, patient: patient, number: patient == null ? report.patients.length + 1 : null),
    );
    if ((saved ?? false) && context.mounted) {
      showMessage(context, 'Data pasien tersimpan.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mission = ref.watch(missionProvider(reportId));

    return Scaffold(
      appBar: AppBar(title: const Text('Pasien & Serah Terima')),
      floatingActionButton: mission.value?.isActive ?? false
          ? FloatingActionButton.extended(
              key: const Key('patients-add'),
              onPressed: () => _edit(context, mission.value!),
              backgroundColor: MedColors.brand,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Tambah pasien', style: TextStyle(fontWeight: FontWeight.w800)),
            )
          : null,
      body: mission.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const SkeletonList(count: 2, itemHeight: 130),
        error: (error, _) => AsyncErrorView(error: error, onRetry: () => ref.invalidate(missionProvider(reportId))),
        data: (report) {
          if (report.patients.isEmpty) {
            return const EmptyState(
              icon: Icons.assignment_ind_outlined,
              title: 'Belum ada data pasien',
              message: 'Pelapor tidak mengisi data pasien. Tambahkan pasien yang Anda tangani di lokasi, '
                  'termasuk siapa yang menerima serah terimanya.',
            );
          }
          final missing = report.patients.where((patient) => (patient.handedOverTo ?? '').trim().isEmpty).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.md, MedSpace.gutter, 96),
            children: [
              _HandoverSummary(total: report.patients.length, missing: missing),
              const SizedBox(height: MedSpace.md),
              for (var index = 0; index < report.patients.length; index++) ...[
                _PatientCard(
                  number: index + 1,
                  patient: report.patients[index],
                  onTap: report.isActive ? () => _edit(context, report, patient: report.patients[index]) : null,
                ),
                const SizedBox(height: MedSpace.md),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HandoverSummary extends StatelessWidget {
  const _HandoverSummary({required this.total, required this.missing});

  final int total;
  final int missing;

  @override
  Widget build(BuildContext context) {
    final complete = missing == 0;
    final color = complete ? MedColors.success : MedColors.warning;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(MedSpace.md),
        decoration: BoxDecoration(
          color: complete ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(MedRadius.md),
        ),
        child: Row(
          children: [
            Icon(complete ? Icons.verified_user_outlined : Icons.pending_actions_rounded, color: color),
            const SizedBox(width: MedSpace.md),
            Expanded(
              child: Text(
                complete ? 'Serah terima $total pasien lengkap.' : '$missing dari $total pasien belum diserahterimakan.',
                style: TextStyle(color: complete ? const Color(0xFF166534) : const Color(0xFF92400E), fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.number, required this.patient, required this.onTap});

  final int number;
  final ReportPatient patient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final handedOver = (patient.handedOverTo ?? '').trim().isNotEmpty;
    final facts = [
      if (patient.gender != null) patient.gender == 'L' ? 'Laki-laki' : 'Perempuan',
      if (patient.ageEstimate != null) '±${patient.ageEstimate} tahun',
      if (patient.consciousness != null) patient.consciousness!.label,
      if (patient.isBreathing != null) patient.isBreathing! ? 'Bernapas' : 'Tidak bernapas',
    ];

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (patient.name ?? '').isEmpty ? 'Pasien $number' : patient.name!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (onTap != null) const Icon(Icons.edit_outlined, color: MedColors.inkMuted, semanticLabel: 'Ubah'),
            ],
          ),
          if (facts.isNotEmpty) Text(facts.join(' · '), style: const TextStyle(color: MedColors.inkMuted)),
          if ((patient.conditionNote ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(patient.conditionNote!),
          ],
          const SizedBox(height: MedSpace.sm),
          Row(
            children: [
              Icon(handedOver ? Icons.check_circle_rounded : Icons.error_outline_rounded, size: 18, color: handedOver ? MedColors.success : MedColors.warning),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  handedOver
                      ? 'Diserahkan kepada ${patient.handedOverTo} · ${formatDateTime(patient.handedOverAt)}'
                      : 'Belum diserahterimakan',
                  style: TextStyle(fontWeight: FontWeight.w800, color: handedOver ? MedColors.ink : const Color(0xFF92400E)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatientForm extends ConsumerStatefulWidget {
  const _PatientForm({required this.reportId, this.patient, this.number});

  final int reportId;
  final ReportPatient? patient;
  final int? number;

  @override
  ConsumerState<_PatientForm> createState() => _PatientFormState();
}

class _PatientFormState extends ConsumerState<_PatientForm> {
  late final _name = TextEditingController(text: widget.patient?.name);
  late final _age = TextEditingController(text: widget.patient?.ageEstimate?.toString());
  late final _condition = TextEditingController(text: widget.patient?.conditionNote);
  late final _handedTo = TextEditingController(text: widget.patient?.handedOverTo);
  late String? _gender = widget.patient?.gender;
  late String? _consciousness = widget.patient?.consciousness?.value;
  late bool? _breathing = widget.patient?.isBreathing;
  late DateTime? _handedAt = widget.patient?.handedOverAt;
  bool _saving = false;
  ApiError? _error;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _condition.dispose();
    _handedTo.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final initial = _handedAt?.toLocal() ?? now;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial), helpText: 'Waktu serah terima');
    if (time == null) {
      return;
    }
    var picked = DateTime(initial.year, initial.month, initial.day, time.hour, time.minute);
    if (picked.isAfter(now)) {
      // Backend menolak waktu di masa depan; jam yang lebih besar berarti kemarin.
      picked = picked.subtract(const Duration(days: 1));
    }
    setState(() => _handedAt = picked);
  }

  Future<void> _save() async {
    final handedTo = _handedTo.text.trim();
    final handedAt = handedTo.isEmpty ? _handedAt : (_handedAt ?? DateTime.now());
    final input = PatientInput(
      name: _name.text,
      gender: _gender,
      ageEstimate: int.tryParse(_age.text.trim()),
      consciousness: _consciousness,
      isBreathing: _breathing,
      conditionNote: _condition.text,
      handedOverTo: handedTo,
      handedOverAt: handedAt,
    );

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(missionProvider(widget.reportId).notifier).savePatient(input, patientId: widget.patient?.id);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = asApiError(error);
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.patient == null ? 'Pasien baru ${widget.number ?? ''}'.trim() : 'Ubah data pasien';
    final general = _error != null && !_error!.isValidation ? _error!.message : null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(MedSpace.gutter, 0, MedSpace.gutter, MedSpace.sm),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.sm, MedSpace.gutter, MedSpace.lg),
                children: [
                  MedTextField(label: 'Nama pasien', optional: true, controller: _name, maxLength: 100, errorText: _error?.fieldError('name')),
                  const SizedBox(height: MedSpace.md),
                  const SectionLabel(icon: Icons.wc_rounded, title: 'Jenis kelamin', optional: true),
                  ChoiceGroup<String>(
                    options: const [ChoiceOption('L', 'Laki-laki'), ChoiceOption('P', 'Perempuan')],
                    value: _gender,
                    onChanged: (value) => setState(() => _gender = _gender == value ? null : value),
                  ),
                  const SizedBox(height: MedSpace.lg),
                  MedTextField(
                    label: 'Perkiraan usia (tahun)',
                    optional: true,
                    controller: _age,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                    errorText: _error?.fieldError('age_estimate'),
                  ),
                  const SizedBox(height: MedSpace.lg),
                  const SectionLabel(icon: Icons.psychology_alt_outlined, title: 'Kesadaran'),
                  ChoiceGroup<String>(
                    options: const [
                      ChoiceOption('sadar', 'Sadar'),
                      ChoiceOption('tidak_sadar', 'Tidak sadar'),
                      ChoiceOption('tidak_diketahui', 'Tidak diketahui'),
                    ],
                    value: _consciousness,
                    onChanged: (value) => setState(() => _consciousness = value),
                    errorText: _error?.fieldError('consciousness'),
                  ),
                  const SizedBox(height: MedSpace.lg),
                  const SectionLabel(icon: Icons.air_rounded, title: 'Napas'),
                  ChoiceGroup<bool>(
                    options: const [ChoiceOption(true, 'Bernapas'), ChoiceOption(false, 'Tidak bernapas')],
                    value: _breathing,
                    onChanged: (value) => setState(() => _breathing = value),
                  ),
                  const SizedBox(height: MedSpace.lg),
                  MedTextField(
                    label: 'Kondisi',
                    optional: true,
                    controller: _condition,
                    maxLines: 3,
                    maxLength: 255,
                    hint: 'Luka, tindakan yang sudah diberikan, dsb.',
                    errorText: _error?.fieldError('condition_note'),
                  ),
                  const SizedBox(height: MedSpace.md),
                  const Divider(),
                  const SizedBox(height: MedSpace.md),
                  Text('Serah terima', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: MedSpace.sm),
                  MedTextField(
                    key: const Key('patient-handed-to'),
                    label: 'Diserahkan kepada',
                    controller: _handedTo,
                    maxLength: 150,
                    hint: 'Nama petugas IGD / keluarga penerima',
                    helperText: 'Wajib diisi sebelum laporan diselesaikan.',
                    errorText: _error?.fieldError('handed_over_to'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: MedSpace.sm),
                  OutlinedButton.icon(
                    onPressed: _pickTime,
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    icon: const Icon(Icons.schedule_rounded),
                    label: Text(
                      _handedAt != null
                          ? 'Waktu serah terima: ${formatDateTime(_handedAt)}'
                          : _handedTo.text.trim().isEmpty
                              ? 'Atur waktu serah terima'
                              : 'Waktu serah terima: saat disimpan',
                    ),
                  ),
                  if (_error?.fieldError('handed_over_at') != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(_error!.fieldError('handed_over_at')!, style: const TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w700)),
                    ),
                  if (general != null) ...[
                    const SizedBox(height: MedSpace.md),
                    Text(general, style: const TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w800)),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.sm, MedSpace.gutter, MedSpace.md),
                child: PrimaryButton(key: const Key('patient-save'), label: 'Simpan pasien', loading: _saving, onPressed: () => unawaited(_save())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

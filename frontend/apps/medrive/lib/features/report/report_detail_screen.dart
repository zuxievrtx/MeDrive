import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../router.dart';
import '../../widgets/feedback.dart';
import '../../widgets/media.dart';
import 'report_providers.dart';

/// Detail laporan: status, riwayat status, detail jenis, pasien, lampiran, driver.
/// Pelapor tidak bisa membatalkan laporan (pembatalan hanya oleh admin pusat).
class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final int reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(reportDetailProvider(reportId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan')),
      body: report.when(
        loading: () => const SkeletonList(count: 4, itemHeight: 140),
        error: (error, _) => AsyncErrorView(error: error, onRetry: () => ref.invalidate(reportDetailProvider(reportId))),
        data: (report) => RefreshIndicator(
          onRefresh: () => ref.refresh(reportDetailProvider(reportId).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.sm, MedSpace.gutter, MedSpace.xxl),
            children: [
              _Header(report: report),
              if (!report.isClosed) ...[
                const SizedBox(height: MedSpace.lg),
                PrimaryButton(
                  label: report.isWaiting ? 'Pantau pencarian ambulans' : 'Lacak Ambulans',
                  icon: Icons.near_me_rounded,
                  onPressed: () => context.push(Routes.tracking(report.id)),
                ),
              ],
              if (report.driver != null) ...[
                const SizedBox(height: MedSpace.xl),
                _DriverCard(report: report),
              ],
              const SizedBox(height: MedSpace.xl),
              _Timeline(report: report),
              const SizedBox(height: MedSpace.xl),
              _Details(report: report),
              if (report.patients.isNotEmpty) ...[
                const SizedBox(height: MedSpace.xl),
                _Patients(patients: report.patients),
              ],
              if (report.attachments.isNotEmpty) ...[
                const SizedBox(height: MedSpace.xl),
                _Attachments(attachments: report.attachments),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: MedSpace.sm),
          child,
        ],
      );
}

class _Header extends StatelessWidget {
  const _Header({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final type = report.reportType;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReportTypeTile(icon: reportTypeIcon(type?.icon, code: type?.code), color: colorFromHex(type?.color)),
              const SizedBox(width: MedSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.typeName, style: Theme.of(context).textTheme.titleLarge),
                    SelectableText(report.code, style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: MedSpace.md),
          StatusBadge(status: report.statusValue, label: report.status.label, large: true),
          const SizedBox(height: MedSpace.md),
          InfoRow(label: 'Dibuat', value: formatDateTime(report.createdAt), icon: Icons.schedule_rounded),
          InfoRow(label: 'Lokasi jemput', value: report.address ?? '${report.latitude}, ${report.longitude}', icon: Icons.location_on_outlined),
          if (report.destination != null)
            InfoRow(
              label: 'Tujuan antar',
              value: [report.destination!.name, report.destination!.address].whereType<String>().join(' · '),
              icon: Icons.flag_outlined,
            ),
          if (report.description != null && report.description!.isNotEmpty)
            InfoRow(label: 'Keterangan', value: report.description!, icon: Icons.notes_rounded),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final driver = report.driver!;
    final ambulance = report.ambulance;

    return _Section(
      title: 'Driver & Ambulans',
      child: AppCard(
        child: Row(
          children: [
            DriverAvatar(name: driver.name, photoUrl: driver.photoUrl),
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
                      [ambulance.plateNumber, ambulance.type, ambulance.vehicleName].whereType<String>().join(' · '),
                      style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w700),
                    ),
                  if (driver.clinic != null) Text(driver.clinic!, style: const TextStyle(color: MedColors.inkMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) => _Section(
        title: 'Riwayat Status',
        child: report.timeline.isEmpty
            ? const Text('Belum ada riwayat status.', style: TextStyle(color: MedColors.inkMuted))
            : Column(
                children: [
                  for (var index = 0; index < report.timeline.length; index++)
                    _TimelineItem(log: report.timeline[index], isLast: index == report.timeline.length - 1),
                ],
              ),
      );
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.log, required this.isLast});

  final ReportStatusLog log;
  final bool isLast;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isLast ? MedColors.brand : MedColors.line,
                      shape: BoxShape.circle,
                      border: Border.all(color: isLast ? MedColors.brandSoft : MedColors.surface, width: 3),
                    ),
                  ),
                  if (!isLast) const Expanded(child: VerticalDivider(width: 2, thickness: 2)),
                ],
              ),
            ),
            const SizedBox(width: MedSpace.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: MedSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusBadge(status: log.toStatus.value, label: log.toStatus.label),
                    const SizedBox(height: 4),
                    Text(formatDateTime(log.createdAt), style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w700)),
                    if (log.note != null && log.note!.isNotEmpty) Text(log.note!),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _Details extends StatelessWidget {
  const _Details({required this.report});

  final Report report;

  String _yesNo(bool? value) => value == null ? 'Tidak diketahui' : (value ? 'Ya' : 'Tidak');

  @override
  Widget build(BuildContext context) {
    final rows = switch (report.details) {
      AccidentDetails(:final accidentType, :final estimatedVictimCount, :final hasTrappedVictim, :final hasFireHazard, :final isRoadBlocked) => [
          InfoRow(label: 'Jenis kecelakaan', value: accidentType?.label ?? '-'),
          InfoRow(label: 'Perkiraan korban', value: estimatedVictimCount == null ? 'Tidak diketahui' : '$estimatedVictimCount orang'),
          InfoRow(label: 'Korban terjepit', value: _yesNo(hasTrappedVictim)),
          InfoRow(label: 'Potensi api', value: _yesNo(hasFireHazard)),
          InfoRow(label: 'Jalan tertutup', value: _yesNo(isRoadBlocked)),
        ],
      MedicalDetails(:final medicalCategory, :final symptomOnsetAt, :final hasMedicalHistory, :final medicalHistoryNotes) => [
          InfoRow(label: 'Kondisi', value: medicalCategory?.label ?? '-'),
          InfoRow(label: 'Gejala mulai', value: symptomOnsetAt == null ? 'Tidak diketahui' : formatDateTime(symptomOnsetAt)),
          InfoRow(
            label: 'Riwayat penyakit',
            value: hasMedicalHistory == true ? (medicalHistoryNotes?.isNotEmpty == true ? medicalHistoryNotes! : 'Ada') : _yesNo(hasMedicalHistory),
          ),
        ],
      MaternityDetails(:final gestationalAgeWeeks, :final contractionIntervalMinutes, :final isWaterBroken, :final hasBleeding, :final pregnancyNumber, :final destinationClinic) => [
          InfoRow(label: 'Usia kehamilan', value: gestationalAgeWeeks == null ? '-' : '$gestationalAgeWeeks minggu'),
          InfoRow(label: 'Jarak kontraksi', value: contractionIntervalMinutes == null ? '-' : 'tiap $contractionIntervalMinutes menit'),
          InfoRow(label: 'Ketuban pecah', value: _yesNo(isWaterBroken)),
          InfoRow(label: 'Perdarahan', value: _yesNo(hasBleeding)),
          InfoRow(label: 'Kehamilan ke-', value: pregnancyNumber?.toString() ?? '-'),
          if (destinationClinic != null) InfoRow(label: 'Faskes tujuan', value: destinationClinic.name),
        ],
      FuneralDetails(:final deceasedName, :final pickupPlaceType, :final scheduledPickupAt, :final hasDeathCertificate, :final familyContactName, :final familyContactPhone) => [
          InfoRow(label: 'Nama almarhum/almarhumah', value: deceasedName ?? '-'),
          InfoRow(label: 'Tempat jemput', value: pickupPlaceType?.label ?? '-'),
          InfoRow(label: 'Jadwal jemput', value: scheduledPickupAt == null ? 'Secepatnya' : formatDateTime(scheduledPickupAt)),
          InfoRow(label: 'Surat kematian', value: hasDeathCertificate == true ? 'Ada' : 'Belum ada'),
          InfoRow(label: 'Kontak keluarga', value: [familyContactName, familyContactPhone].whereType<String>().join(' · ')),
        ],
      _ => const <Widget>[Text('Belum ada detail tambahan.', style: TextStyle(color: MedColors.inkMuted))],
    };

    return _Section(
      title: 'Detail ${report.typeName}',
      child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows)),
    );
  }
}

class _Patients extends StatelessWidget {
  const _Patients({required this.patients});

  final List<ReportPatient> patients;

  @override
  Widget build(BuildContext context) => _Section(
        title: 'Pasien',
        child: Column(
          children: [
            for (final patient in patients)
              Padding(
                padding: const EdgeInsets.only(bottom: MedSpace.sm),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        [
                          patient.name ?? 'Tanpa nama',
                          if (patient.gender != null) patient.gender == 'L' ? 'Laki-laki' : 'Perempuan',
                          if (patient.ageEstimate != null) '± ${patient.ageEstimate} tahun',
                        ].join(' · '),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (patient.consciousness != null) InfoRow(label: 'Kesadaran', value: patient.consciousness!.label),
                      if (patient.conditionNote != null) InfoRow(label: 'Kondisi', value: patient.conditionNote!),
                      if (patient.handedOverTo != null)
                        InfoRow(label: 'Diserahkan ke', value: '${patient.handedOverTo} · ${formatDateTime(patient.handedOverAt)}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
}

class _Attachments extends StatelessWidget {
  const _Attachments({required this.attachments});

  final List<ReportAttachment> attachments;

  @override
  Widget build(BuildContext context) => _Section(
        title: 'Lampiran',
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: MedSpace.sm,
          crossAxisSpacing: MedSpace.sm,
          children: [
            for (final attachment in attachments)
              Semantics(
                button: true,
                label: 'Buka ${attachment.type.label}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(MedRadius.md),
                  onTap: attachment.isImage ? () => showImageViewer(context, attachment.url, caption: attachment.type.label) : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(MedRadius.md),
                    child: attachment.isImage
                        ? AuthImage(url: attachment.url)
                        : ColoredBox(
                            color: MedColors.field,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.description_outlined, color: MedColors.inkMuted),
                                  Text(attachment.type.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      );
}

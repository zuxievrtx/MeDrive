import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../router.dart';
import '../../widgets/feedback.dart';
import '../chat/chat_providers.dart';

/// Ringkasan laporan yang pernah ditangani: waktu, lokasi, pasien & serah terima, jumlah foto,
/// dan linimasa status.
class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({super.key, required this.reportId});

  final int reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(chatReportProvider(reportId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail laporan')),
      body: report.when(
        loading: () => const SkeletonList(count: 3, itemHeight: 110),
        error: (error, _) => AsyncErrorView(error: error, onRetry: () => ref.invalidate(chatReportProvider(reportId))),
        data: (report) {
          final type = report.reportType;
          final photos = report.attachments.where((item) => item.type.value == 'foto_penanganan').length;

          return ListView(
            padding: const EdgeInsets.all(MedSpace.gutter),
            children: [
              Row(
                children: [
                  ReportTypeTile(icon: reportTypeIcon(type?.icon, code: type?.code), color: colorFromHex(type?.color), size: 52),
                  const SizedBox(width: MedSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report.typeName, style: Theme.of(context).textTheme.titleLarge),
                        SelectableText(report.code, style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  StatusBadge(status: report.statusValue, label: report.status.label, large: true),
                ],
              ),
              const SizedBox(height: MedSpace.lg),
              InfoRow(icon: Icons.location_on_outlined, label: 'Alamat kejadian', value: report.address ?? report.shortAddress ?? '-'),
              if (report.destination?.name != null)
                InfoRow(icon: Icons.flag_outlined, label: 'Tujuan antar', value: report.destination!.name!),
              if (report.reporter != null) InfoRow(icon: Icons.person_outline_rounded, label: 'Pelapor', value: report.reporter!.name),
              if (report.ambulance != null)
                InfoRow(icon: Icons.airport_shuttle_outlined, label: 'Ambulans', value: report.ambulance!.plateNumber),
              InfoRow(icon: Icons.schedule_rounded, label: 'Diambil', value: formatDateTime(report.takenAt)),
              InfoRow(icon: Icons.place_outlined, label: 'Tiba di lokasi', value: formatDateTime(report.arrivedAt)),
              InfoRow(icon: Icons.check_circle_outline_rounded, label: 'Selesai', value: formatDateTime(report.completedAt)),
              const SizedBox(height: MedSpace.lg),
              Text('Pasien (${report.patients.length})', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: MedSpace.sm),
              if (report.patients.isEmpty)
                const Text('Tidak ada data pasien.', style: TextStyle(color: MedColors.inkMuted))
              else
                for (var index = 0; index < report.patients.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: MedSpace.sm),
                    child: Text(
                      '${(report.patients[index].name ?? '').isEmpty ? 'Pasien ${index + 1}' : report.patients[index].name}: '
                      '${(report.patients[index].handedOverTo ?? '').isEmpty ? 'belum diserahterimakan' : 'diserahkan kepada ${report.patients[index].handedOverTo}'}',
                    ),
                  ),
              const SizedBox(height: MedSpace.sm),
              Text('Foto penanganan: $photos', style: const TextStyle(fontWeight: FontWeight.w700)),
              if (report.timeline.isNotEmpty) ...[
                const SizedBox(height: MedSpace.lg),
                Text('Linimasa', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: MedSpace.sm),
                for (final log in report.timeline)
                  Padding(
                    padding: const EdgeInsets.only(bottom: MedSpace.sm),
                    child: Row(
                      children: [
                        SizedBox(width: 56, child: Text(formatTime(log.createdAt), style: const TextStyle(fontWeight: FontWeight.w800))),
                        StatusBadge(status: log.toStatus.value, label: log.toStatus.label),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: MedSpace.lg),
              SecondaryButton(
                label: 'Lihat riwayat chat',
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: () => context.push(Routes.chat(report.id)),
              ),
            ],
          );
        },
      ),
    );
  }
}

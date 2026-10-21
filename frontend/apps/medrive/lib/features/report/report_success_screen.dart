import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../router.dart';
import '../../widgets/feedback.dart';
import 'report_providers.dart';

/// Laporan terkirim: kode MDR besar (untuk disebutkan bila menelepon admin) dan tombol lacak.
class ReportSuccessScreen extends ConsumerWidget {
  const ReportSuccessScreen({super.key, required this.reportId});

  final int reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(reportDetailProvider(reportId));

    return Scaffold(
      body: SafeArea(
        child: report.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AsyncErrorView(error: error, onRetry: () => ref.invalidate(reportDetailProvider(reportId))),
          data: (report) => Padding(
            padding: const EdgeInsets.all(MedSpace.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(color: MedColors.brandSoft, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, size: 56, color: MedColors.brand),
                  ),
                ),
                const SizedBox(height: MedSpace.xl),
                Text('Laporan terkirim', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: MedSpace.sm),
                Text(
                  'Kami sedang mencari ambulans terdekat. Tetap di lokasi dan aktifkan nada dering ponsel Anda.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MedColors.inkMuted),
                ),
                const SizedBox(height: MedSpace.xl),
                AppCard(
                  child: Column(
                    children: [
                      const Text('Kode laporan', style: TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w700)),
                      const SizedBox(height: MedSpace.xs),
                      SelectableText(
                        report.code,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1, color: MedColors.ink),
                      ),
                      const SizedBox(height: MedSpace.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(report.typeName, style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(width: MedSpace.sm),
                          StatusBadge(status: report.statusValue, label: report.status.label),
                        ],
                      ),
                      if (report.address != null) ...[
                        const SizedBox(height: MedSpace.sm),
                        Text(
                          report.address!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: MedColors.inkMuted),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Lacak Ambulans',
                  icon: Icons.near_me_rounded,
                  onPressed: () => context.pushReplacement(Routes.tracking(report.id)),
                ),
                const SizedBox(height: MedSpace.md),
                SecondaryButton(label: 'Kembali ke Beranda', onPressed: () => context.go(Routes.home)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

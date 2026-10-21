import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../router.dart';
import '../../widgets/feedback.dart';
import 'address_search_sheet.dart';
import 'home_providers.dart';
import 'pickup_controller.dart';
import 'pickup_map.dart';

/// Beranda Figma: wordmark, bar merah "Alamat Penjemputan", peta dengan pin jemput, lalu empat
/// layanan darurat. Bila ada laporan berjalan, kartu "Lacak ambulans" muncul di atas layanan.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeReportProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.lg, MedSpace.gutter, MedSpace.md),
              child: Text(
                'MeDrive',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: MedColors.ink, height: 1),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: MedSpace.gutter),
              child: _PickupAddressBar(),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(MedSpace.gutter, 0, MedSpace.gutter, MedSpace.md),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(MedRadius.lg)),
                  child: PickupMap(),
                ),
              ),
            ),
            if (active.value != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(MedSpace.gutter, 0, MedSpace.gutter, MedSpace.md),
                child: _ActiveReportCard(report: active.value!),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(MedSpace.gutter, 0, MedSpace.gutter, MedSpace.lg),
              child: _ServiceGrid(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupAddressBar extends ConsumerWidget {
  const _PickupAddressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickup = ref.watch(pickupProvider);
    final text = pickup.resolving
        ? 'Mencari alamat...'
        : pickup.addressError ?? pickup.address ?? 'Geser peta untuk menentukan titik jemput';

    return Semantics(
      button: true,
      label: 'Alamat penjemputan: $text. Ketuk untuk mencari alamat.',
      child: Material(
        color: MedColors.brand,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(MedRadius.lg)),
        child: InkWell(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(MedRadius.lg)),
          onTap: () async {
            final result = await showAddressSearch(context);
            if (result != null) {
              ref.read(pickupProvider.notifier).moveTo(result.point, address: result.label);
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(MedSpace.lg, MedSpace.md, MedSpace.md, MedSpace.md),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alamat Penjemputan',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, height: 1.25),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: MedSpace.sm),
                  const Icon(Icons.search_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveReportCard extends StatelessWidget {
  const _ActiveReportCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) => AppCard(
        color: MedColors.brandSoft,
        padding: const EdgeInsets.symmetric(horizontal: MedSpace.lg, vertical: MedSpace.md),
        onTap: () => context.push(Routes.tracking(report.id)),
        child: Row(
          children: [
            const Icon(Icons.emergency_share_rounded, color: MedColors.brand, size: 30),
            const SizedBox(width: MedSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${report.typeName} · ${report.code}', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  StatusBadge(status: report.statusValue, label: report.status.label),
                ],
              ),
            ),
            const Text('Lacak', style: TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w900)),
            const Icon(Icons.chevron_right_rounded, color: MedColors.brandDeep),
          ],
        ),
      );
}

class _ServiceGrid extends ConsumerWidget {
  const _ServiceGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(reportTypesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Butuh ambulans untuk apa?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: MedSpace.sm),
        SizedBox(
          height: 108,
          child: types.when(
            loading: () => Row(
              children: [
                for (var index = 0; index < 4; index++) ...[
                  if (index > 0) const SizedBox(width: MedSpace.sm),
                  const Expanded(child: Skeleton(height: 108, radius: MedRadius.lg)),
                ],
              ],
            ),
            error: (error, _) => Center(
              child: TextButton.icon(
                onPressed: () => ref.invalidate(reportTypesProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(asApiError(error).message, maxLines: 2),
              ),
            ),
            data: (items) => Row(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  if (index > 0) const SizedBox(width: MedSpace.sm),
                  Expanded(
                    child: ServiceCard(
                      name: items[index].name,
                      color: colorFromHex(items[index].color),
                      icon: reportTypeIcon(items[index].icon, code: items[index].code),
                      onTap: () => context.push(Routes.newReport(items[index].code)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

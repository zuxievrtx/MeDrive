import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

import 'address_search_sheet.dart';
import 'pickup_controller.dart';
import 'pickup_map.dart';

/// Ubah titik jemput dari form laporan (peta layar penuh + cari alamat).
class LocationPickerScreen extends ConsumerWidget {
  const LocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickup = ref.watch(pickupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Titik Jemput'),
        actions: [
          IconButton(
            tooltip: 'Cari alamat',
            icon: const Icon(Icons.search_rounded),
            onPressed: () async {
              final result = await showAddressSearch(context);
              if (result != null) {
                ref.read(pickupProvider.notifier).moveTo(result.point, address: result.label);
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(child: PickupMap()),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(MedSpace.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: MedColors.brand),
                      const SizedBox(width: MedSpace.sm),
                      Expanded(
                        child: Text(
                          pickup.resolving ? 'Mencari alamat...' : (pickup.address ?? pickup.addressError ?? '-'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: MedSpace.md),
                  PrimaryButton(
                    label: 'Gunakan lokasi ini',
                    icon: Icons.check_rounded,
                    onPressed: pickup.resolving ? null : () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

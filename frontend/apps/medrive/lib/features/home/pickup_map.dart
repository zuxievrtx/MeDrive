import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show Distance, LengthUnit;
import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../widgets/feedback.dart';
import 'device_location.dart';
import 'pickup_controller.dart';

/// Peta pemilihan titik jemput: pin tetap di tengah, pengguna menggeser peta di bawahnya
/// (pola aplikasi transportasi). Alamat di bar atas ikut diperbarui setelah peta berhenti.
class PickupMap extends ConsumerStatefulWidget {
  const PickupMap({super.key, this.controlsBottomPadding = 12});

  final double controlsBottomPadding;

  @override
  ConsumerState<PickupMap> createState() => _PickupMapState();
}

class _PickupMapState extends ConsumerState<PickupMap> {
  final _map = MapController();
  bool _ready = false;

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    final pickup = ref.read(pickupProvider.notifier);
    final position = await pickup.locate();
    if (!mounted) {
      return;
    }
    if (position == null) {
      final access = ref.read(pickupProvider).access;
      final message = switch (access) {
        LocationAccess.serviceOff => 'GPS mati. Aktifkan lokasi perangkat untuk menemukan posisi Anda.',
        LocationAccess.deniedForever => 'Izin lokasi ditolak. Buka pengaturan aplikasi untuk mengizinkan.',
        _ => 'Lokasi belum bisa ditemukan. Geser peta ke lokasi Anda.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: access == LocationAccess.serviceOff || access == LocationAccess.deniedForever
              ? SnackBarAction(
                  label: 'Pengaturan',
                  onPressed: () => ref.read(deviceLocationProvider).openSettings(access!),
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = ref.watch(pickupProvider);

    // Titik berubah dari luar peta (pencarian alamat / lokasi saya) → pindahkan kamera.
    ref.listen(pickupProvider.select((state) => state.point), (_, next) {
      if (_ready && const Distance().as(LengthUnit.Meter, _map.camera.center, next) > 3) {
        _map.move(next, _map.camera.zoom < 15 ? 16 : _map.camera.zoom);
      }
    });

    return Stack(
      children: [
        MedMapView(
          controller: _map,
          initialCenter: pickup.point,
          initialZoom: 16,
          myLocation: pickup.myLocation,
          onRecenter: () => unawaited(_locate()),
          controlsBottomPadding: widget.controlsBottomPadding,
          onMapReady: () {
            _ready = true;
            if (pickup.myLocation == null) {
              unawaited(_locate().catchError((Object error) {
                if (context.mounted) {
                  showError(context, error);
                }
              }));
            }
          },
          onPositionChanged: (camera, hasGesture) {
            if (hasGesture) {
              ref.read(pickupProvider.notifier).moveTo(camera.center);
            }
          },
        ),
        // Ujung pin tepat di pusat peta.
        const IgnorePointer(
          child: Center(
            child: Padding(padding: EdgeInsets.only(bottom: 44), child: PickupPin()),
          ),
        ),
      ],
    );
  }
}


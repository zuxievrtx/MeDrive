import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// Peta OSM (flutter_map) dengan cache tile bawaan di disk, titik "lokasi saya", tombol
/// zoom, kembali ke lokasi, dan kompas. Tidak memakai Google Maps SDK.
class MedMapView extends StatelessWidget {
  const MedMapView({
    super.key,
    required this.initialCenter,
    this.controller,
    this.initialZoom = 15,
    this.markers = const [],
    this.polylines = const [],
    this.myLocation,
    this.onRecenter,
    this.onPositionChanged,
    this.onMapReady,
    this.interactive = true,
    this.showControls = true,
    this.controlsBottomPadding = 12,
    this.userAgentPackageName = 'com.medrive.pelapor',
  });

  final MapController? controller;
  final LatLng initialCenter;
  final double initialZoom;
  final List<Marker> markers;
  final List<Polyline<Object>> polylines;
  final LatLng? myLocation;

  /// Tombol "lokasi saya". Bila null, tombol disembunyikan.
  final VoidCallback? onRecenter;
  final void Function(MapCamera camera, bool hasGesture)? onPositionChanged;
  final VoidCallback? onMapReady;
  final bool interactive;
  final bool showControls;
  final double controlsBottomPadding;

  /// Kebijakan tile OSM mewajibkan identitas aplikasi.
  final String userAgentPackageName;

  /// Server tile bisa diganti lewat `--dart-define=TILE_URL=...` (mis. server tile sendiri untuk
  /// produksi, sesuai kebijakan tile OSM).
  static const tileUrl = String.fromEnvironment('TILE_URL', defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');

  static final _cache = BuiltInMapCachingProvider.getOrCreateInstance(maxCacheSize: 200000000);

  @override
  Widget build(BuildContext context) => FlutterMap(
        mapController: controller,
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: initialZoom,
          minZoom: 4,
          maxZoom: 19,
          onPositionChanged: onPositionChanged,
          onMapReady: onMapReady,
          interactionOptions: InteractionOptions(
            flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: tileUrl,
            userAgentPackageName: userAgentPackageName,
            maxNativeZoom: 19,
            tileProvider: NetworkTileProvider(cachingProvider: _cache),
          ),
          if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
          if (myLocation != null)
            MarkerLayer(
              markers: [Marker(point: myLocation!, width: 26, height: 26, child: const MyLocationDot())],
            ),
          if (markers.isNotEmpty) MarkerLayer(markers: markers),
          if (showControls) _MapControls(onRecenter: onRecenter, bottomPadding: controlsBottomPadding),
          const _OsmAttribution(),
        ],
      );
}

/// Atribusi wajib OSM. Label ringkas sendiri karena `SimpleAttributionWidget` meluap di peta kecil.
class _OsmAttribution extends StatelessWidget {
  const _OsmAttribution();

  @override
  Widget build(BuildContext context) => const Align(
        alignment: Alignment.bottomLeft,
        child: ColoredBox(
          color: Color(0xCCFFFFFF),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 10.5, color: MedColors.ink)),
          ),
        ),
      );
}

class _MapControls extends StatelessWidget {
  const _MapControls({required this.onRecenter, required this.bottomPadding});

  final VoidCallback? onRecenter;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final controller = MapController.of(context);

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (camera.rotation.abs() > 1)
              _ControlButton(
                tooltip: 'Arahkan utara ke atas',
                onPressed: () => controller.rotate(0),
                child: Transform.rotate(
                  angle: -camera.rotation * math.pi / 180,
                  child: const Icon(Icons.navigation_rounded, color: MedColors.brand),
                ),
              ),
            _ControlButton(
              tooltip: 'Perbesar',
              onPressed: () => controller.move(camera.center, math.min(camera.zoom + 1, 19)),
              child: const Icon(Icons.add_rounded),
            ),
            _ControlButton(
              tooltip: 'Perkecil',
              onPressed: () => controller.move(camera.center, math.max(camera.zoom - 1, 4)),
              child: const Icon(Icons.remove_rounded),
            ),
            if (onRecenter != null)
              _ControlButton(
                tooltip: 'Ke lokasi saya',
                onPressed: onRecenter!,
                child: const Icon(Icons.my_location_rounded, color: MedColors.brand),
              ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.tooltip, required this.onPressed, required this.child});

  final String tooltip;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Material(
          color: MedColors.surface,
          shape: const CircleBorder(),
          elevation: 3,
          child: IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            constraints: const BoxConstraints.tightFor(width: 46, height: 46),
            icon: child,
          ),
        ),
      );
}

/// Titik biru "lokasi saya".
class MyLocationDot extends StatelessWidget {
  const MyLocationDot({super.key});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
      );
}

/// Pin merah titik jemput (Figma).
class PickupPin extends StatelessWidget {
  const PickupPin({super.key, this.size = 48, this.color = MedColors.brand});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Icon(
        Icons.location_on_rounded,
        size: size,
        color: color,
        shadows: const [Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2))],
      );
}

/// Marker ambulans: lingkaran merah dengan ikon tetap tegak, panah penunjuk arah diputar sesuai
/// [heading] (derajat dari utara) agar ikon tetap terbaca.
class AmbulanceMarker extends StatelessWidget {
  const AmbulanceMarker({super.key, this.heading, this.size = 52});

  final double? heading;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Posisi ambulans',
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (heading != null)
                Transform.rotate(
                  angle: heading! * math.pi / 180,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: CustomPaint(size: Size(size * 0.36, size * 0.24), painter: _HeadingPainter()),
                  ),
                ),
              Container(
                width: size * 0.72,
                height: size * 0.72,
                decoration: BoxDecoration(
                  color: MedColors.brand,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Icon(Icons.local_hospital_rounded, color: Colors.white, size: size * 0.36),
              ),
            ],
          ),
        ),
      );
}

class _HeadingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = MedColors.brandDeep);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

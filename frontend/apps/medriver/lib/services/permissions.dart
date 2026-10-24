import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Status izin yang dibutuhkan selama shift.
class ShiftPermissions {
  const ShiftPermissions({
    required this.locationServiceOn,
    required this.location,
    required this.notifications,
    required this.ignoreBatteryOptimizations,
  });

  final bool locationServiceOn;

  /// Minimal "saat aplikasi digunakan". Foreground service menjaga ping tetap jalan di background.
  final bool location;
  final bool notifications;
  final bool ignoreBatteryOptimizations;

  /// Lokasi wajib untuk membuka shift; notifikasi & baterai sangat dianjurkan.
  bool get canOpenShift => locationServiceOn && location;

  bool get allGranted => canOpenShift && notifications && ignoreBatteryOptimizations;
}

/// Pemeriksaan & permintaan izin. Dibungkus agar bisa diganti di widget test.
class PermissionGate {
  const PermissionGate();

  Future<ShiftPermissions> check() async => ShiftPermissions(
        locationServiceOn: await Geolocator.isLocationServiceEnabled(),
        location: await Permission.locationWhenInUse.isGranted,
        notifications: await Permission.notification.isGranted,
        ignoreBatteryOptimizations: await Permission.ignoreBatteryOptimizations.isGranted,
      );

  /// Minta izin berurutan: lokasi → notifikasi → abaikan optimasi baterai → full-screen intent
  /// (Android 14+, agar tawaran muncul di layar terkunci).
  Future<ShiftPermissions> request() async {
    await Permission.locationWhenInUse.request();
    await Permission.notification.request();
    await Permission.ignoreBatteryOptimizations.request();
    try {
      await FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestFullScreenIntentPermission();
    } on Object {
      // Android lama tidak butuh izin ini.
    }
    return check();
  }

  Future<void> openSettings({required bool locationService}) async {
    if (locationService) {
      await Geolocator.openLocationSettings();
    } else {
      await openAppSettings();
    }
  }
}

final permissionGateProvider = Provider<PermissionGate>((ref) => const PermissionGate());

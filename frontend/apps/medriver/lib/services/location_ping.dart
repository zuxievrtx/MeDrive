import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:path_provider/path_provider.dart';

import '../state/session.dart' show appVersion;

/// Platform channel kecil (MainActivity.kt) yang membaca bendera mock dari lokasi terakhir
/// LocationManager (`Location.isMock` / `isFromMockProvider`). Digabung dengan
/// `Position.isMocked` dari geolocator: salah satu bernilai true → titik ditandai palsu.
class MockLocationChannel {
  const MockLocationChannel();

  static const _channel = MethodChannel('com.medrive.driver/mock_location');

  Future<bool> lastLocationIsMock() async {
    try {
      return await _channel.invokeMethod<bool>('lastLocationIsMock') ?? false;
    } on Object {
      return false;
    }
  }
}

/// Lokasi dari geolocator dengan foreground service Android, sehingga ping tetap berjalan saat
/// layar mati atau aplikasi di background selama shift terbuka.
class GeolocatorLocationSource implements LocationSource {
  GeolocatorLocationSource({this.mockChannel = const MockLocationChannel()});

  final MockLocationChannel mockChannel;

  @override
  Stream<LocationFix> watch({required Duration interval}) {
    final settings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      intervalDuration: interval,
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: 'MeDriveR aktif: memancarkan lokasi',
        notificationText: 'Lokasi ambulans dikirim ke admin pusat selama shift terbuka.',
        notificationChannelName: 'Lokasi shift',
        enableWakeLock: true,
        setOngoing: true,
      ),
    );

    return Geolocator.getPositionStream(locationSettings: settings).asyncMap((position) async {
      final mock = position.isMocked || await mockChannel.lastLocationIsMock();
      return LocationFix(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: position.timestamp,
        accuracyM: position.accuracy,
        altitudeM: position.altitude,
        speedMps: position.speed,
        heading: position.heading,
        isMock: mock,
      );
    });
  }
}

class DeviceBattery implements BatteryReader {
  final _battery = Battery();

  @override
  Future<int?> level() async {
    try {
      return await _battery.batteryLevel;
    } on Object {
      return null;
    }
  }
}

/// Antrean offline di direktori data aplikasi, dibuka saat pertama dipakai.
class AppFilePingQueueStore implements PingQueueStore {
  FilePingQueueStore? _store;

  Future<FilePingQueueStore> _resolve() async {
    if (_store != null) {
      return _store!;
    }
    final directory = await getApplicationSupportDirectory();
    return _store = FilePingQueueStore(File('${directory.path}/location_queue.json'));
  }

  @override
  Future<List<Map<String, dynamic>>> load() async {
    try {
      return await (await _resolve()).load();
    } on Object {
      return [];
    }
  }

  @override
  Future<void> save(List<Map<String, dynamic>> points) async {
    try {
      await (await _resolve()).save(points);
    } on Object catch (error) {
      debugPrint('Antrean lokasi tidak tersimpan: $error');
    }
  }
}

final locationSourceProvider = Provider<LocationSource>((ref) => GeolocatorLocationSource());

final batteryReaderProvider = Provider<BatteryReader>((ref) => DeviceBattery());

final pingQueueStoreProvider = Provider<PingQueueStore>((ref) => AppFilePingQueueStore());

/// Satu pengirim lokasi untuk seluruh aplikasi; dijalankan [DriverController] selama shift terbuka.
final locationPingProvider = Provider<LocationPingService>((ref) {
  final service = LocationPingService(
    api: ref.watch(apiClientProvider),
    source: ref.watch(locationSourceProvider),
    battery: ref.watch(batteryReaderProvider),
    store: ref.watch(pingQueueStoreProvider),
    device: () => {'app_version': appVersion, 'device_model': 'Android'},
  );
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

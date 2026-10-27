import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:medrive_core/medrive_core.dart';
import 'package:medriver/services/dispatch_alarm.dart';
import 'package:medriver/services/location_ping.dart';
import 'package:medriver/services/permissions.dart';

/// Backend palsu di lapisan HTTP: [ApiClient] asli (header, amplop, ApiError) dengan adapter Dio
/// yang menjawab dari [handler]. Semua permintaan dicatat di [requests].
typedef ResponseBodyHandler = ResponseBody Function(RequestOptions request);

class FakeBackend implements HttpClientAdapter {
  FakeBackend(this.handler);

  final ResponseBodyHandler handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}

  Iterable<RequestOptions> to(String method, String path) =>
      requests.where((request) => request.method == method && request.uri.path == '/api/v1$path');

  /// Override provider agar seluruh aplikasi driver memakai backend palsu, tanpa plugin native
  /// (GPS, izin, alarm) yang tidak tersedia di test.
  List<Override> overrides({String? token = 'token-driver', FakeAlarm? alarm}) {
    final tokens = MemoryTokenStorage(token);
    return [
      appRoleProvider.overrideWithValue(AppRole.driver),
      tokenStorageProvider.overrideWithValue(tokens),
      apiClientProvider.overrideWith((ref) {
        final client = ApiClient(config: testConfig, tokens: tokens, dio: Dio()..httpClientAdapter = this);
        ref.onDispose(client.dispose);
        return client;
      }),
      locationSourceProvider.overrideWithValue(SilentLocationSource()),
      batteryReaderProvider.overrideWithValue(FixedBattery()),
      pingQueueStoreProvider.overrideWithValue(MemoryPingQueueStore()),
      permissionGateProvider.overrideWithValue(const GrantedPermissions()),
      dispatchAlarmProvider.overrideWithValue(alarm ?? FakeAlarm()),
    ];
  }
}

const testConfig = AppConfig(apiBaseUrl: 'http://api.test', wsUrl: 'ws://api.test', wsKey: 'key');

/// GPS yang belum memberi titik. Memakai controller (bukan `Stream.empty`) karena membatalkan
/// langganan `Stream.empty` di zona fake-async widget test tidak pernah selesai.
class SilentLocationSource implements LocationSource {
  @override
  Stream<LocationFix> watch({required Duration interval}) => StreamController<LocationFix>().stream;
}

class FixedBattery implements BatteryReader {
  @override
  Future<int?> level() async => 80;
}

class GrantedPermissions extends PermissionGate {
  const GrantedPermissions();

  static const _all = ShiftPermissions(locationServiceOn: true, location: true, notifications: true, ignoreBatteryOptimizations: true);

  @override
  Future<ShiftPermissions> check() async => _all;

  @override
  Future<ShiftPermissions> request() async => _all;
}

/// Alarm senyap yang mencatat panggilan.
class FakeAlarm extends DispatchAlarm {
  FakeAlarm() : super(PushService(config: testConfig));

  final started = <int>[];
  final stopped = <int>[];

  @override
  Future<void> start(Dispatch dispatch) async => started.add(dispatch.id);

  @override
  Future<void> stop(int dispatchId) async => stopped.add(dispatchId);
}

ResponseBody ok(Object? data, {int status = 200}) => _json({'success': true, 'data': data}, status);

ResponseBody apiError(String code, String message, int status) => _json({
      'success': false,
      'error': {'code': code, 'message': message},
    }, status);

ResponseBody _json(Object body, int status) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

const clinicJson = <String, dynamic>{
  'id': 3,
  'code': 'KLN-SMG-01',
  'name': 'Klinik Pratama Sehat',
  'latitude': -6.99,
  'longitude': 110.42,
  'institution': {'id': 1, 'code': 'DKK', 'name': 'Dinas Kesehatan Kota Semarang'},
};

const ambulanceJson = <String, dynamic>{
  'id': 7,
  'plate_number': 'H 1234 KS',
  'vehicle_name': 'Toyota Hiace',
  'year': 2023,
  'status': {'value': 'tersedia', 'label': 'Tersedia'},
  'clinic_id': 3,
  'ambulance_type_id': 1,
  'ambulance_type': {'id': 1, 'code': 'gawat_darurat', 'name': 'Gawat Darurat', 'map_icon': 'truck-medical'},
};

Map<String, dynamic> driverProfileJson({Map<String, dynamic>? openShift, bool onDuty = false}) => {
      'id': 21,
      'name': 'Driver Uji',
      'initials': 'DU',
      'phone': '081200000021',
      'email': 'driver@medrive.test',
      'role': {'value': 'driver', 'label': 'Driver'},
      'account_status': {'value': 'aktif', 'label': 'Aktif'},
      'must_change_password': false,
      'driver_profile': {
        'clinic_id': 3,
        'clinic': clinicJson,
        'employee_number': 'PGW-0021',
        'license_number': '1234-5678-0021',
        'license_class': {'value': 'A', 'label': 'A'},
        'license_expires_at': '2028-01-31',
        'license_expiry_state': 'valid',
        'photo_url': null,
        'is_on_duty': onDuty,
      },
      'open_shift': openShift,
      'is_verified': true,
      'certifications': [
        {'id': 1, 'driver_id': 21, 'name': 'BTCLS', 'issuer': 'PPNI', 'issued_at': '2025-01-10', 'expires_at': '2027-01-10', 'expiry_state': 'valid'},
      ],
    };

Map<String, dynamic> openShiftJson() => {
      'id': 40,
      'driver_id': 21,
      'started_at': '2026-10-24T08:00:00+07:00',
      'ended_at': null,
      'end_reason': null,
      'is_open': true,
      'ambulance': ambulanceJson,
    };

Map<String, dynamic> reportJson({String status = 'menunggu'}) => {
      'id': 90,
      'code': 'MDR-261024-0007',
      'status': {'value': status, 'label': status == 'menunggu' ? 'Menunggu' : 'Diambil', 'tone': 'amber'},
      'report_type': {
        'id': 1,
        'code': 'kecelakaan',
        'name': 'Kecelakaan',
        'priority': 1,
        'is_emergency': true,
        'requires_destination': false,
        'icon': 'car-crash',
        'color': '#B5523B',
        'text_color': '#FFFFFF',
        'is_active': true,
        'sort_order': 1,
      },
      'address': 'Jl. Pahlawan No. 1, Semarang',
      'short_address': 'Jl. Pahlawan',
      'latitude': -6.9932,
      'longitude': 110.4203,
      'destination': null,
      'description': 'Motor tertabrak mobil, satu korban luka di kaki.',
      'reporter': {'id': 5, 'name': 'Pelapor Uji', 'phone': '081200000005'},
      'patients': <Object>[],
      'attachments': <Object>[],
      'timeline': <Object>[],
      'created_at': '2026-10-24T09:00:00+07:00',
    };

Map<String, dynamic> dispatchJson() => {
      'id': 55,
      'report_id': 90,
      'distance_km': 2.4,
      'sent_at': '2026-10-24T09:00:05+07:00',
      'opened_at': null,
      'responded_at': null,
      'response': {'value': 'menunggu', 'label': 'Menunggu'},
      'report': reportJson(),
    };

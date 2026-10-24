import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import '../api/api_response.dart';
import '../models/common.dart';
import '../models/driver.dart';
import '../models/report.dart';

/// Endpoint grup driver (`/driver/*`): profil, shift, tawaran dispatch, misi, pasien, foto
/// penanganan, rute, dan riwayat. Ping lokasi ada di [LocationPingService].
class DriverRepository {
  DriverRepository(this._api);

  final ApiClient _api;

  Future<DriverAccount> profile() async {
    final response = await _api.get('/driver/profile');
    return DriverAccount.fromJson(_map(response.data));
  }

  /// Ambulans tersedia milik klinik driver yang tidak sedang dipakai shift lain.
  Future<List<Ambulance>> availableAmbulances() async {
    final response = await _api.get('/driver/ambulances/available');
    return _list(response.data).map(Ambulance.fromJson).toList();
  }

  Future<Shift> openShift(int ambulanceId) async {
    final response = await _api.post('/driver/shifts', data: {'ambulance_id': ambulanceId});
    return Shift.fromJson(_map(response.data));
  }

  /// [reason] wajib (3-255 karakter). Server tidak pernah menutup shift otomatis.
  Future<Shift> closeShift(String reason) async {
    final response = await _api.post('/driver/shifts/close', data: {'reason': reason.trim()});
    return Shift.fromJson(_map(response.data));
  }

  /// Tawaran yang masih menunggu jawaban (cadangan bila push FCM terlewat).
  Future<List<Dispatch>> activeDispatches() async {
    final response = await _api.get('/driver/dispatches/active');
    return _list(response.data).map(Dispatch.fromJson).toList();
  }

  /// Detail tawaran; server mencatat `opened_at` saat endpoint ini dipanggil.
  Future<Dispatch> dispatch(int dispatchId) async {
    final response = await _api.get('/driver/dispatches/$dispatchId');
    return Dispatch.fromJson(_map(response.data));
  }

  /// Ambil laporan. Yang menang mendapat detail laporan; yang kalah `409 too_late`,
  /// tawaran ronde lama `409 offer_expired`.
  Future<Report> accept(int dispatchId, {required String idempotencyKey}) async {
    final response = await _api.post(
      '/driver/dispatches/$dispatchId/accept',
      headers: {ApiClient.idempotencyHeader: idempotencyKey},
    );
    return Report.fromJson(_map(response.data));
  }

  Future<Report> report(int reportId) async {
    final response = await _api.get('/driver/reports/$reportId');
    return Report.fromJson(_map(response.data));
  }

  /// Transisi status misi. Server memvalidasi urutan dan gate serah terima pasien.
  Future<Report> updateStatus(
    int reportId,
    String status, {
    required String idempotencyKey,
    double? latitude,
    double? longitude,
    String? note,
  }) async {
    final response = await _api.post(
      '/driver/reports/$reportId/status',
      data: {
        'status': status,
        if (latitude != null && longitude != null) ...{'latitude': latitude, 'longitude': longitude},
        'note': ?note,
      },
      headers: {ApiClient.idempotencyHeader: idempotencyKey},
    );
    return Report.fromJson(_map(response.data));
  }

  Future<ReportPatient> addPatient(int reportId, PatientInput input) async {
    final response = await _api.post('/driver/reports/$reportId/patients', data: input.toJson());
    return ReportPatient.fromJson(_map(response.data));
  }

  Future<ReportPatient> updatePatient(int patientId, PatientInput input) async {
    final response = await _api.put('/driver/patients/$patientId', data: input.toJson());
    return ReportPatient.fromJson(_map(response.data));
  }

  /// Foto penanganan (maks 5 per permintaan, sudah dikompres di aplikasi).
  Future<List<ReportAttachment>> uploadHandlingPhotos(int reportId, List<String> paths) async {
    final form = FormData();
    for (final path in paths) {
      form.files.add(MapEntry('photos[]', await MultipartFile.fromFile(path, filename: path.split('/').last)));
    }
    final response = await _api.post('/driver/reports/$reportId/attachments', data: form);
    return _list(response.data).map(ReportAttachment.fromJson).toList();
  }

  /// Rute jalan + ETA dari posisi driver ke titik jemput (atau tujuan antar), lewat proxy OSRM backend.
  Future<RouteResult> route() async {
    final response = await _api.get('/driver/route');
    return RouteResult.fromJson(_map(response.data));
  }

  Future<Paged<Report>> history({int page = 1}) async {
    final response = await _api.get('/driver/reports/history', query: {'page': page});
    return Paged(
      items: _list(response.data).map(Report.fromJson).toList(),
      pagination: response.pagination ?? const PaginationMeta(currentPage: 1, lastPage: 1, perPage: 15, total: 0),
    );
  }

  /// Laporan yang sedang ditangani. Backend tidak punya endpoint khusus, jadi dicari di halaman
  /// pertama riwayat (urut terbaru; driver hanya bisa menangani satu laporan aktif).
  Future<Report?> currentMission() async {
    final page = await history();
    for (final report in page.items) {
      if (report.isActive) {
        return report;
      }
    }
    return null;
  }

  static Map<String, dynamic> _map(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ApiError(code: 'invalid_response', message: 'Respons server tidak dikenali. Coba lagi.');
  }

  static List<Map<String, dynamic>> _list(Object? data) =>
      data is List ? data.whereType<Map<String, dynamic>>().toList() : const [];
}

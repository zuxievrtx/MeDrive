import '../api/api_client.dart';
import '../api/api_error.dart';
import '../api/api_response.dart';
import '../models/common.dart';
import '../models/report.dart';
import '../models/report_draft.dart';
import '../models/report_type.dart';

/// Laporan milik pelapor (`/reporter/reports*`), jenis laporan, dan faskes tujuan.
class ReportRepository {
  ReportRepository(this._api);

  final ApiClient _api;
  List<ReportType>? _types;

  /// Jenis laporan dari server bila tersedia, selain itu daftar bawaan yang sama dengan seeder.
  Future<List<ReportType>> reportTypes() async {
    if (_types != null) {
      return _types!;
    }

    try {
      final response = await _api.get('/reporter/report-types');
      final types = _list(response.data).map(ReportType.fromJson).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return _types = types.isEmpty ? defaultReportTypes : types;
    } on ApiError catch (error) {
      if (error.statusCode == 404 || error.statusCode == 405) {
        return _types = defaultReportTypes;
      }
      rethrow;
    }
  }

  Future<Paged<Report>> list({int page = 1, String? status, String? typeCode}) async {
    final response = await _api.get('/reporter/reports', query: {'page': page, 'status': status, 'type': typeCode});
    return Paged(
      items: _list(response.data).map(Report.fromJson).toList(),
      pagination: response.pagination ?? const PaginationMeta(currentPage: 1, lastPage: 1, perPage: 15, total: 0),
    );
  }

  Future<Report> detail(int id) async {
    final response = await _api.get('/reporter/reports/$id');
    return Report.fromJson(_map(response.data));
  }

  /// Kirim laporan. [idempotencyKey] dibuat sekali per draft agar retry tidak membuat laporan ganda.
  Future<Report> create(ReportDraft draft, {required String idempotencyKey}) async {
    final response = await _api.post(
      '/reporter/reports',
      data: await draft.toFormData(),
      headers: {ApiClient.idempotencyHeader: idempotencyKey},
    );
    return Report.fromJson(_map(response.data));
  }

  /// Posisi ambulans untuk polling cadangan saat WebSocket putus. Null bila belum ada posisi.
  Future<DriverLocation?> driverLocation(int reportId) async {
    final response = await _api.get('/reporter/reports/$reportId/driver-location');
    final location = _map(response.data)['location'];
    return location is Map<String, dynamic> ? DriverLocation.fromJson(location) : null;
  }

  Future<RouteResult> route(int reportId) async {
    final response = await _api.get('/reporter/reports/$reportId/route');
    return RouteResult.fromJson(_map(response.data));
  }

  Future<Paged<Clinic>> clinics({String? search, int page = 1}) async {
    final response = await _api.get('/reporter/clinics', query: {'search': search?.trim(), 'page': page});
    return Paged(
      items: _list(response.data).map(Clinic.fromJson).toList(),
      pagination: response.pagination ?? const PaginationMeta(currentPage: 1, lastPage: 1, perPage: 20, total: 0),
    );
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

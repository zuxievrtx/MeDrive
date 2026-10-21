import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_error.dart';
import 'api_response.dart';

/// Klien HTTP untuk `/api/v1`: header JSON + Bearer, amplop `{success, data, meta}`, error
/// [ApiError], logout global saat 401, dan satu kali retry untuk gangguan jaringan pada
/// permintaan yang aman diulang (GET atau yang membawa Idempotency-Key).
class ApiClient {
  ApiClient({required AppConfig config, required this._tokens, Dio? dio}) : dio = dio ?? Dio() {
    this.dio.options
      ..baseUrl = config.apiV1
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 30)
      ..sendTimeout = const Duration(seconds: 60)
      ..headers = {'Accept': 'application/json'};

    this.dio.interceptors.add(
          InterceptorsWrapper(onRequest: _attachToken, onError: _handleError),
        );
  }

  static const _retriedKey = 'medrive.retried';
  static const idempotencyHeader = 'Idempotency-Key';

  final Dio dio;
  final TokenStorage _tokens;
  final _unauthorized = StreamController<void>.broadcast();

  /// `false` setelah permintaan gagal karena jaringan; kembali `true` begitu server menjawab.
  /// Dipakai pita "Tidak ada koneksi" di aplikasi.
  final reachable = ValueNotifier<bool>(true);

  /// Dipancarkan saat server membalas 401 untuk permintaan yang membawa token.
  Stream<void> get onUnauthorized => _unauthorized.stream;

  /// Header untuk memuat berkas privat (`/media/...`) lewat widget gambar.
  Map<String, String> get authHeaders {
    final token = _tokens.cachedToken;
    return {'Accept': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
  }

  Future<ApiResponse<dynamic>> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => dio.get<Object?>(path, queryParameters: _clean(query)));

  Future<ApiResponse<dynamic>> post(String path, {Object? data, Map<String, String>? headers}) =>
      _send(() => dio.post<Object?>(path, data: data, options: Options(headers: headers)));

  Future<ApiResponse<dynamic>> put(String path, {Object? data, Map<String, String>? headers}) =>
      _send(() => dio.put<Object?>(path, data: data, options: Options(headers: headers)));

  Future<ApiResponse<dynamic>> _send(Future<Response<Object?>> Function() request) async {
    try {
      final response = await request();
      reachable.value = true;
      return _unwrap(response);
    } on DioException catch (exception) {
      final error = ApiError.fromDio(exception);
      reachable.value = !error.isNetwork;
      throw error;
    }
  }

  ApiResponse<dynamic> _unwrap(Response<Object?> response) {
    final body = response.data;

    if (response.statusCode == 204 || body == null || body == '') {
      return const ApiResponse<dynamic>(data: null);
    }

    if (body is! Map<String, dynamic>) {
      throw const ApiError(code: 'invalid_response', message: 'Respons server tidak dikenali. Coba lagi.');
    }

    if (body['success'] == false) {
      throw ApiError.fromResponseBody(body, response.statusCode);
    }

    final meta = body['meta'];
    return ApiResponse<dynamic>(data: body['data'], meta: meta is Map<String, dynamic> ? meta : const {});
  }

  Future<void> _attachToken(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokens.read();
    if (token != null && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _handleError(DioException exception, ErrorInterceptorHandler handler) async {
    final options = exception.requestOptions;

    if (exception.response?.statusCode == 401 && options.headers.containsKey('Authorization')) {
      _unauthorized.add(null);
    }

    if (_shouldRetry(exception)) {
      options.extra[_retriedKey] = true;
      final data = options.data;
      try {
        final response = await dio.fetch<Object?>(
          data is FormData ? options.copyWith(data: data.clone()) : options,
        );
        return handler.resolve(response);
      } on DioException catch (retryException) {
        return handler.next(retryException);
      }
    }

    handler.next(exception);
  }

  bool _shouldRetry(DioException exception) {
    final options = exception.requestOptions;
    final isNetworkFailure = exception.response == null &&
        const [
          DioExceptionType.connectionError,
          DioExceptionType.connectionTimeout,
          DioExceptionType.receiveTimeout,
          DioExceptionType.sendTimeout,
        ].contains(exception.type);
    final isSafe = options.method == 'GET' || options.headers.containsKey(idempotencyHeader);

    return isNetworkFailure && isSafe && options.extra[_retriedKey] != true;
  }

  static Map<String, dynamic>? _clean(Map<String, dynamic>? query) {
    if (query == null) {
      return null;
    }
    return Map.fromEntries(query.entries.where((entry) => entry.value != null && entry.value != ''));
  }

  void dispose() {
    reachable.dispose();
    unawaited(_unauthorized.close());
    dio.close();
  }
}

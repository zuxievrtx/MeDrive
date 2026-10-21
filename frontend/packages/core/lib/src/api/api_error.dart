import 'package:dio/dio.dart';

/// Error baku dari backend `{success: false, error: {code, message, details}}`, atau error jaringan
/// yang dipetakan ke bentuk yang sama agar UI cukup menampilkan [message].
class ApiError implements Exception {
  const ApiError({
    required this.code,
    required this.message,
    this.details = const {},
    this.statusCode,
  });

  /// Bentuk respons error backend.
  factory ApiError.fromResponseBody(Object? body, int? statusCode) {
    if (body is Map && body['error'] is Map) {
      final error = body['error'] as Map;

      return ApiError(
        code: (error['code'] ?? 'http_error').toString(),
        message: (error['message'] ?? _fallbackMessage(statusCode)).toString(),
        details: _parseDetails(error['details']),
        statusCode: statusCode,
      );
    }

    return ApiError(code: 'http_error', message: _fallbackMessage(statusCode), statusCode: statusCode);
  }

  factory ApiError.fromDio(DioException exception) {
    final response = exception.response;

    if (response != null) {
      return ApiError.fromResponseBody(response.data, response.statusCode);
    }

    if (exception.error is ApiError) {
      return exception.error! as ApiError;
    }

    return switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const ApiError(code: networkTimeout, message: 'Koneksi lambat. Periksa jaringan lalu coba lagi.'),
      DioExceptionType.cancel => const ApiError(code: 'cancelled', message: 'Permintaan dibatalkan.'),
      _ => const ApiError(code: networkError, message: 'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.'),
    };
  }

  /// Error tak terduga (mis. respons tidak bisa dibaca) tetap tampil sebagai pesan Indonesia.
  factory ApiError.unexpected(Object error) {
    if (error is ApiError) {
      return error;
    }
    if (error is DioException) {
      return ApiError.fromDio(error);
    }

    return const ApiError(code: 'unexpected', message: 'Terjadi kesalahan. Coba lagi.');
  }

  static const networkError = 'network_error';
  static const networkTimeout = 'network_timeout';

  final String code;
  final String message;

  /// Pesan validasi per field, mis. `{'email': ['Email sudah dipakai.']}`.
  final Map<String, List<String>> details;

  final int? statusCode;

  bool get isNetwork => code == networkError || code == networkTimeout;

  bool get isValidation => code == 'validation_failed';

  bool get isUnauthenticated => statusCode == 401;

  /// Pesan pertama untuk sebuah field (untuk `errorText` TextField).
  String? fieldError(String field) {
    final messages = details[field];
    return messages == null || messages.isEmpty ? null : messages.first;
  }

  static Map<String, List<String>> _parseDetails(Object? raw) {
    if (raw is! Map) {
      return const {};
    }

    final result = <String, List<String>>{};
    raw.forEach((key, value) {
      if (value is List) {
        result[key.toString()] = value.map((item) => item.toString()).toList();
      } else if (value is String) {
        result[key.toString()] = [value];
      }
    });

    return result;
  }

  static String _fallbackMessage(int? statusCode) => switch (statusCode) {
        401 => 'Sesi berakhir. Silakan masuk lagi.',
        403 => 'Anda tidak berhak melakukan tindakan ini.',
        404 => 'Data tidak ditemukan.',
        429 => 'Terlalu banyak permintaan. Coba lagi sebentar lagi.',
        final code? when code >= 500 => 'Server sedang bermasalah. Coba lagi sebentar lagi.',
        _ => 'Terjadi kesalahan. Coba lagi.',
      };

  @override
  String toString() => 'ApiError($code, $statusCode): $message';
}

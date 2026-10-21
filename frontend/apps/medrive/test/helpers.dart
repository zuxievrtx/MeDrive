import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:medrive_core/medrive_core.dart';

/// Backend palsu di lapisan HTTP: [ApiClient] asli (header, amplop, ApiError) dengan adapter Dio
/// yang menjawab dari [handler]. Semua permintaan dicatat di [requests].
class FakeBackend implements HttpClientAdapter {
  FakeBackend(this.handler);

  final ResponseBody Function(RequestOptions request) handler;
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

  /// Override provider dasar agar seluruh aplikasi memakai backend palsu ini.
  List<Override> overrides({String? token}) {
    final tokens = MemoryTokenStorage(token);
    return [
      tokenStorageProvider.overrideWithValue(tokens),
      apiClientProvider.overrideWith((ref) {
        final client = ApiClient(config: testConfig, tokens: tokens, dio: Dio()..httpClientAdapter = this);
        ref.onDispose(client.dispose);
        return client;
      }),
    ];
  }
}

const testConfig = AppConfig(apiBaseUrl: 'http://api.test', wsUrl: 'ws://api.test', wsKey: 'key');

ResponseBody ok(Object? data, {int status = 200}) => _json({'success': true, 'data': data}, status);

ResponseBody apiError(String code, String message, int status, {Map<String, List<String>>? details}) => _json({
      'success': false,
      'error': {'code': code, 'message': message, 'details': ?details},
    }, status);

ResponseBody _json(Object body, int status) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

const reporterJson = <String, dynamic>{
  'id': 1,
  'name': 'Budi Santoso',
  'initials': 'BS',
  'phone': '081234567801',
  'email': 'budi@medrive.test',
  'role': {'value': 'pelapor', 'label': 'Pelapor'},
  'account_status': {'value': 'aktif', 'label': 'Aktif'},
  'must_change_password': false,
  'created_at': '2026-09-01T08:00:00+07:00',
};

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medrive_core/medrive_core.dart';

/// Adapter palsu: setiap permintaan dijawab oleh [handler] (atau melempar error jaringan).
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(Object body, int status) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

const config = AppConfig(apiBaseUrl: 'http://api.test', wsUrl: 'ws://api.test', wsKey: 'key');

void main() {
  late FakeAdapter adapter;
  late ApiClient client;

  ApiClient build(ResponseBody Function(RequestOptions options) handler, {String? token = 'secret'}) {
    adapter = FakeAdapter(handler);
    final dio = Dio()..httpClientAdapter = adapter;
    return client = ApiClient(config: config, tokens: MemoryTokenStorage(token), dio: dio);
  }

  test('sends JSON + Bearer headers and unwraps the success envelope', () async {
    build((_) => json({
          'success': true,
          'data': {'id': 1},
          'meta': {
            'pagination': {'current_page': 1, 'last_page': 3, 'per_page': 15, 'total': 40},
          },
        }, 200));

    final response = await client.get('/reporter/reports', query: {'page': 1, 'status': null});

    expect(response.data, {'id': 1});
    expect(response.pagination!.hasMore, isTrue);
    final request = adapter.requests.single;
    expect(request.uri.toString(), 'http://api.test/api/v1/reporter/reports?page=1');
    expect(request.headers['Accept'], 'application/json');
    expect(request.headers['Authorization'], 'Bearer secret');
  });

  test('maps validation errors with per-field details', () async {
    build((_) => json({
          'success': false,
          'error': {
            'code': 'validation_failed',
            'message': 'Data tidak valid.',
            'details': {
              'email': ['Email sudah dipakai.'],
            },
          },
        }, 400));

    final error = await client.post('/auth/register').then<ApiError?>((_) => null, onError: (Object e) => e as ApiError);

    expect(error!.isValidation, isTrue);
    expect(error.statusCode, 400);
    expect(error.message, 'Data tidak valid.');
    expect(error.fieldError('email'), 'Email sudah dipakai.');
    expect(error.fieldError('name'), isNull);
  });

  test('emits onUnauthorized when an authenticated request gets 401', () async {
    build((_) => json({
          'success': false,
          'error': {'code': 'unauthenticated', 'message': 'Sesi berakhir.'},
        }, 401));
    var fired = 0;
    client.onUnauthorized.listen((_) => fired++);

    await expectLater(client.get('/me'), throwsA(isA<ApiError>().having((e) => e.isUnauthenticated, 'unauthenticated', true)));
    await Future<void>.delayed(Duration.zero);
    expect(fired, 1);
  });

  test('does not emit onUnauthorized for a failed login without a token', () async {
    build(
      (_) => json({
        'success': false,
        'error': {'code': 'invalid_credentials', 'message': 'Email atau password salah.'},
      }, 401),
      token: null,
    );
    var fired = 0;
    client.onUnauthorized.listen((_) => fired++);

    await expectLater(client.post('/auth/login'), throwsA(isA<ApiError>()));
    await Future<void>.delayed(Duration.zero);
    expect(fired, 0);
  });

  test('retries a GET once after a network failure', () async {
    var calls = 0;
    build((options) {
      calls++;
      if (calls == 1) {
        throw DioException.connectionError(requestOptions: options, reason: 'offline');
      }
      return json({'success': true, 'data': 'ok'}, 200);
    });

    expect((await client.get('/me')).data, 'ok');
    expect(calls, 2);
  });

  test('does not retry a POST without an Idempotency-Key and reports a network error', () async {
    var calls = 0;
    build((options) {
      calls++;
      throw DioException.connectionError(requestOptions: options, reason: 'offline');
    });

    await expectLater(
      client.post('/reporter/reports/3/chat', data: {'type': 'text', 'body': 'Halo'}),
      throwsA(isA<ApiError>().having((e) => e.isNetwork, 'isNetwork', true)),
    );
    expect(calls, 1);
  });

  test('retries a POST carrying an Idempotency-Key once', () async {
    var calls = 0;
    build((options) {
      calls++;
      if (calls == 1) {
        throw DioException.connectionError(requestOptions: options, reason: 'offline');
      }
      return json({'success': true, 'data': {'id': 10}}, 201);
    });

    await client.post('/reporter/reports', data: {'a': 1}, headers: {ApiClient.idempotencyHeader: 'draft-1'});
    expect(calls, 2);
    expect(adapter.requests.last.headers[ApiClient.idempotencyHeader], 'draft-1');
  });

  test('maps timeouts and unknown bodies to Indonesian messages', () {
    final timeout = ApiError.fromDio(DioException(requestOptions: RequestOptions(), type: DioExceptionType.receiveTimeout));
    expect(timeout.code, ApiError.networkTimeout);
    expect(timeout.message, contains('Koneksi lambat'));

    final server = ApiError.fromResponseBody('<html>', 502);
    expect(server.message, 'Server sedang bermasalah. Coba lagi sebentar lagi.');
  });
}

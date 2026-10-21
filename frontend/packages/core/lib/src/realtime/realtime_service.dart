import 'dart:async';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';

enum RealtimeStatus { disconnected, connecting, connected }

typedef RealtimeHandler = void Function(Map<String, dynamic> data);

/// Koneksi WebSocket ke Laravel Reverb (protokol Pusher) dengan kanal privat yang diotorisasi
/// lewat `POST /api/v1/broadcasting/auth` memakai Bearer token Sanctum.
///
/// Satu koneksi dipakai bersama; tiap layar memanggil [subscribe] dan membatalkan
/// [RealtimeSubscription] saat ditutup. Kanal dilepas setelah pendengar terakhir pergi, dan
/// otomatis didaftarkan ulang saat koneksi tersambung kembali.
class RealtimeService {
  RealtimeService({required this._config, required this._tokens});

  final AppConfig _config;
  final TokenStorage _tokens;

  PusherChannelsClient? _client;
  StreamSubscription<PusherChannelsClientLifeCycleState>? _lifecycle;
  final _channels = <String, _ChannelEntry>{};
  final status = ValueNotifier<RealtimeStatus>(RealtimeStatus.disconnected);

  bool get isConnected => status.value == RealtimeStatus.connected;

  /// Mulai koneksi (idempoten). Aman dipanggil berulang.
  Future<void> connect() async {
    if (_client != null) {
      return;
    }

    final uri = Uri.parse(_config.wsUrl);
    final options = PusherChannelsOptions.fromHost(
      scheme: uri.scheme == 'https' || uri.scheme == 'wss' ? 'wss' : 'ws',
      host: uri.host,
      port: uri.hasPort ? uri.port : (uri.scheme == 'wss' || uri.scheme == 'https' ? 443 : 80),
      key: _config.wsKey,
      shouldSupplyMetadataQueries: true,
      metadata: const PusherChannelsOptionsMetadata.byDefault(),
    );

    final client = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (exception, trace, refresh) => refresh(),
      minimumReconnectDelayDuration: const Duration(seconds: 2),
    );
    _client = client;
    status.value = RealtimeStatus.connecting;

    _lifecycle = client.lifecycleStream.listen((state) {
      switch (state) {
        case PusherChannelsClientLifeCycleState.establishedConnection:
          status.value = RealtimeStatus.connected;
          for (final entry in _channels.values) {
            entry.channel.subscribeIfNotUnsubscribed();
          }
        case PusherChannelsClientLifeCycleState.pendingConnection:
        case PusherChannelsClientLifeCycleState.reconnecting:
          status.value = RealtimeStatus.connecting;
        default:
          status.value = RealtimeStatus.disconnected;
      }
    });

    unawaited(client.connect());
  }

  /// Dengarkan event di kanal privat. [channelName] tanpa awalan `private-`, mis. `report.12`.
  Future<RealtimeSubscription> subscribe(
    String channelName,
    Map<String, RealtimeHandler> handlers, {
    VoidCallback? onAuthFailed,
  }) async {
    await connect();
    final client = _client!;
    final token = await _tokens.read();
    final name = 'private-$channelName';

    final entry = _channels.putIfAbsent(name, () {
      final channel = client.privateChannel(
        name,
        authorizationDelegate: EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
          authorizationEndpoint: Uri.parse(_config.broadcastingAuthUrl),
          headers: {'Accept': 'application/json', if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
      return _ChannelEntry(channel);
    });

    final subscriptions = <StreamSubscription<Object?>>[
      for (final handler in handlers.entries)
        entry.channel.bind(handler.key).listen((event) => handler.value(event.tryGetDataAsMap() ?? const {})),
      if (onAuthFailed != null) entry.channel.onAuthenticationSubscriptionFailed().listen((_) => onAuthFailed()),
    ];

    entry.listeners++;
    if (isConnected) {
      entry.channel.subscribeIfNotUnsubscribed();
    }

    return RealtimeSubscription._(() {
      for (final subscription in subscriptions) {
        unawaited(subscription.cancel());
      }
      entry.listeners--;
      if (entry.listeners <= 0) {
        entry.channel.unsubscribe();
        _channels.remove(name);
      }
    });
  }

  /// Putuskan koneksi dan lepas semua kanal (dipakai saat logout).
  Future<void> disconnect() async {
    for (final entry in _channels.values) {
      entry.channel.unsubscribe();
    }
    _channels.clear();
    await _lifecycle?.cancel();
    _lifecycle = null;
    _client?.dispose();
    _client = null;
    status.value = RealtimeStatus.disconnected;
  }
}

class _ChannelEntry {
  _ChannelEntry(this.channel);

  final PrivateChannel channel;
  int listeners = 0;
}

class RealtimeSubscription {
  RealtimeSubscription._(this._cancel);

  final VoidCallback _cancel;
  bool _cancelled = false;

  void cancel() {
    if (_cancelled) {
      return;
    }
    _cancelled = true;
    _cancel();
  }
}

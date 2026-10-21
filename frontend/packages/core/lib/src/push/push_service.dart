import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/app_config.dart';

/// Data notifikasi yang relevan untuk navigasi (`type`, `report_id`, ...).
class PushPayload {
  const PushPayload(this.data);

  final Map<String, String> data;

  String? get type => data['type'];

  int? get reportId => int.tryParse(data['report_id'] ?? '');
}

/// FCM + notifikasi lokal. Semua langkah dibungkus try-catch: tanpa google-services.json atau
/// opsi Firebase dari `--dart-define`, aplikasi tetap berjalan, hanya tanpa push.
class PushService {
  PushService({required this._config});

  final AppConfig _config;
  final _local = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<PushPayload>.broadcast();
  StreamSubscription<String>? _tokenRefresh;
  bool _available = false;

  static const _channel = AndroidNotificationChannel(
    'medrive_reports',
    'Status laporan & chat',
    description: 'Perubahan status laporan dan pesan dari driver ambulans.',
    importance: Importance.high,
  );

  /// Firebase berhasil diinisialisasi.
  bool get isAvailable => _available;

  /// Notifikasi yang diketuk pengguna (dari background, terminated, atau foreground).
  Stream<PushPayload> get onTap => _taps.stream;

  Future<void> initialize() async {
    try {
      final firebase = _config.firebase;
      await Firebase.initializeApp(
        options: firebase == null
            ? null
            : FirebaseOptions(
                apiKey: firebase.apiKey,
                appId: firebase.appId,
                messagingSenderId: firebase.messagingSenderId,
                projectId: firebase.projectId,
              ),
      );
      _available = true;
    } catch (error) {
      debugPrint('FCM tidak aktif (konfigurasi Firebase tidak ditemukan): $error');
      _available = false;
      return;
    }

    try {
      await _local.initialize(
        settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null) {
            _taps.add(PushPayload(Map<String, String>.from(jsonDecode(payload) as Map)));
          }
        },
      );
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      FirebaseMessaging.onMessage.listen(_showForeground);
      FirebaseMessaging.onMessageOpenedApp.listen((message) => _taps.add(_payload(message)));

      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        // Ditunda agar router sempat siap sebelum navigasi deep-link.
        Future<void>.delayed(const Duration(milliseconds: 600), () => _taps.add(_payload(initial)));
      }
    } catch (error) {
      debugPrint('Inisialisasi notifikasi gagal: $error');
    }
  }

  /// Minta izin notifikasi (Android 13+) lalu kirim token FCM ke backend lewat [register].
  Future<void> registerToken(Future<void> Function(String token) register) async {
    if (!_available) {
      return;
    }

    try {
      await FirebaseMessaging.instance.requestPermission();
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Backend mengirim lewat FCM HTTP v1 `message.token`, yang membutuhkan registration token,
      // bukan Firebase Installation ID dari API register()/onRegistered.
      // ignore: deprecated_member_use
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await register(token);
      }

      await _tokenRefresh?.cancel();
      // ignore: deprecated_member_use
      _tokenRefresh = FirebaseMessaging.instance.onTokenRefresh.listen((token) => unawaited(register(token)));
    } catch (error) {
      debugPrint('Registrasi token FCM gagal: $error');
    }
  }

  Future<void> unregister() async {
    await _tokenRefresh?.cancel();
    _tokenRefresh = null;
    if (!_available) {
      return;
    }
    try {
      // ignore: deprecated_member_use
      await FirebaseMessaging.instance.deleteToken();
    } catch (error) {
      debugPrint('Gagal menghapus token FCM: $error');
    }
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    await _local.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(_payload(message).data),
    );
  }

  PushPayload _payload(RemoteMessage message) =>
      PushPayload(message.data.map((key, value) => MapEntry(key, value.toString())));
}

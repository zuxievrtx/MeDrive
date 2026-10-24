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

/// Pesan FCM yang diterima saat aplikasi di depan. Kembalikan `true` bila aplikasi sudah
/// menanganinya sendiri (mis. layar tawaran dispatch), sehingga notifikasi bawaan tidak ditampilkan.
typedef ForegroundPushHandler = bool Function(PushPayload payload);

/// FCM + notifikasi lokal. Semua langkah dibungkus try-catch: tanpa google-services.json atau
/// opsi Firebase dari `--dart-define`, aplikasi tetap berjalan, hanya tanpa push. Notifikasi lokal
/// tetap disiapkan walau Firebase tidak aktif (dipakai alarm tawaran di aplikasi driver).
class PushService {
  PushService({
    required this._config,
    this.channel = defaultChannel,
    this.extraChannels = const [],
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : local = localNotifications ?? FlutterLocalNotificationsPlugin();

  final AppConfig _config;

  /// Kanal notifikasi untuk push yang ditampilkan saat aplikasi di depan.
  final AndroidNotificationChannel channel;

  /// Kanal tambahan yang dibuat saat inisialisasi (mis. alarm tawaran driver).
  final List<AndroidNotificationChannel> extraChannels;

  /// Plugin notifikasi lokal bersama; ketukan pada notifikasi apa pun yang membawa payload JSON
  /// diteruskan ke [onTap].
  final FlutterLocalNotificationsPlugin local;

  final _taps = StreamController<PushPayload>.broadcast();
  StreamSubscription<String>? _tokenRefresh;
  bool _available = false;
  bool _localReady = false;

  /// Penangan pesan saat aplikasi di depan (opsional).
  ForegroundPushHandler? onForegroundMessage;

  static const defaultChannel = AndroidNotificationChannel(
    'medrive_reports',
    'Status laporan & chat',
    description: 'Perubahan status laporan dan pesan dari driver ambulans.',
    importance: Importance.high,
  );

  /// Firebase berhasil diinisialisasi.
  bool get isAvailable => _available;

  /// Notifikasi lokal siap dipakai.
  bool get isLocalReady => _localReady;

  /// Notifikasi yang diketuk pengguna (dari background, terminated, atau foreground).
  Stream<PushPayload> get onTap => _taps.stream;

  Future<void> initialize() async {
    await _initializeLocal();

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
      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen((message) => _taps.add(_payload(message)));

      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        // Ditunda agar router sempat siap sebelum navigasi deep-link.
        _emitLater(_payload(initial));
      }
    } catch (error) {
      debugPrint('Inisialisasi FCM gagal: $error');
    }
  }

  Future<void> _initializeLocal() async {
    try {
      await local.initialize(
        settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
        onDidReceiveNotificationResponse: (response) {
          final payload = _decode(response.payload);
          if (payload != null) {
            _taps.add(payload);
          }
        },
      );
      final android = local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      for (final item in [channel, ...extraChannels]) {
        await android?.createNotificationChannel(item);
      }
      _localReady = true;

      // Aplikasi dibuka dari notifikasi lokal (mis. full-screen intent tawaran saat layar terkunci).
      final launch = await local.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        final payload = _decode(launch!.notificationResponse?.payload);
        if (payload != null) {
          _emitLater(payload);
        }
      }
    } catch (error) {
      debugPrint('Inisialisasi notifikasi lokal gagal: $error');
    }
  }

  void _emitLater(PushPayload payload) {
    Future<void>.delayed(const Duration(milliseconds: 600), () => _taps.add(payload));
  }

  static PushPayload? _decode(String? payload) {
    if (payload == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map ? PushPayload(decoded.map((key, value) => MapEntry('$key', '$value'))) : null;
    } on FormatException {
      return null;
    }
  }

  /// Minta izin notifikasi (Android 13+) lalu kirim token FCM ke backend lewat [register].
  Future<void> registerToken(Future<void> Function(String token) register) async {
    if (!_available) {
      return;
    }

    try {
      await FirebaseMessaging.instance.requestPermission();
      await local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

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

  Future<void> _onForeground(RemoteMessage message) async {
    final payload = _payload(message);
    if (onForegroundMessage?.call(payload) ?? false) {
      return;
    }
    await _showForeground(message, payload);
  }

  Future<void> _showForeground(RemoteMessage message, PushPayload payload) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    await local.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(payload.data),
    );
  }

  PushPayload _payload(RemoteMessage message) =>
      PushPayload(message.data.map((key, value) => MapEntry(key, value.toString())));
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medrive_core/medrive_core.dart';

import 'dispatch_alarm.dart';

/// Push FCM saat aplikasi di background/terminated (isolate terpisah). Untuk tawaran dispatch,
/// tampilkan alarm full-screen agar muncul walau layar terkunci. Pesan lain cukup ditampilkan
/// sistem dari payload `notification` FCM.
@pragma('vm:entry-point')
Future<void> driverBackgroundMessageHandler(RemoteMessage message) async {
  final data = message.data.map((key, value) => MapEntry(key, '$value'));
  final offer = DispatchOffer.fromPushData(data);
  if (offer == null) {
    return;
  }

  try {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
    await plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(dispatchChannel);
    await showDispatchAlarm(
      plugin,
      dispatchId: offer.dispatchId,
      data: data,
      title: message.notification?.title,
      body: message.notification?.body,
    );
  } on Object {
    // Notifikasi sistem dari payload FCM tetap tampil sebagai cadangan.
  }
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medrive_core/medrive_core.dart';

/// Kanal tawaran laporan: prioritas tertinggi, nada alarm (bukan nada notifikasi), getar panjang.
/// Kanal Android tidak bisa diubah setelah dibuat, jadi id-nya berversi.
final dispatchChannel = AndroidNotificationChannel(
  'medriver_dispatch_v1',
  'Tawaran laporan darurat',
  description: 'Alarm berulang saat ada laporan darurat yang ditawarkan ke ambulans Anda.',
  importance: Importance.max,
  sound: const UriAndroidNotificationSound('content://settings/system/alarm_alert'),
  audioAttributesUsage: AudioAttributesUsage.alarm,
  vibrationPattern: Int64List.fromList([0, 800, 400, 800, 400, 800]),
  bypassDnd: true,
);

/// Kanal status/chat biasa untuk aplikasi driver.
const driverChannel = AndroidNotificationChannel(
  'medriver_updates',
  'Chat & pembaruan misi',
  description: 'Pesan dari pelapor dan pembaruan laporan yang Anda tangani.',
  importance: Importance.high,
);

/// Batas bunyi alarm. Ronde broadcast paling lama 5 menit; setelah itu tawaran sudah kedaluwarsa.
const _alarmTimeout = Duration(minutes: 3);

/// FLAG_INSISTENT Android: suara & getar diulang sampai notifikasi dibuka/dibatalkan.
const _flagInsistent = 4;

int dispatchNotificationId(int dispatchId) => 700000 + dispatchId % 100000;

/// Tampilkan alarm tawaran: full-screen intent (muncul di atas layar kunci), suara alarm berulang,
/// dan getar. Dipakai dari foreground maupun background handler FCM.
Future<void> showDispatchAlarm(
  FlutterLocalNotificationsPlugin plugin, {
  required int dispatchId,
  required Map<String, String> data,
  String? title,
  String? body,
}) =>
    plugin.show(
      id: dispatchNotificationId(dispatchId),
      title: title ?? 'Laporan darurat masuk',
      body: body ?? 'Ketuk untuk melihat dan menerima tawaran.',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          dispatchChannel.id,
          dispatchChannel.name,
          channelDescription: dispatchChannel.description,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          visibility: NotificationVisibility.public,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          sound: dispatchChannel.sound,
          vibrationPattern: dispatchChannel.vibrationPattern,
          additionalFlags: Int32List.fromList([_flagInsistent]),
          ongoing: true,
          autoCancel: false,
          timeoutAfter: _alarmTimeout.inMilliseconds,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(data),
    );

/// Alarm tawaran di dalam aplikasi. Diganti versi senyap di widget test.
class DispatchAlarm {
  DispatchAlarm(this._push);

  final PushService _push;

  Future<void> start(Dispatch dispatch) async {
    await HapticFeedback.heavyImpact();
    if (!_push.isLocalReady) {
      return;
    }
    final report = dispatch.report;
    try {
      await showDispatchAlarm(
        _push.local,
        dispatchId: dispatch.id,
        data: {
          'type': 'dispatch',
          'dispatch_id': '${dispatch.id}',
          'report_id': '${dispatch.reportId}',
          if (report != null) 'report_code': report.code,
        },
        title: 'Laporan darurat: ${report?.typeName ?? 'laporan baru'}',
        body: report?.shortAddress ?? report?.address,
      );
    } on Object {
      // Tanpa izin notifikasi alarm tidak berbunyi; layar tawaran tetap tampil.
    }
  }

  Future<void> stop(int dispatchId) async {
    if (!_push.isLocalReady) {
      return;
    }
    try {
      await _push.local.cancel(id: dispatchNotificationId(dispatchId));
    } on Object {
      // Notifikasi sudah hilang.
    }
  }
}

final dispatchAlarmProvider = Provider<DispatchAlarm>((ref) => DispatchAlarm(ref.watch(pushServiceProvider)));

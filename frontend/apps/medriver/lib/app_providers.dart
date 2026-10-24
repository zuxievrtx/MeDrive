import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:medrive_core/medrive_core.dart';

import 'services/dispatch_alarm.dart';

/// Override provider bersama `medrive_core` untuk aplikasi driver: role driver (prefix
/// `/driver/...`, tolak akun pelapor) dan kanal notifikasi driver (alarm tawaran + pembaruan).
final List<Override> driverOverrides = [
  appRoleProvider.overrideWithValue(AppRole.driver),
  pushServiceProvider.overrideWith(
    (ref) => PushService(
      config: ref.watch(appConfigProvider),
      channel: driverChannel,
      extraChannels: [dispatchChannel],
    ),
  ),
];

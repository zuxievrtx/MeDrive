import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initMedFormats();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final container = ProviderContainer(
    // Error API ditampilkan ke pengguna dengan tombol coba lagi, bukan diulang diam-diam.
    retry: (retryCount, error) => null,
  );
  unawaited(container.read(pushServiceProvider).initialize());

  runApp(UncontrolledProviderScope(container: container, child: const MedriveApp()));
}

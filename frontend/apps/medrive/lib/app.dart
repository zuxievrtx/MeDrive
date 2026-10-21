import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import 'router.dart';
import 'widgets/connection_banner.dart';

class MedriveApp extends ConsumerStatefulWidget {
  const MedriveApp({super.key});

  @override
  ConsumerState<MedriveApp> createState() => _MedriveAppState();
}

class _MedriveAppState extends ConsumerState<MedriveApp> {
  StreamSubscription<PushPayload>? _pushTaps;

  @override
  void initState() {
    super.initState();
    _pushTaps = ref.read(pushServiceProvider).onTap.listen(_openFromPush);
  }

  @override
  void dispose() {
    unawaited(_pushTaps?.cancel());
    super.dispose();
  }

  /// Notifikasi diketuk: chat → layar chat, status → pelacakan/detail laporan.
  void _openFromPush(PushPayload payload) {
    final reportId = payload.reportId;
    if (reportId == null) {
      return;
    }
    final router = ref.read(routerProvider);
    router.push(payload.type == 'chat' ? Routes.chat(reportId) : Routes.tracking(reportId));
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MeDrive',
      debugShowCheckedModeBanner: false,
      theme: buildMedTheme(),
      themeMode: ThemeMode.light,
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: router,
      builder: (context, child) => ConnectionBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}

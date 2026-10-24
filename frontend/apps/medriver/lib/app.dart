import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import 'router.dart';
import 'services/location_ping.dart';
import 'state/dispatch_state.dart';
import 'state/driver_state.dart';
import 'state/session.dart';
import 'widgets/connection_banner.dart';

class MedriverApp extends ConsumerStatefulWidget {
  const MedriverApp({super.key});

  @override
  ConsumerState<MedriverApp> createState() => _MedriverAppState();
}

class _MedriverAppState extends ConsumerState<MedriverApp> {
  /// Tarik tawaran berkala selama standby di depan layar (cadangan bila FCM terlewat).
  static const _standbyPull = Duration(seconds: 20);

  StreamSubscription<PushPayload>? _pushTaps;
  StreamSubscription<int>? _offerRequests;
  late final AppLifecycleListener _lifecycle;
  Timer? _pullTimer;
  bool _resumed = true;

  @override
  void initState() {
    super.initState();
    final push = ref.read(pushServiceProvider);
    _pushTaps = push.onTap.listen(_openFromPush);
    push.onForegroundMessage = _onForegroundPush;
    _offerRequests = ref.read(dispatchProvider.notifier).openRequests.listen(_openOffer);
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _resumed = true;
        _syncOnResume();
      },
      onPause: () => _resumed = false,
    );
    _pullTimer = Timer.periodic(_standbyPull, (_) {
      if (_resumed && _signedIn) {
        unawaited(ref.read(dispatchProvider.notifier).pull());
      }
    });
  }

  @override
  void dispose() {
    unawaited(_pushTaps?.cancel());
    unawaited(_offerRequests?.cancel());
    ref.read(pushServiceProvider).onForegroundMessage = null;
    _pullTimer?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  bool get _signedIn {
    final session = ref.read(sessionProvider);
    return session.status == SessionStatus.authenticated && !session.mustChangePassword;
  }

  /// Aplikasi kembali ke depan: jangan andalkan push, tarik ulang status & tawaran.
  void _syncOnResume() {
    if (!_signedIn) {
      return;
    }
    unawaited(() async {
      // Antrean lokasi offline langsung dicoba kirim begitu aplikasi aktif lagi.
      final ping = ref.read(locationPingProvider);
      if (ping.isRunning) {
        unawaited(ping.flush());
      }
      await ref.read(driverProvider.notifier).refresh();
      await ref.read(dispatchProvider.notifier).pull();
    }());
  }

  /// Push saat aplikasi di depan: tawaran langsung membuka layar penuh (alarm dibunyikan layar itu).
  bool _onForegroundPush(PushPayload payload) {
    final offer = DispatchOffer.fromPushData(payload.data);
    if (offer == null) {
      return false;
    }
    ref.read(dispatchProvider.notifier).open(offer.dispatchId);
    return true;
  }

  void _openFromPush(PushPayload payload) {
    final offer = DispatchOffer.fromPushData(payload.data);
    if (offer != null) {
      ref.read(dispatchProvider.notifier).open(offer.dispatchId);
      return;
    }
    final reportId = payload.reportId;
    if (reportId == null || !_signedIn) {
      return;
    }
    final router = ref.read(routerProvider);
    unawaited(router.push(payload.type == 'chat' ? Routes.chat(reportId) : Routes.mission(reportId)));
  }

  void _openOffer(int dispatchId) {
    if (!_signedIn) {
      return;
    }
    unawaited(ref.read(routerProvider).push(Routes.offer(dispatchId)));
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    // Profil driver pertama kali termuat: langsung periksa tawaran yang mungkin terlewat.
    ref.listen(driverProvider, (previous, next) {
      if (previous?.hasValue != true && next.hasValue) {
        unawaited(ref.read(dispatchProvider.notifier).pull());
      }
    });

    return MaterialApp.router(
      title: 'MeDriveR',
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

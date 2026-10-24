import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'features/auth/force_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/chat/chat_list_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/history/history_detail_screen.dart';
import 'features/history/history_screen.dart';
import 'features/home/home_screen.dart';
import 'features/mission/handling_photos_screen.dart';
import 'features/mission/mission_screen.dart';
import 'features/mission/patients_screen.dart';
import 'features/offer/offer_screen.dart';
import 'features/profile/profile_screen.dart';
import 'state/session.dart';

abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const forcePassword = '/force-password';
  static const home = '/home';
  static const chats = '/chat';
  static const profile = '/profile';
  static const history = '/history';

  static String offer(int dispatchId) => '/offer/$dispatchId';
  static String mission(int reportId) => '/mission/$reportId';
  static String patients(int reportId) => '/mission/$reportId/patients';
  static String photos(int reportId) => '/mission/$reportId/photos';
  static String chat(int reportId) => '/chat/$reportId';
  static String historyDetail(int reportId) => '/history/$reportId';
}

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier<SessionState>(ref.read(sessionProvider));
  ref.listen(sessionProvider, (_, next) => session.value = next);

  int id(GoRouterState state) => int.parse(state.pathParameters['id']!);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: session,
    redirect: (context, state) => _redirect(session.value, state.matchedLocation),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.forcePassword, builder: (_, _) => const ForcePasswordScreen()),
      GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/offer/:id',
        pageBuilder: (_, state) => MaterialPage<void>(fullscreenDialog: true, child: OfferScreen(dispatchId: id(state))),
      ),
      GoRoute(
        path: '/mission/:id',
        builder: (_, state) => MissionScreen(reportId: id(state)),
        routes: [
          GoRoute(path: 'patients', builder: (_, state) => PatientsScreen(reportId: id(state))),
          GoRoute(path: 'photos', builder: (_, state) => HandlingPhotosScreen(reportId: id(state))),
        ],
      ),
      GoRoute(
        path: Routes.chats,
        builder: (_, _) => const ChatListScreen(),
        routes: [GoRoute(path: ':id', builder: (_, state) => ChatScreen(reportId: id(state)))],
      ),
      GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen()),
      GoRoute(
        path: Routes.history,
        builder: (_, _) => const HistoryScreen(),
        routes: [GoRoute(path: ':id', builder: (_, state) => HistoryDetailScreen(reportId: id(state)))],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    session.dispose();
  });
  return router;
});

String? _redirect(SessionState session, String location) {
  switch (session.status) {
    case SessionStatus.unknown:
      return location == Routes.splash ? null : Routes.splash;
    case SessionStatus.unauthenticated:
      return location == Routes.login ? null : Routes.login;
    case SessionStatus.authenticated:
      if (session.mustChangePassword) {
        return location == Routes.forcePassword ? null : Routes.forcePassword;
      }
      if (location == Routes.splash || location == Routes.forcePassword || location == Routes.login) {
        return Routes.home;
      }
      return null;
  }
}

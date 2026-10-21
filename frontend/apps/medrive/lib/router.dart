import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'features/auth/force_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/welcome_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/history/history_screen.dart';
import 'features/home/home_screen.dart';
import 'features/home/location_picker_screen.dart';
import 'features/profile/change_password_screen.dart';
import 'features/profile/edit_profile_screen.dart';
import 'features/profile/help_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/profile/security_screen.dart';
import 'features/report/report_detail_screen.dart';
import 'features/report/report_form_screen.dart';
import 'features/report/report_success_screen.dart';
import 'features/tracking/tracking_screen.dart';
import 'state/session.dart';
import 'widgets/main_shell.dart';

abstract final class Routes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const forcePassword = '/force-password';
  static const home = '/home';
  static const history = '/history';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const security = '/profile/security';
  static const changePassword = '/profile/security/password';
  static const help = '/profile/help';
  static const pickLocation = '/pick-location';

  static String newReport(String typeCode) => '/report/new/$typeCode';
  static String reportSuccess(int id) => '/report/$id/success';
  static String reportDetail(int id) => '/report/$id';
  static String tracking(int id) => '/report/$id/track';
  static String chat(int id) => '/report/$id/chat';

  static const _public = {welcome, login, register};
}

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier<SessionState>(ref.read(sessionProvider));
  ref.listen(sessionProvider, (_, next) => session.value = next);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: session,
    redirect: (context, state) => _redirect(session.value, state.matchedLocation),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(path: Routes.forcePassword, builder: (_, _) => const ForcePasswordScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.history, builder: (_, _) => const HistoryScreen())]),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(path: 'edit', parentNavigatorKey: _rootKey, builder: (_, _) => const EditProfileScreen()),
                  GoRoute(
                    path: 'security',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const SecurityScreen(),
                    routes: [
                      GoRoute(path: 'password', parentNavigatorKey: _rootKey, builder: (_, _) => const ChangePasswordScreen()),
                    ],
                  ),
                  GoRoute(path: 'help', parentNavigatorKey: _rootKey, builder: (_, _) => const HelpScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: Routes.pickLocation, builder: (_, _) => const LocationPickerScreen()),
      GoRoute(
        path: '/report/new/:type',
        builder: (_, state) => ReportFormScreen(typeCode: state.pathParameters['type']!),
      ),
      GoRoute(
        path: '/report/:id',
        builder: (_, state) => ReportDetailScreen(reportId: int.parse(state.pathParameters['id']!)),
        routes: [
          GoRoute(path: 'success', builder: (_, state) => ReportSuccessScreen(reportId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: 'track', builder: (_, state) => TrackingScreen(reportId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: 'chat', builder: (_, state) => ChatScreen(reportId: int.parse(state.pathParameters['id']!))),
        ],
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
      return Routes._public.contains(location) ? null : Routes.welcome;
    case SessionStatus.authenticated:
      if (session.mustChangePassword) {
        return location == Routes.forcePassword ? null : Routes.forcePassword;
      }
      if (location == Routes.splash || location == Routes.forcePassword || Routes._public.contains(location)) {
        return Routes.home;
      }
      return null;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
import 'config/app_config.dart';
import 'push/push_service.dart';
import 'realtime/realtime_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/chat_repository.dart';
import 'repositories/geocode_repository.dart';
import 'repositories/report_repository.dart';
import 'storage/token_storage.dart';

/// Provider dasar yang dipakai bersama aplikasi pelapor dan driver. Test meng-override
/// [apiClientProvider] atau repository-nya.
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

final tokenStorageProvider = Provider<TokenStorage>((ref) => SecureTokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(config: ref.watch(appConfigProvider), tokens: ref.watch(tokenStorageProvider));
  ref.onDispose(client.dispose);
  return client;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider), ref.watch(tokenStorageProvider)),
);

final reportRepositoryProvider = Provider<ReportRepository>((ref) => ReportRepository(ref.watch(apiClientProvider)));

final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository(ref.watch(apiClientProvider)));

final geocodeRepositoryProvider = Provider<GeocodeRepository>((ref) => GeocodeRepository(ref.watch(apiClientProvider)));

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final service = RealtimeService(config: ref.watch(appConfigProvider), tokens: ref.watch(tokenStorageProvider));
  ref.onDispose(service.disconnect);
  return service;
});

final pushServiceProvider = Provider<PushService>((ref) => PushService(config: ref.watch(appConfigProvider)));

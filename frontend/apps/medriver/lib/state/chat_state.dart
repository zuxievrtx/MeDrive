import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medrive_core/medrive_core.dart';

import '../widgets/connection_banner.dart';

/// Jumlah pesan belum dibaca per laporan (`GET /driver/chat/unread-count`) untuk badge side menu,
/// daftar chat, dan tombol Chat di layar misi.
final unreadProvider = FutureProvider.autoDispose<UnreadSummary>((ref) {
  ref.watch(retryTickProvider);
  return ref.watch(chatRepositoryProvider).unreadCount();
});

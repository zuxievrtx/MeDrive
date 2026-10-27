import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medrive_core/medrive_core.dart';

import '../../widgets/connection_banner.dart';

/// Laporan untuk judul chat & riwayat (`GET /driver/reports/{id}`), juga untuk laporan yang sudah
/// selesai (riwayat chat tetap bisa dibaca).
final chatReportProvider = FutureProvider.autoDispose.family<Report, int>((ref, id) {
  ref.watch(retryTickProvider);
  return ref.watch(driverRepositoryProvider).report(id);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medrive_core/medrive_core.dart';

import '../../widgets/connection_banner.dart';

final reportTypesProvider = FutureProvider<List<ReportType>>((ref) {
  ref.watch(retryTickProvider);
  return ref.watch(reportRepositoryProvider).reportTypes();
});

/// Laporan terbaru yang belum selesai (menunggu atau sedang ditangani) untuk kartu "Lacak" di beranda.
final activeReportProvider = FutureProvider.autoDispose<Report?>((ref) async {
  ref.watch(retryTickProvider);
  final page = await ref.watch(reportRepositoryProvider).list();
  for (final report in page.items) {
    if (!report.isClosed) {
      return report;
    }
  }
  return null;
});

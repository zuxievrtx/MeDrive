import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medrive_core/medrive_core.dart';

import '../../widgets/connection_banner.dart';

/// Detail satu laporan (`GET /reporter/reports/{id}`).
final reportDetailProvider = FutureProvider.autoDispose.family<Report, int>((ref, id) {
  ref.watch(retryTickProvider);
  return ref.watch(reportRepositoryProvider).detail(id);
});

/// Jenis laporan berdasarkan kode (data server atau bawaan).
final reportTypeByCodeProvider = FutureProvider.autoDispose.family<ReportType, String>((ref, code) async {
  final types = await ref.watch(reportRepositoryProvider).reportTypes();
  return types.firstWhere(
    (type) => type.code == code,
    orElse: () => throw const ApiError(code: 'not_found', message: 'Jenis laporan tidak dikenal.'),
  );
});

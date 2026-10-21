import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Format tanggal & angka Indonesia. Panggil [initMedFormats] sekali sebelum `runApp`.
Future<void> initMedFormats() async {
  Intl.defaultLocale = 'id_ID';
  await initializeDateFormatting('id_ID');
}

/// `21 Okt 2026 · 10.15`
String formatDateTime(DateTime? value) {
  if (value == null) {
    return '-';
  }
  final local = value.toLocal();
  return '${DateFormat('dd MMM yyyy', 'id_ID').format(local)} · ${DateFormat('HH:mm', 'id_ID').format(local)}';
}

String formatTime(DateTime? value) => value == null ? '-' : DateFormat('HH:mm', 'id_ID').format(value.toLocal());

String formatDay(DateTime? value) => value == null ? '-' : DateFormat('dd MMM yyyy', 'id_ID').format(value.toLocal());

/// `3,5 km` / `850 m`
String formatDistance(double km) =>
    km < 1 ? '${(km * 1000).round()} m' : '${NumberFormat('#,##0.0', 'id_ID').format(km)} km';

/// `7 menit`, `1 jam 5 menit`. Di bawah 1 menit ditulis "< 1 menit".
String formatDuration(double minutes) {
  if (minutes < 1) {
    return '< 1 menit';
  }
  final total = minutes.round();
  if (total < 60) {
    return '$total menit';
  }
  final hours = total ~/ 60;
  final rest = total % 60;
  return rest == 0 ? '$hours jam' : '$hours jam $rest menit';
}

/// "baru saja", "5 menit lalu", lalu tanggal lengkap.
String formatRelative(DateTime? value, {DateTime? now}) {
  if (value == null) {
    return '-';
  }
  final diff = (now ?? DateTime.now()).difference(value);
  if (diff.inSeconds < 45) {
    return 'baru saja';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} menit lalu';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} jam lalu';
  }
  return formatDateTime(value);
}

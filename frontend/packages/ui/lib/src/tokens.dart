import 'package:material_ui/material_ui.dart';

/// Token warna MeDrive. Merah utama diambil dari logo & Figma; merah tua satu keluarga dengan
/// aksen dashboard admin (#B30000) dipakai untuk teks kecil dan state ditekan.
abstract final class MedColors {
  static const brand = Color(0xFFE2062C);
  static const brandDeep = Color(0xFFB30000);
  static const brandSoft = Color(0xFFFDE8EC);

  static const ink = Color(0xFF1C1917);
  static const inkMuted = Color(0xFF57534E);
  static const inkFaint = Color(0xFF6B6560);
  static const line = Color(0xFFE7E5E4);
  static const field = Color(0xFFF1F0EE);
  static const surface = Color(0xFFFFFFFF);
  static const canvas = Color(0xFFF8F7F5);

  static const success = Color(0xFF15803D);
  static const warning = Color(0xFFB45309);
  static const info = Color(0xFF1D4ED8);
}

/// Warna status laporan, sama dengan badge dashboard admin.
class StatusTone {
  const StatusTone(this.background, this.foreground);

  final Color background;
  final Color foreground;

  static const _tones = <String, StatusTone>{
    'menunggu': StatusTone(Color(0xFFFEF3C7), Color(0xFF92400E)),
    'diambil': StatusTone(Color(0xFFDBEAFE), Color(0xFF1E40AF)),
    'dalam_perjalanan': StatusTone(Color(0xFFEDE9FE), Color(0xFF5B21B6)),
    'tiba_di_lokasi': StatusTone(Color(0xFFCFFAFE), Color(0xFF155E75)),
    'mengantar_pasien': StatusTone(Color(0xFFCCFBF1), Color(0xFF115E59)),
    'selesai': StatusTone(Color(0xFFDCFCE7), Color(0xFF166534)),
    'dibatalkan': StatusTone(Color(0xFFE7E5E4), Color(0xFF44403C)),
  };

  static StatusTone of(String status) => _tones[status] ?? const StatusTone(Color(0xFFE7E5E4), Color(0xFF44403C));
}

abstract final class MedSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Margin samping layar.
  static const gutter = 20.0;
}

abstract final class MedRadius {
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 20.0;

  /// Lembar putih di bawah header merah (Figma: sudut atas sangat membulat).
  static const sheet = 36.0;

  /// Tombol & field berbentuk pil seperti Figma.
  static const pill = 999.0;
}

/// Warna hex dari database (`report_types.color`).
Color colorFromHex(String? hex, {Color fallback = MedColors.brand}) {
  if (hex == null) {
    return fallback;
  }
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(cleaned.length == 6 ? 'FF$cleaned' : cleaned, radix: 16);
  return value == null ? fallback : Color(value);
}

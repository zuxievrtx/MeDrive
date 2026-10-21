import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// Kartu putih dengan garis tipis. Bayangan hanya dipakai bila kartu mengambang di atas peta.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(MedSpace.lg),
    this.onTap,
    this.floating = false,
    this.color = MedColors.surface,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool floating;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(MedRadius.lg);

    return Material(
      color: color,
      borderRadius: radius,
      elevation: floating ? 6 : 0,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: floating ? null : Border.all(color: MedColors.line),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Ikon jenis laporan. Nilai `report_types.icon` di database memakai nama Font Awesome, lalu
/// dipetakan ke Material Icons yang paling dekat maknanya.
IconData reportTypeIcon(String? icon, {String? code}) {
  switch (icon) {
    case 'car-crash':
      return Icons.car_crash;
    case 'heart-pulse':
      return Icons.monitor_heart;
    case 'baby':
      return Icons.pregnant_woman;
    case 'bed':
      return Icons.airline_seat_flat;
  }
  return switch (code) {
    'kecelakaan' => Icons.car_crash,
    'medis_darurat' => Icons.monitor_heart,
    'ibu_hamil' => Icons.pregnant_woman,
    'pengantaran_jenazah' => Icons.airline_seat_flat,
    _ => Icons.local_hospital,
  };
}

/// Kartu layanan di beranda (Figma: kotak bergaris merah dengan ilustrasi + nama layanan).
/// Warna aksen dan ikon berasal dari data jenis laporan.
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.name,
    required this.color,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });

  final String name;
  final String? subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(MedRadius.lg);

    return Semantics(
      button: true,
      label: 'Laporkan $name',
      child: Material(
        color: MedColors.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(borderRadius: radius, border: Border.all(color: MedColors.brand, width: 2)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, height: 1.15, color: MedColors.ink),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ikon kotak merah jenis laporan (Figma riwayat).
class ReportTypeTile extends StatelessWidget {
  const ReportTypeTile({super.key, required this.icon, this.color = MedColors.brand, this.size = 52});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(MedRadius.md)),
        child: Icon(icon, color: Colors.white, size: size * 0.52),
      );
}

/// Judul bagian form dengan ikon merah (Figma: "Jumlah Korban", "Keterangan Tambahan (Opsional)").
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.icon, required this.title, this.optional = false, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool optional;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: MedSpace.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: MedColors.brand, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: title,
                      children: [
                        if (optional)
                          const TextSpan(
                            text: ' (Opsional)',
                            style: TextStyle(color: MedColors.inkFaint, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (subtitle != null)
                    Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MedColors.inkMuted)),
                ],
              ),
            ),
          ],
        ),
      );
}

/// Baris info berlabel (kartu detail, profil).
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[Icon(icon, size: 20, color: MedColors.brand), const SizedBox(width: 10)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12.5, color: MedColors.inkMuted, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: MedColors.ink)),
                ],
              ),
            ),
          ],
        ),
      );
}

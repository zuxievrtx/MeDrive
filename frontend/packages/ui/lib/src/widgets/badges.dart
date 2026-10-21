import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// Badge status laporan dengan warna semantik yang sama dengan dashboard admin.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, required this.label, this.large = false});

  final String status;
  final String label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final tone = StatusTone.of(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 14 : 10, vertical: large ? 7 : 4),
      decoration: BoxDecoration(color: tone.background, borderRadius: BorderRadius.circular(MedRadius.sm)),
      child: Text(
        label,
        style: TextStyle(color: tone.foreground, fontWeight: FontWeight.w800, fontSize: large ? 14 : 12.5),
      ),
    );
  }
}

/// Badge "Terverifikasi" untuk driver dengan sertifikat yang masih berlaku.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Driver terverifikasi',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(MedRadius.sm)),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, size: 15, color: Color(0xFF166534)),
              SizedBox(width: 4),
              Text('Terverifikasi', style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
        ),
      );
}

/// Bulatan angka kecil (pesan belum dibaca).
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) => Badge(
        isLabelVisible: count > 0,
        backgroundColor: MedColors.brand,
        label: Text(count > 99 ? '99+' : '$count', style: const TextStyle(fontWeight: FontWeight.w800)),
        child: child,
      );
}

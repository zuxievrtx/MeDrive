import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

/// Sakelar besar Aktif/Nonaktif di pita merah beranda. Aktif = shift terbuka. Mengetuknya tidak
/// langsung mengubah status: membuka alur pilih ambulans (aktif) atau alasan tutup shift
/// (nonaktif), karena keduanya butuh data dari driver.
class DutyToggle extends StatelessWidget {
  const DutyToggle({super.key, required this.active, required this.onPressed, this.busy = false});

  final bool active;

  /// Alur buka/tutup shift sedang berjalan (bottom sheet punya indikatornya sendiri): ketukan diabaikan.
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final title = active ? 'Aktif' : 'Nonaktif';
    final subtitle = active ? 'Menerima tawaran laporan' : 'Ketuk untuk memilih ambulans dan mulai shift';

    return Semantics(
      toggled: active,
      button: true,
      label: 'Status driver $title. ${active ? 'Ketuk untuk menutup shift' : subtitle}',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: busy || onPressed == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onPressed!();
                },
          borderRadius: BorderRadius.circular(MedRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: MedSpace.sm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, height: 1.1),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(width: MedSpace.md),
                _Track(active: active),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations ? Duration.zero : const Duration(milliseconds: 180);

    return AnimatedContainer(
      duration: duration,
      width: 96,
      height: 54,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: active ? Colors.white : MedColors.brandDeep,
        borderRadius: BorderRadius.circular(MedRadius.pill),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: AnimatedAlign(
        duration: duration,
        alignment: active ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: active ? MedColors.brand : Colors.white, shape: BoxShape.circle),
          child: Icon(
            active ? Icons.power_settings_new_rounded : Icons.power_off_rounded,
            color: active ? Colors.white : MedColors.brandDeep,
          ),
        ),
      ),
    );
  }
}

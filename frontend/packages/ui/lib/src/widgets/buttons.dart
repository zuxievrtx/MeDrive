import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// Tombol utama berbentuk pil merah (Figma: "Login", "Kirim Laporan").
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Menonaktifkan tombol dan menampilkan indikator agar tidak ditekan dua kali.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 22), const SizedBox(width: 10)],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    return Semantics(
      button: true,
      label: loading ? '$label, sedang diproses' : null,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: loading ? FilledButton.styleFrom(disabledBackgroundColor: MedColors.brand.withValues(alpha: 0.75)) : null,
        child: child,
      ),
    );
  }
}

/// Tombol sekunder bergaris merah (Figma: "Create Account", "Batal").
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      );
}

import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

/// Baris menu pengaturan (Figma Profil, Keamanan Akun, Bantuan): ikon, judul, keterangan, panah.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.destructive = false,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool destructive;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? MedColors.brandDeep : MedColors.ink;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: MedSpace.md, vertical: MedSpace.md),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: MedColors.line))),
        child: Row(
          children: [
            Icon(icon, color: destructive ? MedColors.brandDeep : MedColors.ink, size: 24),
            const SizedBox(width: MedSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: const TextStyle(fontSize: 13, color: MedColors.inkMuted)),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null && !destructive)
              const Icon(Icons.chevron_right_rounded, color: MedColors.inkMuted),
          ],
        ),
      ),
    );
  }
}

/// Judul halaman sub-menu dengan keterangan singkat di bawahnya (Figma Keamanan Akun / Bantuan).
class PageIntro extends StatelessWidget {
  const PageIntro({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(MedSpace.gutter, 0, MedSpace.gutter, MedSpace.lg),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MedColors.inkMuted)),
      );
}

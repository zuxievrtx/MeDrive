import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../router.dart';
import '../../state/session.dart';
import '../../widgets/feedback.dart';
import 'settings_tile.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _signingOut = false;

  Future<void> _logout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Keluar dari akun?',
      message: 'Anda perlu masuk lagi untuk membuat laporan dan melacak ambulans.',
      confirmLabel: 'Ya, Keluar',
      icon: Icons.logout_rounded,
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _signingOut = true);
    try {
      await ref.read(sessionProvider.notifier).logout();
    } catch (error) {
      if (mounted) {
        showError(context, error);
        setState(() => _signingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider).user;
    if (user == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return LoadingOverlay(
      visible: _signingOut,
      message: 'Keluar…',
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.xl, MedSpace.gutter, MedSpace.xl),
            children: [
              Text('Profil', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: MedSpace.lg),
              _ProfileHeader(
                name: user.name,
                initials: user.displayInitials,
                onEdit: () => context.push(Routes.editProfile),
              ),
              const SizedBox(height: MedSpace.xl),
              Text('Detail akun', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: MedSpace.sm),
              _DetailRow(icon: Icons.call_outlined, label: 'Nomor telepon', value: user.phone),
              _DetailRow(icon: Icons.mail_outline_rounded, label: 'Email', value: user.email),
              if (user.createdAt != null)
                _DetailRow(icon: Icons.event_available_outlined, label: 'Terdaftar sejak', value: formatDay(user.createdAt)),
              const SizedBox(height: MedSpace.xl),
              Text('Pengaturan', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: MedSpace.sm),
              SettingsTile(
                icon: Icons.shield_outlined,
                title: 'Keamanan akun',
                onTap: () => context.push(Routes.security),
              ),
              SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Bantuan',
                onTap: () => context.push(Routes.help),
              ),
              SettingsTile(icon: Icons.logout_rounded, title: 'Keluar', destructive: true, onTap: _logout),
              const SizedBox(height: MedSpace.xxl),
              const Center(
                child: Text('MeDrive v$appVersion', style: TextStyle(color: MedColors.inkFaint, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.initials, required this.onEdit});

  final String name;
  final String initials;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(MedSpace.xl),
        decoration: BoxDecoration(color: MedColors.brand, borderRadius: BorderRadius.circular(MedRadius.md)),
        child: Row(
          children: [
            Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: MedColors.surface, shape: BoxShape.circle),
              child: Text(
                initials,
                style: const TextStyle(color: MedColors.brandDeep, fontSize: 26, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: MedSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: MedSpace.sm),
                  FilledButton.icon(
                    onPressed: onEdit,
                    style: FilledButton.styleFrom(
                      backgroundColor: MedColors.surface,
                      foregroundColor: MedColors.brandDeep,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: MedSpace.md),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit profil'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: MedSpace.md, vertical: MedSpace.md),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: MedColors.line))),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: MedColors.brandSoft, shape: BoxShape.circle),
              child: Icon(icon, color: MedColors.brandDeep, size: 20),
            ),
            const SizedBox(width: MedSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: MedColors.inkMuted, fontSize: 13)),
                  SelectableText(value, style: const TextStyle(color: MedColors.ink, fontSize: 15.5, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      );
}

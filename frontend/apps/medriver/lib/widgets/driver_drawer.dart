import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../router.dart';
import '../state/chat_state.dart';
import '../state/driver_state.dart';
import '../state/session.dart';
import 'feedback.dart';
import 'media.dart';

/// Side menu (Figma): header merah dengan avatar inisial, nama, klinik, ambulans aktif dari API,
/// badge Terverifikasi; menu Profil, Chat, Riwayat, Keluar; versi aplikasi. Tanpa rating.
class DriverDrawer extends ConsumerWidget {
  const DriverDrawer({super.key, required this.onCloseShiftRequested});

  /// Keluar diminta saat shift masih terbuka: arahkan ke penutupan shift lebih dulu.
  final VoidCallback onCloseShiftRequested;

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final driver = ref.read(driverProvider).value;
    final navigator = Navigator.of(context);

    if (driver?.hasMission ?? false) {
      navigator.pop();
      showMessage(context, 'Selesaikan laporan yang sedang ditangani sebelum keluar.');
      return;
    }

    if (driver?.isActive ?? false) {
      final closeFirst = await ConfirmDialog.show(
        context,
        title: 'Shift masih aktif',
        message: 'Tutup shift lebih dulu supaya tawaran laporan tidak lagi dikirim ke ambulans '
            '${driver!.shift?.ambulance?.plateNumber ?? 'Anda'}.',
        confirmLabel: 'Tutup Shift',
        icon: Icons.local_shipping_outlined,
      );
      if (closeFirst) {
        navigator.pop();
        onCloseShiftRequested();
      }
      return;
    }

    if (!context.mounted) {
      return;
    }
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Keluar dari akun?',
      message: 'Anda tidak akan menerima tawaran laporan sampai masuk lagi.',
      confirmLabel: 'Ya, Keluar',
      icon: Icons.logout_rounded,
    );
    if (!confirmed) {
      return;
    }
    try {
      await ref.read(sessionProvider.notifier).logout();
    } catch (error) {
      if (context.mounted) {
        showError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(driverProvider).value;
    final user = ref.watch(sessionProvider).user;
    final account = snapshot?.account;
    final name = account?.name ?? user?.name ?? '';
    final clinic = account?.driverProfile?.clinic?.name;
    final plate = snapshot?.shift?.ambulance?.plateNumber;
    final unread = ref.watch(unreadProvider).value?.total ?? 0;

    void go(String location) {
      Navigator.of(context).pop();
      unawaited(context.push(location));
    }

    return Drawer(
      backgroundColor: MedColors.surface,
      shape: const RoundedRectangleBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: MedColors.brand,
            padding: EdgeInsets.fromLTRB(MedSpace.xl, MediaQuery.paddingOf(context).top + MedSpace.xl, MedSpace.xl, MedSpace.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InitialsAvatar(
                  name: name,
                  initials: account?.initials ?? user?.initials,
                  photoUrl: account?.driverProfile?.photoUrl,
                  size: 84,
                  onBrand: true,
                ),
                const SizedBox(height: MedSpace.lg),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.15),
                ),
                if (clinic != null)
                  Text(clinic, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  plate == null ? 'Belum memakai ambulans' : 'Ambulans $plate',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                ),
                if (account?.isVerified ?? false) ...[
                  const SizedBox(height: MedSpace.md),
                  const VerifiedBadge(),
                ],
              ],
            ),
          ),
          const SizedBox(height: MedSpace.sm),
          _MenuTile(icon: Icons.person_outline_rounded, label: 'Profil', onTap: () => go(Routes.profile)),
          _MenuTile(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            onTap: () => go(Routes.chats),
            trailing: unread > 0
                ? Semantics(
                    label: '$unread pesan belum dibaca',
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: MedColors.brand,
                      child: Text(unread > 99 ? '99+' : '$unread', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                  )
                : null,
          ),
          _MenuTile(icon: Icons.history_rounded, label: 'Riwayat', onTap: () => go(Routes.history)),
          const Spacer(),
          const Divider(),
          _MenuTile(icon: Icons.logout_rounded, label: 'Keluar', destructive: true, onTap: () => _logout(context, ref)),
          const SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(MedSpace.xl, MedSpace.sm, MedSpace.xl, MedSpace.lg),
              child: Text(
                'MeDriveR v$appVersion',
                textAlign: TextAlign.center,
                style: TextStyle(color: MedColors.inkMuted, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap, this.trailing, this.destructive = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? MedColors.brandDeep : MedColors.ink;
    return ListTile(
      minTileHeight: 60,
      contentPadding: const EdgeInsets.symmetric(horizontal: MedSpace.xl),
      leading: Icon(icon, color: color, size: 28),
      title: Text(label, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

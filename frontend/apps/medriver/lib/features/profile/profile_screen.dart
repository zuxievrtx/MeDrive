import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../state/driver_state.dart';
import '../../widgets/feedback.dart';
import '../../widgets/media.dart';

/// Profil driver (hanya baca; data kepegawaian diatur admin pusat): akun, kepegawaian, SIM,
/// ambulans aktif, sertifikat + status kedaluwarsa, badge Terverifikasi. Tanpa rating.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(driverProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: driver.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const SkeletonList(count: 3, itemHeight: 120),
        error: (error, _) => AsyncErrorView(error: error, onRetry: () => ref.invalidate(driverProvider)),
        data: (snapshot) {
          final account = snapshot.account;
          final profile = account.driverProfile;
          final clinic = profile?.clinic;
          final ambulance = snapshot.shift?.ambulance;

          return RefreshIndicator(
            onRefresh: () => ref.read(driverProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.sm, MedSpace.gutter, MedSpace.xxl),
              children: [
                _Header(account: account),
                const SizedBox(height: MedSpace.xl),
                const _Title('Detail akun'),
                _Row(icon: Icons.call_outlined, label: 'Nomor telepon', value: account.phone ?? '-'),
                _Row(icon: Icons.mail_outline_rounded, label: 'Email', value: account.email),
                const SizedBox(height: MedSpace.xl),
                const _Title('Kepegawaian'),
                _Row(icon: Icons.local_hospital_outlined, label: 'Klinik', value: clinic?.name ?? '-'),
                _Row(icon: Icons.apartment_rounded, label: 'Instansi', value: clinic?.institution?.name ?? '-'),
                _Row(icon: Icons.badge_outlined, label: 'Nomor pegawai', value: profile?.employeeNumber ?? '-'),
                const SizedBox(height: MedSpace.xl),
                const _Title('Surat Izin Mengemudi'),
                _Row(
                  icon: Icons.credit_card_rounded,
                  label: 'Nomor SIM${profile?.licenseClass == null ? '' : ' (${profile!.licenseClass!.label})'}',
                  value: profile?.licenseNumber ?? '-',
                ),
                _Row(
                  icon: Icons.event_outlined,
                  label: 'Berlaku sampai',
                  value: formatDay(profile?.licenseExpiresAt),
                  trailing: profile?.licenseExpiryState == null ? null : _ExpiryChip(state: profile!.licenseExpiryState),
                ),
                const SizedBox(height: MedSpace.xl),
                const _Title('Ambulans aktif'),
                if (ambulance == null)
                  const _Row(icon: Icons.airport_shuttle_outlined, label: 'Plat nomor', value: 'Belum ada shift terbuka')
                else ...[
                  _Row(icon: Icons.airport_shuttle_outlined, label: 'Plat nomor', value: ambulance.plateNumber),
                  _Row(
                    icon: Icons.info_outline_rounded,
                    label: 'Kendaraan',
                    value: [ambulance.vehicleName, ambulance.ambulanceType?.name].whereType<String>().join(' · '),
                  ),
                ],
                const SizedBox(height: MedSpace.xl),
                const _Title('Sertifikat'),
                if (account.certifications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: MedSpace.md),
                    child: Text(
                      'Belum ada sertifikat tercatat. Badge Terverifikasi muncul setelah admin menambahkan sertifikat yang masih berlaku.',
                      style: TextStyle(color: MedColors.inkMuted),
                    ),
                  )
                else
                  for (final certification in account.certifications) _CertificationTile(certification: certification),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.account});

  final DriverAccount account;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(MedSpace.xl),
        decoration: BoxDecoration(color: MedColors.brand, borderRadius: BorderRadius.circular(MedRadius.md)),
        child: Row(
          children: [
            InitialsAvatar(name: account.name, initials: account.initials, photoUrl: account.driverProfile?.photoUrl, size: 76, onBrand: true),
            const SizedBox(width: MedSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  const Text('Driver ambulans', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  if (account.isVerified) ...[
                    const SizedBox(height: MedSpace.sm),
                    const VerifiedBadge(key: Key('profile-verified')),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: MedSpace.sm),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value, this.trailing});

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

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
                  SelectableText(value.isEmpty ? '-' : value, style: const TextStyle(color: MedColors.ink, fontSize: 15.5, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: MedSpace.sm), trailing!],
          ],
        ),
      );
}

class _ExpiryChip extends StatelessWidget {
  const _ExpiryChip({required this.state});

  final String? state;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (state) {
      ExpiryState.expired => (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
      ExpiryState.expiring => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
      _ => (const Color(0xFFDCFCE7), const Color(0xFF166534)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(MedRadius.sm)),
      child: Text(ExpiryState.label(state), style: TextStyle(color: foreground, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

class _CertificationTile extends StatelessWidget {
  const _CertificationTile({required this.certification});

  final DriverCertification certification;

  @override
  Widget build(BuildContext context) {
    final meta = [certification.issuer, certification.certificateNumber].whereType<String>().where((part) => part.isNotEmpty).join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpace.md, vertical: MedSpace.md),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: MedColors.line))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            certification.isExpired ? Icons.workspace_premium_outlined : Icons.workspace_premium_rounded,
            color: certification.isExpired ? MedColors.inkMuted : MedColors.brand,
          ),
          const SizedBox(width: MedSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(certification.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
                if (meta.isNotEmpty) Text(meta, style: const TextStyle(color: MedColors.inkMuted)),
                Text(
                  certification.expiresAt == null ? 'Tanpa masa berlaku' : 'Berlaku sampai ${formatDay(certification.expiresAt)}',
                  style: const TextStyle(color: MedColors.ink),
                ),
              ],
            ),
          ),
          _ExpiryChip(state: certification.expiryState),
        ],
      ),
    );
  }
}

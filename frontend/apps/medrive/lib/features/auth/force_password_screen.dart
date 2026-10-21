import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../state/session.dart';
import '../../widgets/feedback.dart';
import '../profile/change_password_form.dart';

/// Akun dengan `must_change_password`: semua layar lain diblokir router sampai kata sandi diganti.
class ForcePasswordScreen extends ConsumerWidget {
  const ForcePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Ganti kata sandi'),
            actions: [
              TextButton(
                onPressed: () => ref.read(sessionProvider.notifier).logout(),
                child: const Text('Keluar'),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(MedSpace.gutter),
              children: [
                Container(
                  padding: const EdgeInsets.all(MedSpace.lg),
                  decoration: BoxDecoration(color: MedColors.brandSoft, borderRadius: BorderRadius.circular(MedRadius.md)),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_reset_rounded, color: MedColors.brandDeep),
                      SizedBox(width: MedSpace.md),
                      Expanded(
                        child: Text(
                          'Akun Anda memakai kata sandi sementara. Buat kata sandi baru sebelum melanjutkan.',
                          style: TextStyle(fontWeight: FontWeight.w700, color: MedColors.ink),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MedSpace.xl),
                ChangePasswordForm(
                  submitLabel: 'Simpan & lanjutkan',
                  onChanged: () => showMessage(context, 'Kata sandi berhasil diganti.'),
                ),
              ],
            ),
          ),
        ),
      );
}

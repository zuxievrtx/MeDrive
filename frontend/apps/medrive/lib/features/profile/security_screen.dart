import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../router.dart';
import 'settings_tile.dart';

/// Keamanan akun. Figma juga memuat "Verifikasi Dua Langkah" dan "Perangkat yang Terhubung",
/// tetapi backend belum menyediakan keduanya sehingga tidak ditampilkan (lihat ASSUMPTIONS.md).
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Keamanan Akun')),
        body: SafeArea(
          child: ListView(
            children: [
              const PageIntro(text: 'Kelola keamanan akun Anda agar tetap aman dan terlindungi.'),
              SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: 'Ubah Kata Sandi',
                subtitle: 'Ganti kata sandi secara berkala untuk keamanan yang lebih baik.',
                onTap: () => context.push(Routes.changePassword),
              ),
            ],
          ),
        ),
      );
}

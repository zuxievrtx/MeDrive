import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../router.dart';

/// Layar sambutan Figma: logo besar di bidang merah yang memudar ke putih, lalu Masuk / Buat Akun.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: DecoratedBox(
          // Gradasi merah → putih di Figma memberi ruang tenang untuk dua tombol utama di bawah.
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 0.6, 0.86],
              colors: [MedColors.brand, MedColors.brand, MedColors.surface],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MedSpace.xxl),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Image.asset('assets/images/logo_white.png', width: 190, semanticLabel: 'Logo MeDrive'),
                  const SizedBox(height: MedSpace.lg),
                  const Text(
                    'MeDrive',
                    style: TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: MedSpace.sm),
                  const Text(
                    'Laporkan keadaan darurat, ambulans terdekat langsung menuju lokasi Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700, height: 1.4),
                  ),
                  const Spacer(flex: 3),
                  PrimaryButton(label: 'Masuk', onPressed: () => context.push(Routes.login)),
                  const SizedBox(height: MedSpace.md),
                  SecondaryButton(label: 'Buat Akun', onPressed: () => context.push(Routes.register)),
                  const SizedBox(height: MedSpace.xxl),
                ],
              ),
            ),
          ),
        ),
      );
}

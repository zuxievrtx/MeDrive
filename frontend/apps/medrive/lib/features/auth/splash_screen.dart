import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../state/session.dart';
import '../../widgets/feedback.dart';

/// Logo MeDrive sambil memeriksa token tersimpan; router berpindah otomatis setelah sesi jelas.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    setState(() => _error = null);
    try {
      await ref.read(sessionProvider.notifier).bootstrap();
    } catch (error) {
      if (mounted) {
        setState(() => _error = error);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: MedColors.brand,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              Semantics(
                label: 'MeDrive',
                child: Column(
                  children: [
                    Image.asset('assets/images/logo_white.png', width: 168),
                    const SizedBox(height: MedSpace.lg),
                    const Text(
                      'MeDrive',
                      style: TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: MedSpace.xs),
                    const Text(
                      'Ambulans darurat dalam genggaman',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              if (_error == null)
                const SizedBox.square(dimension: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: MedSpace.xl),
                  child: Column(
                    children: [
                      Text(
                        asApiError(_error!).message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: MedSpace.md),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          minimumSize: const Size(200, 50),
                        ),
                        onPressed: _start,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 56),
            ],
          ),
        ),
      );
}

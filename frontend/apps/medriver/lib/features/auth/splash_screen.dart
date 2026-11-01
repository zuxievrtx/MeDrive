
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../state/session.dart';
import '../../widgets/brand.dart';
import '../../widgets/feedback.dart';

/// Logo MeDriveR sambil memeriksa token tersimpan.
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
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: constraints.maxHeight * 0.40,
                    child: const Center(
                      child: DriverLogo(
                        markWidth: 170,
                        wordmarkSize: 52,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 56,
                    child: Center(
                      child: _error == null
                          ? const SizedBox.square(
                              dimension: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: MedSpace.xl,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    asApiError(_error!).message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: MedColors.ink,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: MedSpace.md),
                                  SizedBox(
                                    width: 220,
                                    child: SecondaryButton(
                                      label: 'Coba lagi',
                                      icon: Icons.refresh_rounded,
                                      onPressed: _start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
}

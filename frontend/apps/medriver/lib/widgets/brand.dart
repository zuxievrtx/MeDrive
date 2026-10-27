import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

/// Logo MeDrive (pin + ambulans, aset yang sudah ada) dengan wordmark "MeDriveR" merah seperti
/// Figma splash/login aplikasi driver. Wordmark ditulis sebagai teks, bukan aset baru.
class DriverLogo extends StatelessWidget {
  const DriverLogo({super.key, this.markWidth = 150, this.wordmarkSize = 46});

  final double markWidth;
  final double wordmarkSize;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'MeDriveR',
        image: true,
        child: ExcludeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo_red.png', width: markWidth),
              const SizedBox(height: MedSpace.sm),
              Text(
                'MeDriveR',
                style: TextStyle(
                  color: MedColors.brand,
                  fontSize: wordmarkSize,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      );
}

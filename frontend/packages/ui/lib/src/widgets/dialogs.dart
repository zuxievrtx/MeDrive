import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'buttons.dart';

/// Dialog konfirmasi bergaya Figma (ikon bulat, judul tebal, Batal bergaris + aksi merah).
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.icon = Icons.help_outline_rounded,
    this.cancelLabel = 'Batal',
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    IconData icon = Icons.help_outline_rounded,
    String cancelLabel = 'Batal',
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => ConfirmDialog(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          icon: icon,
          cancelLabel: cancelLabel,
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: MedSpace.xl),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(MedSpace.xl, MedSpace.xl, MedSpace.xl, MedSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(color: MedColors.brandSoft, shape: BoxShape.circle),
                child: Icon(icon, size: 36, color: MedColors.brand),
              ),
              const SizedBox(height: MedSpace.lg),
              Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: MedSpace.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MedColors.inkMuted),
              ),
              const SizedBox(height: MedSpace.xl),
              Row(
                children: [
                  Expanded(child: SecondaryButton(label: cancelLabel, onPressed: () => Navigator.of(context).pop(false))),
                  const SizedBox(width: MedSpace.md),
                  Expanded(child: PrimaryButton(label: confirmLabel, onPressed: () => Navigator.of(context).pop(true))),
                ],
              ),
            ],
          ),
        ),
      );
}

/// Bottom sheet dengan judul; isi boleh tinggi (daftar faskes, pencarian alamat).
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  bool tall = false,
}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(MedSpace.gutter, 0, MedSpace.gutter, MedSpace.md),
              child: Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
            ),
            if (tall) Expanded(child: builder(sheetContext)) else Flexible(child: builder(sheetContext)),
          ],
        );

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: tall ? SizedBox(height: MediaQuery.of(sheetContext).size.height * 0.85, child: content) : content,
        );
      },
    );

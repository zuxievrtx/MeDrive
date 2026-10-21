import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

class ChoiceOption<T> {
  const ChoiceOption(this.value, this.label);

  final T value;
  final String label;
}

/// Pilihan tunggal berbentuk tombol (Figma: "Sadar / Tidak Sadar / Kritis").
class ChoiceGroup<T> extends StatelessWidget {
  const ChoiceGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final List<ChoiceOption<T>> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MedSpace.sm,
            runSpacing: MedSpace.sm,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text(option.label),
                  selected: option.value == value,
                  onSelected: (_) => onChanged(option.value),
                ),
            ],
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(errorText!, style: const TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w700, fontSize: 12.5)),
            ),
        ],
      );
}

/// Ya/tidak dengan teks pertanyaan (mis. "Ada korban terjepit").
class YesNoTile extends StatelessWidget {
  const YesNoTile({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Material(
        color: MedColors.field,
        borderRadius: BorderRadius.circular(MedRadius.md),
        child: SwitchListTile(
          value: value,
          onChanged: onChanged,
          title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          activeThumbColor: Colors.white,
          activeTrackColor: MedColors.brand,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MedRadius.md)),
          contentPadding: const EdgeInsets.symmetric(horizontal: MedSpace.lg),
        ),
      );
}

/// Grid foto terpilih + kotak "Pilih Foto" bergaris putus-putus (Figma). Pemilihan dan kompresi
/// foto dilakukan pemanggil lewat [onAdd].
class PhotoPickerGrid extends StatelessWidget {
  const PhotoPickerGrid({
    super.key,
    required this.paths,
    required this.onAdd,
    required this.onRemove,
    this.max = 5,
    this.busy = false,
  });

  final List<String> paths;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final int max;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final canAdd = paths.length < max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (paths.isNotEmpty)
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: MedSpace.sm,
            crossAxisSpacing: MedSpace.sm,
            children: [
              for (var index = 0; index < paths.length; index++)
                Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(MedRadius.md),
                      child: Image.file(File(paths[index]), fit: BoxFit.cover, cacheWidth: 300),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: IconButton.filled(
                        tooltip: 'Hapus foto ${index + 1}',
                        style: IconButton.styleFrom(backgroundColor: Colors.black54, minimumSize: const Size(36, 36)),
                        iconSize: 18,
                        onPressed: () => onRemove(index),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        if (paths.isNotEmpty) const SizedBox(height: MedSpace.sm),
        if (canAdd)
          Semantics(
            button: true,
            label: 'Pilih foto, ${paths.length} dari $max',
            child: InkWell(
              onTap: busy ? null : onAdd,
              borderRadius: BorderRadius.circular(MedRadius.md),
              child: CustomPaint(
                painter: _DashedBorderPainter(),
                child: SizedBox(
                  height: 84,
                  child: Center(
                    child: busy
                        ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_circle_rounded, color: MedColors.inkFaint, size: 28),
                              const SizedBox(height: 4),
                              Text(
                                paths.isEmpty ? 'Pilih Foto' : 'Tambah foto (${paths.length}/$max)',
                                style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MedColors.brand
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(MedRadius.md)));

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 7), paint);
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

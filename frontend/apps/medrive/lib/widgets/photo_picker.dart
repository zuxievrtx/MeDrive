import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

/// Ambil foto dari kamera/galeri lalu kecilkan: sisi terpanjang ≤ 1280 px dan ukuran ≤ 300 KB
/// (backend menerima maks 2 MB untuk laporan dan 1 MB untuk chat; 300 KB menghemat kuota pelapor).
class PhotoPicker {
  const PhotoPicker();

  static const maxBytes = 300 * 1024;
  static const maxSide = 1280;

  Future<String?> pick(BuildContext context) async {
    final source = await showAppBottomSheet<ImageSource>(
      context,
      title: 'Ambil foto dari',
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: MedColors.brand),
              title: const Text('Kamera'),
              minTileHeight: 56,
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: MedColors.brand),
              title: const Text('Galeri'),
              minTileHeight: 56,
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            const SizedBox(height: MedSpace.md),
          ],
        ),
      ),
    );
    if (source == null) {
      return null;
    }

    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: maxSide.toDouble(),
      maxHeight: maxSide.toDouble(),
      imageQuality: 85,
    );
    return file == null ? null : compress(file.path);
  }

  /// Turunkan kualitas JPEG bertahap sampai ≤ [maxBytes].
  Future<String> compress(String path) async {
    final directory = await Directory.systemTemp.createTemp('medrive_photo');
    var quality = 80;
    var output = path;

    while (true) {
      final target = '${directory.path}/foto_$quality.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        path,
        target,
        quality: quality,
        minWidth: maxSide,
        minHeight: maxSide,
        format: CompressFormat.jpeg,
      );
      if (result == null) {
        return output;
      }
      output = result.path;
      if (await File(output).length() <= maxBytes || quality <= 35) {
        return output;
      }
      quality -= 15;
    }
  }
}

final photoPickerProvider = Provider<PhotoPicker>((ref) => const PhotoPicker());

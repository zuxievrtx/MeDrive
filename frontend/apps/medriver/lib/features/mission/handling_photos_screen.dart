import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../widgets/feedback.dart';
import '../../widgets/media.dart';
import '../../widgets/photo_picker.dart';
import 'mission_state.dart';

/// Foto penanganan: pilih beberapa foto (dikompres ≤ 300 KB), unggah sekaligus maks 5 per
/// permintaan sesuai batas backend, lalu tampil di grid foto terunggah.
class HandlingPhotosScreen extends ConsumerStatefulWidget {
  const HandlingPhotosScreen({super.key, required this.reportId});

  final int reportId;

  @override
  ConsumerState<HandlingPhotosScreen> createState() => _HandlingPhotosScreenState();
}

class _HandlingPhotosScreenState extends ConsumerState<HandlingPhotosScreen> {
  static const _maxPerUpload = 5;

  final _paths = <String>[];
  bool _picking = false;
  bool _uploading = false;

  Future<void> _add() async {
    setState(() => _picking = true);
    try {
      final path = await ref.read(photoPickerProvider).pick(context);
      if (path != null && mounted) {
        setState(() => _paths.add(path));
      }
    } catch (error) {
      if (mounted) {
        showMessage(context, 'Foto tidak bisa diambil. Periksa izin kamera atau galeri.');
      }
    } finally {
      if (mounted) {
        setState(() => _picking = false);
      }
    }
  }

  Future<void> _upload() async {
    if (_paths.isEmpty || _uploading) {
      return;
    }
    setState(() => _uploading = true);
    try {
      final uploaded = await ref.read(missionProvider(widget.reportId).notifier).uploadPhotos([..._paths]);
      if (mounted) {
        setState(_paths.clear);
        showMessage(context, '${uploaded.length} foto penanganan terunggah.');
      }
    } catch (error) {
      if (mounted) {
        showError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mission = ref.watch(missionProvider(widget.reportId));

    return LoadingOverlay(
      visible: _uploading,
      message: 'Mengunggah foto…',
      child: Scaffold(
        appBar: AppBar(title: const Text('Foto Penanganan')),
        body: mission.when(
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          loading: () => const SkeletonList(count: 2, itemHeight: 120),
          error: (error, _) => AsyncErrorView(error: error, onRetry: () => ref.invalidate(missionProvider(widget.reportId))),
          data: (report) {
            final photos = report.attachments.where((item) => item.type.value == 'foto_penanganan' && item.isImage).toList();

            return ListView(
              padding: const EdgeInsets.all(MedSpace.gutter),
              children: [
                if (report.isActive) ...[
                  const SectionLabel(
                    icon: Icons.add_a_photo_outlined,
                    title: 'Tambah foto',
                    subtitle: 'Maksimal 5 foto per unggahan. Foto dikecilkan otomatis agar hemat kuota.',
                  ),
                  PhotoPickerGrid(paths: _paths, onAdd: _add, onRemove: (index) => setState(() => _paths.removeAt(index)), max: _maxPerUpload, busy: _picking),
                  const SizedBox(height: MedSpace.md),
                  PrimaryButton(
                    key: const Key('photos-upload'),
                    label: _paths.isEmpty ? 'Unggah foto' : 'Unggah ${_paths.length} foto',
                    icon: Icons.cloud_upload_outlined,
                    onPressed: _paths.isEmpty ? null : _upload,
                  ),
                  const SizedBox(height: MedSpace.xl),
                ],
                Text('Foto terunggah (${photos.length})', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: MedSpace.sm),
                if (photos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: MedSpace.lg),
                    child: Text('Belum ada foto penanganan untuk laporan ini.', style: TextStyle(color: MedColors.inkMuted)),
                  )
                else
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: MedSpace.sm,
                    crossAxisSpacing: MedSpace.sm,
                    children: [
                      for (final photo in photos)
                        Semantics(
                          button: true,
                          label: 'Foto penanganan ${formatDateTime(photo.createdAt)}, ketuk untuk memperbesar',
                          child: GestureDetector(
                            onTap: () => showImageViewer(context, photo.url, caption: formatDateTime(photo.createdAt)),
                            child: ClipRRect(borderRadius: BorderRadius.circular(MedRadius.md), child: AuthImage(url: photo.url)),
                          ),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

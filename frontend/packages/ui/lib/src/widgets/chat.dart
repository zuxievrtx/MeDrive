import 'package:material_ui/material_ui.dart';

import '../format.dart';
import '../tokens.dart';
import 'states.dart';

/// Gelembung pesan chat pelapor ↔ driver. Pesan sendiri merah tua di kanan, lawan bicara abu di
/// kiri (Figma Chat). Gambar privat dirender pemanggil lewat [image] karena butuh header token.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.mine,
    this.body,
    this.image,
    this.onImageTap,
    this.imageLabel,
    this.sentAt,
    this.read = false,
  });

  final bool mine;
  final String? body;

  /// Isi pesan gambar (mis. widget gambar ber-auth 220×220). Null = pesan teks.
  final Widget? image;
  final VoidCallback? onImageTap;

  /// Label pembaca layar untuk gambar, mis. "Foto dari Anda".
  final String? imageLabel;
  final DateTime? sentAt;

  /// Hanya untuk pesan sendiri: centang ganda bila sudah dibaca lawan bicara.
  final bool read;

  @override
  Widget build(BuildContext context) {
    final foreground = mine ? Colors.white : MedColors.ink;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(mine ? 18 : 4),
      bottomRight: Radius.circular(mine ? 4 : 18),
    );
    final isImage = image != null;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.76),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: isImage ? const EdgeInsets.all(4) : const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: BoxDecoration(color: mine ? MedColors.brandDeep : MedColors.field, borderRadius: radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isImage)
                GestureDetector(
                  onTap: onImageTap,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Semantics(label: imageLabel, button: onImageTap != null, child: image),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  child: Text(body ?? '', style: TextStyle(color: foreground, fontSize: 15.5, height: 1.35)),
                ),
              Padding(
                padding: isImage ? const EdgeInsets.fromLTRB(8, 4, 8, 2) : const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatTime(sentAt),
                      style: TextStyle(color: mine ? Colors.white : MedColors.inkMuted, fontSize: 11.5),
                    ),
                    if (mine) ...[
                      const SizedBox(width: 4),
                      Icon(
                        read ? Icons.done_all_rounded : Icons.done_rounded,
                        size: 15,
                        color: Colors.white,
                        semanticLabel: read ? 'Dibaca' : 'Terkirim',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pemisah tanggal di antara pesan.
class ChatDayDivider extends StatelessWidget {
  const ChatDayDivider({super.key, required this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: MedSpace.md),
        child: Center(
          child: Text(formatDay(date), style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
      );
}

/// Garis "Pesan baru" di atas pesan belum dibaca pertama.
class ChatUnreadDivider extends StatelessWidget {
  const ChatUnreadDivider({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: MedSpace.sm),
        child: Row(
          children: [
            Expanded(child: Divider(color: MedColors.brand)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MedSpace.sm),
              child: Text('Pesan baru', style: TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w800, fontSize: 12.5)),
            ),
            Expanded(child: Divider(color: MedColors.brand)),
          ],
        ),
      );
}

/// Pengganti kolom tulis saat chat ditutup (laporan selesai/dibatalkan).
class ChatClosedBanner extends StatelessWidget {
  const ChatClosedBanner({
    super.key,
    this.message = 'Chat ditutup karena laporan sudah selesai. Riwayat pesan tetap bisa dibaca.',
  });

  final String message;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: MedColors.field,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(MedSpace.lg),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, color: MedColors.inkMuted),
                const SizedBox(width: MedSpace.md),
                Expanded(
                  child: Text(message, style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      );
}

/// Kerangka gelembung saat riwayat chat dimuat.
class ChatSkeleton extends StatelessWidget {
  const ChatSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(MedSpace.lg),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          Align(alignment: Alignment.centerLeft, child: Skeleton(width: 200, height: 44, radius: 18)),
          SizedBox(height: MedSpace.sm),
          Align(alignment: Alignment.centerRight, child: Skeleton(width: 160, height: 44, radius: 18)),
          SizedBox(height: MedSpace.sm),
          Align(alignment: Alignment.centerLeft, child: Skeleton(width: 240, height: 64, radius: 18)),
          SizedBox(height: MedSpace.sm),
          Align(alignment: Alignment.centerRight, child: Skeleton(width: 120, height: 44, radius: 18)),
        ],
      );
}

/// Kolom tulis pesan: tombol foto, field teks (maks 1000 karakter, sama dengan backend), kirim.
class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    this.sending = false,
    this.maxLength = 1000,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final bool sending;
  final int maxLength;

  @override
  Widget build(BuildContext context) => Material(
        color: MedColors.surface,
        elevation: 8,
        shadowColor: Colors.black26,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(MedSpace.sm),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final canSend = value.text.trim().isNotEmpty && !sending;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'Kirim foto',
                      onPressed: sending ? null : onPickImage,
                      icon: const Icon(Icons.photo_camera_rounded, color: MedColors.inkMuted),
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: maxLength,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(hintText: 'Tulis pesan…', counterText: ''),
                      ),
                    ),
                    const SizedBox(width: MedSpace.xs),
                    IconButton.filled(
                      tooltip: 'Kirim',
                      onPressed: canSend ? onSend : null,
                      icon: sending
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
}

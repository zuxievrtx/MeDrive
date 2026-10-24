import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

/// Gambar privat dari `/api/v1/media/...` (butuh header Authorization), dengan cache disk.
class AuthImage extends ConsumerWidget {
  const AuthImage({super.key, required this.url, this.fit = BoxFit.cover, this.width, this.height});

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) => CachedNetworkImage(
        imageUrl: url,
        httpHeaders: ref.watch(apiClientProvider).authHeaders,
        fit: fit,
        width: width,
        height: height,
        placeholder: (_, _) => const Skeleton(radius: 0),
        errorWidget: (_, _, _) => const ColoredBox(
          color: MedColors.field,
          child: Center(
            child: Icon(Icons.broken_image_outlined, color: MedColors.inkMuted, semanticLabel: 'Gambar tidak tersedia'),
          ),
        ),
      );
}

/// Foto layar penuh dengan pinch-zoom.
Future<void> showImageViewer(BuildContext context, String url, {String? caption}) => Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: caption == null ? null : Text(caption, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          body: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(child: AuthImage(url: url, fit: BoxFit.contain)),
          ),
        ),
      ),
    );

/// Avatar inisial (Figma side menu "AP"). Backend tidak menyediakan foto pelapor; foto driver
/// dimuat bila ada.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.initials,
    this.photoUrl,
    this.size = 56,
    this.onBrand = false,
  });

  final String name;
  final String? initials;
  final String? photoUrl;
  final double size;

  /// Di atas header merah: lingkaran merah tua dengan cincin putih seperti Figma.
  final bool onBrand;

  @override
  Widget build(BuildContext context) {
    final text = (initials != null && initials!.isNotEmpty)
        ? initials!
        : name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).take(2).map((part) => part[0].toUpperCase()).join();

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(onBrand ? 3 : 0),
      decoration: BoxDecoration(shape: BoxShape.circle, color: onBrand ? Colors.white : null),
      child: ClipOval(
        child: photoUrl == null
            ? ColoredBox(
                color: onBrand ? MedColors.brandDeep : MedColors.brandSoft,
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: onBrand ? Colors.white : MedColors.brandDeep,
                      fontWeight: FontWeight.w900,
                      fontSize: size * 0.34,
                    ),
                  ),
                ),
              )
            : AuthImage(url: photoUrl!),
      ),
    );
  }
}

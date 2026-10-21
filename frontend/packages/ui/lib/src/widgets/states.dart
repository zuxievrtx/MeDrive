import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'buttons.dart';

/// Blok abu-abu berkilau untuk loading. Kilau dimatikan bila pengguna memilih kurangi animasi.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height = 16, this.radius = MedRadius.sm});

  final double? width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final shift = _controller.value * 2 - 1;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              gradient: LinearGradient(
                begin: Alignment(shift - 1, 0),
                end: Alignment(shift + 1, 0),
                colors: const [Color(0xFFEDEBE8), Color(0xFFF7F6F4), Color(0xFFEDEBE8)],
              ),
            ),
          );
        },
      );
}

/// Daftar kartu skeleton (riwayat, faskes, chat).
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 4, this.itemHeight = 110});

  final int count;
  final double itemHeight;

  @override
  Widget build(BuildContext context) => ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(MedSpace.gutter),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: MedSpace.md),
        itemBuilder: (_, _) => Semantics(
          label: 'Memuat',
          child: Skeleton(height: itemHeight, radius: MedRadius.lg),
        ),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(MedSpace.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: MedColors.field, shape: BoxShape.circle),
                child: Icon(icon, size: 34, color: MedColors.inkMuted),
              ),
              const SizedBox(height: MedSpace.lg),
              Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
              if (message != null) ...[
                const SizedBox(height: MedSpace.sm),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MedColors.inkMuted),
                ),
              ],
              if (action != null) ...[const SizedBox(height: MedSpace.xl), action!],
            ],
          ),
        ),
      );
}

/// Error dengan tombol coba lagi. Pesan jaringan diberi ikon sinyal agar jelas penyebabnya.
class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.message, required this.onRetry, this.isNetwork = false});

  final String message;
  final VoidCallback onRetry;
  final bool isNetwork;

  @override
  Widget build(BuildContext context) => EmptyState(
        icon: isNetwork ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
        title: isNetwork ? 'Tidak ada koneksi' : 'Gagal memuat data',
        message: message,
        action: SizedBox(
          width: 220,
          child: SecondaryButton(label: 'Coba lagi', icon: Icons.refresh_rounded, onPressed: onRetry),
        ),
      );
}

/// Lapisan penghalang dengan indikator saat proses yang tidak boleh diganggu (kirim laporan).
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, required this.visible, required this.child, this.message});

  final bool visible;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          child,
          if (visible)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black38,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                    decoration: BoxDecoration(color: MedColors.surface, borderRadius: BorderRadius.circular(MedRadius.lg)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        if (message != null) ...[
                          const SizedBox(height: MedSpace.md),
                          Text(message!, style: Theme.of(context).textTheme.titleSmall),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
}

/// Pita "Tidak ada koneksi" di atas layar data.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Material(
        color: MedColors.ink,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(MedSpace.lg, 6, MedSpace.sm, 6),
            child: Row(
              children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
                const SizedBox(width: MedSpace.sm),
                const Expanded(
                  child: Text('Tidak ada koneksi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
                TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      );
}

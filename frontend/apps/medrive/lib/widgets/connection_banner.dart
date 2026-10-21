import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

/// Pita "Tidak ada koneksi" di atas semua layar saat permintaan terakhir gagal karena jaringan.
/// "Coba lagi" memancarkan [retryTick]; layar data mendengarkannya untuk memuat ulang.
class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiClientProvider);

    return ValueListenableBuilder<bool>(
      valueListenable: api.reachable,
      builder: (context, reachable, _) => Column(
        children: [
          if (!reachable)
            OfflineBanner(
              onRetry: () {
                ref.read(retryTickProvider.notifier).bump();
                // Ping ringan: berhasil → pita hilang walau layar aktif tidak memuat ulang apa pun.
                unawaited(api.get('/me').then<void>((_) {}, onError: (_) {}));
              },
            ),
          Expanded(
            child: MediaQuery.removePadding(context: context, removeTop: !reachable, child: child),
          ),
        ],
      ),
    );
  }
}

class RetryTick extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

/// Bertambah setiap kali pengguna menekan "Coba lagi" di pita offline.
final retryTickProvider = NotifierProvider<RetryTick, int>(RetryTick.new);

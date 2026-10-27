import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../router.dart';
import '../../state/chat_state.dart';
import '../../state/driver_state.dart';
import '../../widgets/feedback.dart';

/// Daftar chat (side menu): laporan yang sedang ditangani beserta laporan lain yang masih punya
/// pesan belum dibaca. Satu room chat per laporan.
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadProvider);
    final mission = ref.watch(driverProvider).value?.mission;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(unreadProvider);
          await ref.read(unreadProvider.future).catchError((Object _) => const UnreadSummary());
        },
        child: unread.when(
          loading: () => const SkeletonList(count: 2, itemHeight: 84),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 420, child: AsyncErrorView(error: error, onRetry: () => ref.invalidate(unreadProvider))),
            ],
          ),
          data: (summary) {
            final items = <_ChatItem>[
              if (mission != null)
                _ChatItem(reportId: mission.id, code: mission.code, title: mission.typeName, unread: summary.forReport(mission.id), active: true),
              for (final report in summary.reports)
                if (report.reportId != mission?.id)
                  _ChatItem(reportId: report.reportId, code: report.code, title: 'Laporan ${report.code}', unread: report.count, active: false),
            ];

            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 420,
                    child: EmptyState(
                      icon: Icons.forum_outlined,
                      title: 'Belum ada chat',
                      message: 'Chat dengan pelapor terbuka selama Anda menangani laporan, dari diambil sampai selesai.',
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(MedSpace.gutter),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: MedSpace.md),
              itemBuilder: (context, index) {
                final item = items[index];
                return AppCard(
                  onTap: () async {
                    await context.push(Routes.chat(item.reportId));
                    ref.invalidate(unreadProvider);
                  },
                  child: Row(
                    children: [
                      CountBadge(
                        count: item.unread,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(color: MedColors.brandSoft, shape: BoxShape.circle),
                          child: const Icon(Icons.chat_bubble_outline_rounded, color: MedColors.brandDeep),
                        ),
                      ),
                      const SizedBox(width: MedSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                            Text(
                              item.active ? '${item.code} · sedang ditangani' : item.code,
                              style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      if (item.unread > 0)
                        Text('${item.unread} baru', style: const TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w900)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ChatItem {
  const _ChatItem({required this.reportId, required this.code, required this.title, required this.unread, required this.active});

  final int reportId;
  final String code;
  final String title;
  final int unread;
  final bool active;
}

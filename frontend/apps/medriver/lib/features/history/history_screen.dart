import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../router.dart';
import '../../widgets/connection_banner.dart';
import '../../widgets/feedback.dart';

/// Riwayat laporan yang pernah ditangani (`GET /driver/reports/history`, 15 per halaman).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scroll = ScrollController();
  final _items = <Report>[];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) {
        unawaited(_loadMore());
      }
    });
    unawaited(_reload());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = _items.isEmpty;
      _error = null;
    });
    try {
      final page = await ref.read(driverRepositoryProvider).history();
      if (!mounted) {
        return;
      }
      setState(() {
        _items
          ..clear()
          ..addAll(page.items);
        _page = page.pagination.currentPage;
        _hasMore = page.pagination.hasMore;
        _loading = false;
      });
    } on ApiError catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = error;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore || _error != null) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final page = await ref.read(driverRepositoryProvider).history(page: _page + 1);
      if (!mounted) {
        return;
      }
      setState(() {
        final known = _items.map((report) => report.id).toSet();
        _items.addAll(page.items.where((report) => !known.contains(report.id)));
        _page = page.pagination.currentPage;
        _hasMore = page.pagination.hasMore;
      });
    } on ApiError catch (error) {
      if (mounted) {
        showError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(retryTickProvider, (_, _) => unawaited(_reload()));

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: _buildBody(),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    if (_loading) {
      return const [SliverFillRemaining(child: SkeletonList(count: 4, itemHeight: 120))];
    }
    if (_error != null && _items.isEmpty) {
      return [
        SliverFillRemaining(hasScrollBody: false, child: AsyncErrorView(error: _error!, onRetry: () => unawaited(_reload()))),
      ];
    }
    if (_items.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.history_rounded,
            title: 'Belum ada riwayat',
            message: 'Laporan yang Anda ambil dan tangani akan tercatat di sini.',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.sm, MedSpace.gutter, 0),
        sliver: SliverList.separated(
          itemCount: _items.length,
          separatorBuilder: (_, _) => const SizedBox(height: MedSpace.md),
          itemBuilder: (context, index) => _HistoryCard(report: _items[index]),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: MedSpace.xl),
          child: Center(
            child: _loadingMore
                ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                : _hasMore
                    ? TextButton(onPressed: _loadMore, child: const Text('Muat lebih banyak'))
                    : const Text('Semua laporan sudah ditampilkan', style: TextStyle(color: MedColors.inkMuted)),
          ),
        ),
      ),
    ];
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final type = report.reportType;

    return AppCard(
      onTap: () => context.push(report.isActive ? Routes.mission(report.id) : Routes.historyDetail(report.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportTypeTile(icon: reportTypeIcon(type?.icon, code: type?.code), color: colorFromHex(type?.color), size: 46),
              const SizedBox(width: MedSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.typeName, style: Theme.of(context).textTheme.titleMedium),
                    Text(report.code, style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: MedSpace.sm),
              StatusBadge(status: report.statusValue, label: report.status.label),
            ],
          ),
          const SizedBox(height: MedSpace.md),
          Text(formatDateTime(report.takenAt ?? report.createdAt), style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            report.shortAddress ?? report.address ?? '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: MedColors.inkMuted),
          ),
          if (report.ambulance != null) ...[
            const SizedBox(height: 2),
            Text('Ambulans ${report.ambulance!.plateNumber}', style: const TextStyle(color: MedColors.inkMuted)),
          ],
        ],
      ),
    );
  }
}

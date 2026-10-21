import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../router.dart';
import '../../widgets/connection_banner.dart';
import '../../widgets/feedback.dart';

/// Filter riwayat. Backend hanya menerima satu nilai `status`, jadi "Aktif" (menunggu sampai
/// mengantar pasien) disaring di aplikasi dari halaman-halaman server.
enum HistoryFilter {
  all('Semua', null),
  active('Aktif', null),
  done('Selesai', ReportStatus.selesai),
  cancelled('Dibatalkan', ReportStatus.dibatalkan);

  const HistoryFilter(this.label, this.status);

  final String label;
  final String? status;

  bool accepts(Report report) => this != active || !report.isClosed;
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  /// Batas halaman kosong berturut-turut yang dilewati saat filter "Aktif" tidak menemukan apa pun.
  static const _maxEmptySkips = 3;

  final _scroll = ScrollController();
  HistoryFilter _filter = HistoryFilter.all;
  final _items = <Report>[];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;
  int _generation = 0;

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
    final generation = ++_generation;
    setState(() {
      _loading = _items.isEmpty;
      _error = null;
    });
    try {
      final result = await _fetchFrom(1);
      if (!mounted || generation != _generation) {
        return;
      }
      setState(() {
        _items
          ..clear()
          ..addAll(result.items);
        _page = result.page;
        _hasMore = result.hasMore;
        _loading = false;
      });
    } on ApiError catch (error) {
      if (mounted && generation == _generation) {
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
    final generation = _generation;
    setState(() => _loadingMore = true);
    try {
      final result = await _fetchFrom(_page + 1);
      if (!mounted || generation != _generation) {
        return;
      }
      setState(() {
        final known = _items.map((report) => report.id).toSet();
        _items.addAll(result.items.where((report) => !known.contains(report.id)));
        _page = result.page;
        _hasMore = result.hasMore;
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

  /// Ambil halaman [page]; untuk filter "Aktif" lanjut ke halaman berikutnya bila hasil
  /// saringan kosong, paling banyak [_maxEmptySkips] halaman.
  Future<({List<Report> items, int page, bool hasMore})> _fetchFrom(int page) async {
    final repository = ref.read(reportRepositoryProvider);
    var current = page;
    for (var attempt = 0;; attempt++) {
      final result = await repository.list(page: current, status: _filter.status);
      final items = result.items.where(_filter.accepts).toList();
      final hasMore = result.pagination.hasMore;
      if (items.isNotEmpty || !hasMore || attempt >= _maxEmptySkips) {
        return (items: items, page: current, hasMore: hasMore);
      }
      current++;
    }
  }

  void _select(HistoryFilter filter) {
    if (filter == _filter) {
      return;
    }
    setState(() {
      _filter = filter;
      _items.clear();
      _hasMore = true;
    });
    unawaited(_reload());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(retryTickProvider, (_, _) => unawaited(_reload()));

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.xl, MedSpace.gutter, MedSpace.md),
                sliver: SliverToBoxAdapter(
                  child: Text('Riwayat', style: Theme.of(context).textTheme.displaySmall),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: MedSpace.gutter),
                  child: Row(
                    children: [
                      for (final filter in HistoryFilter.values) ...[
                        ChoiceChip(
                          label: Text(filter.label),
                          selected: filter == _filter,
                          onSelected: (_) => _select(filter),
                        ),
                        const SizedBox(width: MedSpace.sm),
                      ],
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: MedSpace.md)),
              ..._buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    if (_loading) {
      return const [SliverToBoxAdapter(child: SkeletonList(count: 4, itemHeight: 150))];
    }
    if (_error != null && _items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AsyncErrorView(error: _error!, onRetry: () => unawaited(_reload())),
        ),
      ];
    }
    if (_items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.history_rounded,
            title: _filter == HistoryFilter.all ? 'Belum ada riwayat' : 'Tidak ada laporan ${_filter.label.toLowerCase()}',
            message: _filter == HistoryFilter.all
                ? 'Laporan yang Anda kirim akan tercatat di sini beserta statusnya.'
                : 'Coba pilih filter lain.',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: MedSpace.gutter),
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
                    : const Text('Semua laporan sudah ditampilkan', style: TextStyle(color: MedColors.inkFaint)),
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
      onTap: () => context.push(Routes.reportDetail(report.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportTypeTile(
                icon: reportTypeIcon(type?.icon, code: type?.code),
                color: colorFromHex(type?.color),
                size: 48,
              ),
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
          _Line(label: 'Waktu', value: formatDateTime(report.createdAt)),
          const SizedBox(height: 4),
          _Line(label: 'Lokasi', value: report.shortAddress ?? report.address ?? '-', pin: true),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.pin = false});

  final String label;
  final String value;
  final bool pin;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 64, child: Text(label, style: const TextStyle(color: MedColors.inkMuted))),
          if (pin) ...[
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.location_on_outlined, size: 17, color: MedColors.brand),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: MedColors.ink, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
}

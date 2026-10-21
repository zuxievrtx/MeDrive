import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../home/address_search_sheet.dart';

/// Tujuan antar: faskes terdaftar (`destination_clinic_id`) atau alamat lain (nama + koordinat).
class DestinationChoice {
  const DestinationChoice.clinic(Clinic this.clinic)
      : name = null,
        address = null,
        latitude = null,
        longitude = null;

  const DestinationChoice.place({required String this.name, this.address, required double this.latitude, required double this.longitude})
      : clinic = null;

  final Clinic? clinic;
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;

  String get title => clinic?.name ?? name!;

  String? get subtitle => clinic?.address ?? address;
}

Future<DestinationChoice?> showDestinationPicker(BuildContext context) => showAppBottomSheet<DestinationChoice>(
      context,
      title: 'Pilih tujuan antar',
      tall: true,
      builder: (_) => const _DestinationPicker(),
    );

class _DestinationPicker extends ConsumerStatefulWidget {
  const _DestinationPicker();

  @override
  ConsumerState<_DestinationPicker> createState() => _DestinationPickerState();
}

class _DestinationPickerState extends ConsumerState<_DestinationPicker> {
  final _query = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;
  final _clinics = <Clinic>[];
  PaginationMeta? _pagination;
  bool _loading = true;
  bool _loadingMore = false;
  ApiError? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 200 && !_loadingMore && (_pagination?.hasMore ?? false)) {
        unawaited(_load(more: true));
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    final requestId = ++_requestId;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;
      }
    });

    try {
      final page = await ref.read(reportRepositoryProvider).clinics(
            search: _query.text,
            page: more ? (_pagination?.currentPage ?? 0) + 1 : 1,
          );
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        if (!more) {
          _clinics.clear();
        }
        _clinics.addAll(page.items);
        _pagination = page.pagination;
      });
    } on ApiError catch (error) {
      if (mounted && requestId == _requestId) {
        setState(() => _error = error);
      }
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _pickOtherAddress() async {
    final result = await showAddressSearch(context, title: 'Cari alamat tujuan');
    if (result != null && mounted) {
      Navigator.of(context).pop(
        DestinationChoice.place(name: result.label.split(',').first, address: result.label, latitude: result.latitude, longitude: result.longitude),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MedSpace.gutter),
            child: TextField(
              controller: _query,
              textInputAction: TextInputAction.search,
              onChanged: (_) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () => unawaited(_load()));
              },
              decoration: const InputDecoration(
                hintText: 'Cari rumah sakit, puskesmas, klinik',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_location_alt_outlined, color: MedColors.brand),
            title: const Text('Alamat lain (rumah duka, pemakaman, dll.)'),
            subtitle: const Text('Cari dari peta'),
            minTileHeight: 60,
            onTap: _pickOtherAddress,
          ),
          const Divider(),
          Expanded(child: _list()),
        ],
      );

  Widget _list() {
    if (_loading) {
      return const SkeletonList(count: 5, itemHeight: 60);
    }
    if (_error != null) {
      return ErrorRetry(message: _error!.message, isNetwork: _error!.isNetwork, onRetry: _load);
    }
    if (_clinics.isEmpty) {
      return const EmptyState(
        icon: Icons.local_hospital_outlined,
        title: 'Faskes tidak ditemukan',
        message: 'Coba kata kunci lain atau pilih "Alamat lain".',
      );
    }

    return ListView.separated(
      controller: _scroll,
      itemCount: _clinics.length + (_loadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(indent: 64),
      itemBuilder: (context, index) {
        if (index >= _clinics.length) {
          return const Padding(padding: EdgeInsets.all(MedSpace.lg), child: Center(child: CircularProgressIndicator()));
        }
        final clinic = _clinics[index];
        return ListTile(
          leading: const Icon(Icons.local_hospital_rounded, color: MedColors.brand),
          title: Text(clinic.name),
          subtitle: clinic.address == null ? null : Text(clinic.address!, maxLines: 2, overflow: TextOverflow.ellipsis),
          minTileHeight: 64,
          onTap: () => Navigator.of(context).pop(DestinationChoice.clinic(clinic)),
        );
      },
    );
  }
}

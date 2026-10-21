import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

/// Cari alamat lewat `/geocode/search` (proxy backend). Mengembalikan hasil yang dipilih.
Future<GeocodeResult?> showAddressSearch(BuildContext context, {String title = 'Cari alamat penjemputan'}) =>
    showAppBottomSheet<GeocodeResult>(context, title: title, tall: true, builder: (_) => const _AddressSearch());

class _AddressSearch extends ConsumerStatefulWidget {
  const _AddressSearch();

  @override
  ConsumerState<_AddressSearch> createState() => _AddressSearchState();
}

class _AddressSearchState extends ConsumerState<_AddressSearch> {
  final _query = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  List<GeocodeResult>? _results;
  ApiError? _error;
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() {
        _results = null;
        _error = null;
        _loading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () => unawaited(_search(value)));
  }

  Future<void> _search(String value) async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await ref.read(geocodeRepositoryProvider).search(value);
      if (mounted && requestId == _requestId) {
        setState(() => _results = results);
      }
    } on ApiError catch (error) {
      if (mounted && requestId == _requestId) {
        setState(() => _error = error);
      }
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() => _loading = false);
      }
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
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: (value) => value.trim().length >= 3 ? _search(value) : null,
              decoration: const InputDecoration(
                hintText: 'Nama jalan, gedung, atau tempat',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: MedSpace.sm),
          Expanded(child: _body()),
        ],
      );

  Widget _body() {
    if (_loading && _results == null) {
      return const SkeletonList(count: 4, itemHeight: 56);
    }
    if (_error != null) {
      return ErrorRetry(message: _error!.message, isNetwork: _error!.isNetwork, onRetry: () => _search(_query.text));
    }
    if (_results == null) {
      return const EmptyState(
        icon: Icons.travel_explore_rounded,
        title: 'Ketik minimal 3 huruf',
        message: 'Contoh: "RSUP Kariadi" atau "Jl. Pandanaran".',
      );
    }
    if (_results!.isEmpty) {
      return const EmptyState(
        icon: Icons.location_off_outlined,
        title: 'Alamat tidak ditemukan',
        message: 'Coba kata kunci lain, atau geser pin di peta ke lokasi Anda.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: MedSpace.xl),
      itemCount: _results!.length,
      separatorBuilder: (_, _) => const Divider(indent: 64),
      itemBuilder: (context, index) {
        final result = _results![index];
        return ListTile(
          leading: const Icon(Icons.location_on_outlined, color: MedColors.brand),
          title: Text(result.label, maxLines: 2, overflow: TextOverflow.ellipsis),
          minTileHeight: 60,
          onTap: () => Navigator.of(context).pop(result),
        );
      },
    );
  }
}

extension GeocodeResultPoint on GeocodeResult {
  LatLng get point => LatLng(latitude, longitude);
}

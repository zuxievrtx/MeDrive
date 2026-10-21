import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:medrive_core/medrive_core.dart';

import 'device_location.dart';

/// Titik awal peta bila lokasi belum diketahui: Simpang Lima, Semarang (wilayah data contoh backend).
const fallbackCenter = LatLng(-6.9902, 110.4229);

@immutable
class PickupState {
  const PickupState({
    required this.point,
    this.address,
    this.myLocation,
    this.resolving = false,
    this.access,
    this.addressError,
  });

  /// Titik jemput (pusat peta).
  final LatLng point;
  final String? address;
  final LatLng? myLocation;
  final bool resolving;
  final LocationAccess? access;
  final String? addressError;

  bool get hasAddress => address != null && address!.isNotEmpty;

  PickupState copyWith({
    LatLng? point,
    String? address,
    bool clearAddress = false,
    LatLng? myLocation,
    bool? resolving,
    LocationAccess? access,
    String? addressError,
    bool clearAddressError = false,
  }) =>
      PickupState(
        point: point ?? this.point,
        address: clearAddress ? null : (address ?? this.address),
        myLocation: myLocation ?? this.myLocation,
        resolving: resolving ?? this.resolving,
        access: access ?? this.access,
        addressError: clearAddressError ? null : (addressError ?? this.addressError),
      );
}

/// Titik jemput yang dipakai beranda dan form laporan. Alamat diambil lewat proxy backend
/// `/geocode/reverse` setelah peta berhenti digeser (debounce) agar hemat kuota.
class PickupController extends Notifier<PickupState> {
  Timer? _debounce;
  int _requestId = 0;

  @override
  PickupState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const PickupState(point: fallbackCenter);
  }

  /// Minta izin lokasi lalu pindahkan titik jemput ke posisi perangkat.
  Future<LatLng?> locate() async {
    final device = ref.read(deviceLocationProvider);
    final access = await device.ensureAccess();
    state = state.copyWith(access: access);

    if (access != LocationAccess.granted) {
      return null;
    }

    final position = await device.current();
    if (position != null) {
      state = state.copyWith(myLocation: position);
      moveTo(position, immediate: true);
    }
    return position;
  }

  /// Peta digeser ke [point]. Bila [address] sudah diketahui (hasil pencarian), tidak perlu reverse.
  void moveTo(LatLng point, {String? address, bool immediate = false}) {
    _debounce?.cancel();
    state = state.copyWith(point: point, address: address, clearAddress: address == null, clearAddressError: true);

    if (address != null) {
      state = state.copyWith(resolving: false);
      return;
    }

    state = state.copyWith(resolving: true);
    _debounce = Timer(immediate ? Duration.zero : const Duration(milliseconds: 700), () => unawaited(_resolve(point)));
  }

  Future<void> _resolve(LatLng point, {bool retried = false}) async {
    final requestId = ++_requestId;
    try {
      final result = await ref.read(geocodeRepositoryProvider).reverse(point.latitude, point.longitude);
      if (requestId != _requestId) {
        return;
      }
      state = state.copyWith(
        resolving: false,
        address: result.address ?? 'Titik di peta (${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)})',
      );
    } on ApiError catch (error) {
      if (requestId != _requestId) {
        return;
      }
      // Proxy membatasi 1 permintaan/detik ke Nominatim: tunggu sebentar lalu coba sekali lagi.
      if (error.code == 'geocode_busy' && !retried) {
        await Future<void>.delayed(const Duration(milliseconds: 1500));
        if (requestId == _requestId) {
          return _resolve(point, retried: true);
        }
        return;
      }
      state = state.copyWith(resolving: false, addressError: error.message);
    }
  }
}

final pickupProvider = NotifierProvider<PickupController, PickupState>(PickupController.new);

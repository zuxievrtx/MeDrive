import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medrive_core/medrive_core.dart';

import 'driver_state.dart';

@immutable
class DispatchState {
  const DispatchState({this.pending = const [], this.loading = false, this.error});

  /// Tawaran yang masih menunggu jawaban dan belum diabaikan di perangkat ini.
  final List<Dispatch> pending;
  final bool loading;
  final ApiError? error;
}

/// Tawaran dispatch. Push FCM bisa terlambat atau hilang, jadi daftar juga ditarik dari
/// `GET /driver/dispatches/active` saat aplikasi dibuka, kembali ke depan, dan berkala selama
/// standby. Tawaran baru yang belum pernah dibuka diminta tampil layar penuh lewat [openRequests].
class DispatchController extends Notifier<DispatchState> {
  final _dismissed = <int>{};
  final _announced = <int>{};
  final _openRequests = StreamController<int>.broadcast();

  /// Tawaran yang sedang tampil di layar tawaran (mencegah layar ganda).
  int? showing;

  Stream<int> get openRequests => _openRequests.stream;

  @override
  DispatchState build() {
    ref.onDispose(() => unawaited(_openRequests.close()));
    return const DispatchState();
  }

  /// Tarik tawaran aktif bila driver standby (shift terbuka, tidak sedang menangani laporan).
  Future<void> pull() async {
    final driver = ref.read(driverProvider).value;
    if (driver == null || !driver.isActive || driver.hasMission) {
      if (state.pending.isNotEmpty) {
        state = const DispatchState();
      }
      return;
    }

    state = DispatchState(pending: state.pending, loading: true);
    try {
      final dispatches = await ref.read(driverRepositoryProvider).activeDispatches();
      final visible = dispatches.where((dispatch) => dispatch.isPending && !_dismissed.contains(dispatch.id)).toList();
      state = DispatchState(pending: visible);

      final fresh = visible.where((dispatch) => !_announced.contains(dispatch.id) && dispatch.openedAt == null);
      if (fresh.isNotEmpty && showing == null) {
        open(fresh.first.id);
      }
    } on ApiError catch (error) {
      state = DispatchState(pending: state.pending, error: error);
    }
  }

  /// Minta layar tawaran dibuka (dari push, ketukan notifikasi, atau hasil tarik).
  void open(int dispatchId) {
    if (showing == dispatchId) {
      return;
    }
    _announced.add(dispatchId);
    _openRequests.add(dispatchId);
  }

  /// "Abaikan" hanya di perangkat ini: server tidak diberi tahu, tawaran tetap bisa kedaluwarsa
  /// atau diambil driver lain sesuai alur eskalasi.
  void dismiss(int dispatchId) {
    _dismissed.add(dispatchId);
    _remove(dispatchId);
  }

  /// Tawaran sudah dijawab (menang, kalah cepat, atau kedaluwarsa).
  void resolved(int dispatchId) => _remove(dispatchId);

  void _remove(int dispatchId) {
    state = DispatchState(pending: [for (final dispatch in state.pending) if (dispatch.id != dispatchId) dispatch]);
  }
}

final dispatchProvider = NotifierProvider<DispatchController, DispatchState>(DispatchController.new);

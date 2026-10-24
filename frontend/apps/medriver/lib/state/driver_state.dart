import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medrive_core/medrive_core.dart';

import '../services/location_ping.dart';
import 'session.dart';

/// Profil driver + shift terbuka + laporan yang sedang ditangani.
@immutable
class DriverSnapshot {
  const DriverSnapshot({required this.account, this.mission});

  final DriverAccount account;

  /// Laporan aktif (`diambil` s.d. `mengantar_pasien`), null saat standby.
  final Report? mission;

  Shift? get shift => account.openShift;

  bool get isActive => account.hasOpenShift;

  bool get hasMission => mission != null;

  DriverSnapshot copyWith({DriverAccount? account, Report? mission, bool clearMission = false}) =>
      DriverSnapshot(account: account ?? this.account, mission: clearMission ? null : (mission ?? this.mission));
}

/// Sumber kebenaran status driver di aplikasi. Selama shift terbuka, [LocationPingService]
/// dijalankan; begitu shift tertutup (oleh driver atau admin), pelacakan dihentikan.
class DriverController extends AsyncNotifier<DriverSnapshot> {
  StreamSubscription<void>? _shiftClosed;

  DriverRepository get _repository => ref.read(driverRepositoryProvider);

  LocationPingService get _ping => ref.read(locationPingProvider);

  @override
  Future<DriverSnapshot> build() async {
    ref.watch(sessionProvider.select((session) => session.user?.id));
    _shiftClosed ??= ref.read(locationPingProvider).onShiftClosed.listen((_) => unawaited(refresh()));
    ref.onDispose(() {
      unawaited(_shiftClosed?.cancel());
      _shiftClosed = null;
    });
    return _load();
  }

  Future<DriverSnapshot> _load() async {
    final account = await _repository.profile();
    final mission = account.isOnDuty ? await _repository.currentMission() : null;
    _syncTracking(account);
    return DriverSnapshot(account: account, mission: mission);
  }

  void _syncTracking(DriverAccount account) {
    if (account.hasOpenShift) {
      unawaited(_ping.start());
    } else {
      unawaited(_ping.stop());
    }
  }

  /// Muat ulang tanpa mengosongkan tampilan (data lama tetap tampil saat memuat).
  Future<void> refresh() async {
    final result = await AsyncValue.guard(_load);
    if (result.hasError && state.hasValue) {
      // Gagal (mis. offline): pertahankan data terakhir.
      return;
    }
    state = result;
  }

  Future<void> openShift(int ambulanceId) async {
    await _repository.openShift(ambulanceId);
    await refresh();
  }

  Future<void> closeShift(String reason) async {
    await _ping.stop(flushPending: true);
    try {
      await _repository.closeShift(reason);
    } on ApiError {
      // Shift masih terbuka (mis. sedang menangani laporan): lanjutkan pelacakan.
      final current = state.value;
      if (current != null) {
        _syncTracking(current.account);
      }
      rethrow;
    }
    await refresh();
  }

  /// Dipanggil setelah menang mengambil laporan atau status misi berubah.
  void setMission(Report report) {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(mission: report.isActive ? report : null, clearMission: !report.isActive));
  }
}

final driverProvider = AsyncNotifierProvider<DriverController, DriverSnapshot>(DriverController.new);

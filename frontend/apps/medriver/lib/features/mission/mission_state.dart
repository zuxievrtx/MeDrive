import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:uuid/uuid.dart';

import '../../services/location_ping.dart';
import '../../state/driver_state.dart';

/// Langkah berikutnya untuk tombol aksi bertahap di layar misi.
class MissionStep {
  const MissionStep(this.status, this.label, this.icon);

  final String status;
  final String label;
  final IconData icon;

  bool get completes => status == ReportStatus.selesai;
}

/// `diambil → dalam_perjalanan → tiba_di_lokasi → (mengantar_pasien) → selesai`, sama dengan
/// `ReportService::DRIVER_TRANSITIONS`. Jenis ber-tujuan wajib melewati mengantar pasien.
MissionStep? nextMissionStep(Report report) => switch (report.statusValue) {
      ReportStatus.diambil => const MissionStep(ReportStatus.dalamPerjalanan, 'Mulai Perjalanan', Icons.navigation_rounded),
      ReportStatus.dalamPerjalanan => const MissionStep(ReportStatus.tibaDiLokasi, 'Tiba di Lokasi', Icons.place_rounded),
      ReportStatus.tibaDiLokasi => report.requiresDestination
          ? const MissionStep(ReportStatus.mengantarPasien, 'Antar Pasien', Icons.local_hospital_rounded)
          : const MissionStep(ReportStatus.selesai, 'Selesai', Icons.check_circle_rounded),
      ReportStatus.mengantarPasien => const MissionStep(ReportStatus.selesai, 'Selesai', Icons.check_circle_rounded),
      _ => null,
    };

/// Urutan status untuk [StatusStepper]; "Mengantar Pasien" hanya untuk jenis ber-tujuan.
List<String> missionStatuses(Report report) => [
      ReportStatus.diambil,
      ReportStatus.dalamPerjalanan,
      ReportStatus.tibaDiLokasi,
      if (report.requiresDestination) ReportStatus.mengantarPasien,
      ReportStatus.selesai,
    ];

/// Laporan yang ditangani driver (`GET /driver/reports/{id}`) beserta aksinya. Dipakai bersama
/// layar misi, form pasien, dan foto penanganan agar datanya selalu sama.
class MissionController extends AsyncNotifier<Report> {
  MissionController(this.reportId);

  final int reportId;

  /// Satu Idempotency-Key per transisi: retry jaringan untuk status yang sama memakai kunci yang sama.
  final _statusKeys = <String, String>{};

  DriverRepository get _repository => ref.read(driverRepositoryProvider);

  @override
  Future<Report> build() => _repository.report(reportId);

  /// Muat ulang diam-diam (polling cadangan); error tidak menimpa data yang sudah tampil.
  Future<void> reload() async {
    try {
      _apply(await _repository.report(reportId));
    } on ApiError {
      if (!state.hasValue) {
        rethrow;
      }
    }
  }

  Future<Report> advance(String status) async {
    final key = _statusKeys.putIfAbsent(status, () => const Uuid().v4());
    final fix = ref.read(locationPingProvider).status.value.lastFix;
    final report = await _repository.updateStatus(
      reportId,
      status,
      idempotencyKey: key,
      latitude: fix?.latitude,
      longitude: fix?.longitude,
    );
    _apply(report);
    return report;
  }

  Future<ReportPatient> savePatient(PatientInput input, {int? patientId}) async {
    final patient = patientId == null
        ? await _repository.addPatient(reportId, input)
        : await _repository.updatePatient(patientId, input);
    final current = state.value;
    if (current != null) {
      final patients = [...current.patients];
      final index = patients.indexWhere((item) => item.id == patient.id);
      if (index >= 0) {
        patients[index] = patient;
      } else {
        patients.add(patient);
      }
      _apply(current.copyWith(patients: patients));
    }
    return patient;
  }

  Future<List<ReportAttachment>> uploadPhotos(List<String> paths) async {
    final uploaded = await _repository.uploadHandlingPhotos(reportId, paths);
    final current = state.value;
    if (current != null) {
      _apply(current.copyWith(attachments: [...current.attachments, ...uploaded]));
    }
    return uploaded;
  }

  void _apply(Report report) {
    state = AsyncData(report);
    ref.read(driverProvider.notifier).setMission(report);
  }
}

final missionProvider = AsyncNotifierProvider.autoDispose.family<MissionController, Report, int>(MissionController.new);

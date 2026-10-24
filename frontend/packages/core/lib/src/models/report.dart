import 'package:freezed_annotation/freezed_annotation.dart';

import 'common.dart';
import 'report_type.dart';

part 'report.freezed.dart';
part 'report.g.dart';

/// Status laporan (nilai `reports.status`).
abstract final class ReportStatus {
  static const menunggu = 'menunggu';
  static const diambil = 'diambil';
  static const dalamPerjalanan = 'dalam_perjalanan';
  static const tibaDiLokasi = 'tiba_di_lokasi';
  static const mengantarPasien = 'mengantar_pasien';
  static const selesai = 'selesai';
  static const dibatalkan = 'dibatalkan';

  /// Laporan sedang ditangani driver: pelacakan dan chat tersedia.
  static const active = [diambil, dalamPerjalanan, tibaDiLokasi, mengantarPasien];

  static const ordered = [menunggu, diambil, dalamPerjalanan, tibaDiLokasi, mengantarPasien, selesai];

  static const labels = {
    menunggu: 'Menunggu',
    diambil: 'Diambil',
    dalamPerjalanan: 'Dalam Perjalanan',
    tibaDiLokasi: 'Tiba di Lokasi',
    mengantarPasien: 'Mengantar Pasien',
    selesai: 'Selesai',
    dibatalkan: 'Dibatalkan',
  };

  static String label(String status) => labels[status] ?? status;

  static bool isActive(String status) => active.contains(status);

  static bool isClosed(String status) => status == selesai || status == dibatalkan;
}

@freezed
abstract class ReportDestination with _$ReportDestination {
  const factory ReportDestination({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
  }) = _ReportDestination;

  factory ReportDestination.fromJson(Map<String, dynamic> json) => _$ReportDestinationFromJson(json);
}

@freezed
abstract class ReportDriver with _$ReportDriver {
  const factory ReportDriver({
    required int id,
    required String name,
    String? phone,
    @Default(false) bool isVerified,
    String? photoUrl,
    String? clinic,
  }) = _ReportDriver;

  factory ReportDriver.fromJson(Map<String, dynamic> json) => _$ReportDriverFromJson(json);
}

/// Pelapor pada laporan yang ditangani driver (`GET /driver/reports/{id}`).
@freezed
abstract class ReportReporter with _$ReportReporter {
  const factory ReportReporter({
    required int id,
    required String name,
    String? phone,
  }) = _ReportReporter;

  factory ReportReporter.fromJson(Map<String, dynamic> json) => _$ReportReporterFromJson(json);
}

@freezed
abstract class ReportAmbulance with _$ReportAmbulance {
  const factory ReportAmbulance({
    int? id,
    required String plateNumber,
    String? vehicleName,
    String? type,
    String? mapIcon,
    String? clinic,
  }) = _ReportAmbulance;

  factory ReportAmbulance.fromJson(Map<String, dynamic> json) => _$ReportAmbulanceFromJson(json);
}

@freezed
abstract class ReportPatient with _$ReportPatient {
  const factory ReportPatient({
    required int id,
    String? name,
    String? gender,
    int? ageEstimate,
    LabeledValue? consciousness,
    bool? isBreathing,
    String? conditionNote,
    String? handedOverTo,
    DateTime? handedOverAt,
  }) = _ReportPatient;

  factory ReportPatient.fromJson(Map<String, dynamic> json) => _$ReportPatientFromJson(json);
}

@freezed
abstract class ReportAttachment with _$ReportAttachment {
  const factory ReportAttachment({
    required int id,
    required LabeledValue type,
    String? mimeType,
    @Default(true) bool isImage,
    int? sizeKb,
    required String url,
    DateTime? createdAt,
  }) = _ReportAttachment;

  factory ReportAttachment.fromJson(Map<String, dynamic> json) => _$ReportAttachmentFromJson(json);
}

@freezed
abstract class ReportStatusLog with _$ReportStatusLog {
  const factory ReportStatusLog({
    required int id,
    LabeledValue? fromStatus,
    required LabeledValue toStatus,
    String? note,
    DateTime? createdAt,
  }) = _ReportStatusLog;

  factory ReportStatusLog.fromJson(Map<String, dynamic> json) => _$ReportStatusLogFromJson(json);
}

/// Detail khusus jenis laporan (tepat satu tabel detail v3), dibedakan oleh `kind`.
@Freezed(unionKey: 'kind', fallbackUnion: 'unknown')
sealed class ReportDetails with _$ReportDetails {
  @FreezedUnionValue('kecelakaan')
  const factory ReportDetails.accident({
    LabeledValue? accidentType,
    int? estimatedVictimCount,
    bool? hasTrappedVictim,
    bool? hasFireHazard,
    bool? isRoadBlocked,
  }) = AccidentDetails;

  @FreezedUnionValue('medis')
  const factory ReportDetails.medical({
    LabeledValue? medicalCategory,
    DateTime? symptomOnsetAt,
    bool? hasMedicalHistory,
    String? medicalHistoryNotes,
  }) = MedicalDetails;

  @FreezedUnionValue('ibu_hamil')
  const factory ReportDetails.maternity({
    int? gestationalAgeWeeks,
    int? contractionIntervalMinutes,
    bool? isWaterBroken,
    bool? hasBleeding,
    int? pregnancyNumber,
    ReportDetailClinic? destinationClinic,
  }) = MaternityDetails;

  @FreezedUnionValue('jenazah')
  const factory ReportDetails.funeral({
    String? deceasedName,
    LabeledValue? pickupPlaceType,
    DateTime? scheduledPickupAt,
    bool? hasDeathCertificate,
    String? familyContactName,
    String? familyContactPhone,
  }) = FuneralDetails;

  const factory ReportDetails.unknown() = UnknownDetails;

  factory ReportDetails.fromJson(Map<String, dynamic> json) => _$ReportDetailsFromJson(json);
}

@freezed
abstract class ReportDetailClinic with _$ReportDetailClinic {
  const factory ReportDetailClinic({required int id, required String name}) = _ReportDetailClinic;

  factory ReportDetailClinic.fromJson(Map<String, dynamic> json) => _$ReportDetailClinicFromJson(json);
}

/// Laporan. Daftar memuat ringkasan; detail (`GET /reporter/reports/{id}`) mengisi field sisanya.
@freezed
abstract class Report with _$Report {
  const Report._();

  const factory Report({
    required int id,
    required String code,
    required LabeledValue status,
    ReportType? reportType,
    String? address,
    String? shortAddress,
    required double latitude,
    required double longitude,
    ReportDestination? destination,
    ReportDriver? driver,
    ReportReporter? reporter,
    ReportAmbulance? ambulance,
    DateTime? createdAt,
    DateTime? takenAt,
    DateTime? arrivedAt,
    DateTime? completedAt,
    int? responseTimeMinutes,
    int? waitingMinutes,
    String? description,
    ReportDetails? details,
    @Default([]) List<ReportPatient> patients,
    @Default([]) List<ReportAttachment> attachments,
    @Default([]) List<ReportStatusLog> timeline,
    @Default(false) bool isTrackingAvailable,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

  String get statusValue => status.value;

  bool get isActive => ReportStatus.isActive(status.value);

  bool get isClosed => ReportStatus.isClosed(status.value);

  bool get isWaiting => status.value == ReportStatus.menunggu;

  String get typeName => reportType?.name ?? 'Laporan';

  /// Jenis laporan dengan tujuan antar (ibu hamil, jenazah) wajib melewati `mengantar_pasien`.
  bool get requiresDestination => reportType?.requiresDestination ?? false;

  /// Serah terima lengkap: minimal satu pasien dan setiap pasien punya penerima.
  bool get allPatientsHandedOver =>
      patients.isNotEmpty && patients.every((patient) => (patient.handedOverTo ?? '').trim().isNotEmpty);
}

import 'package:freezed_annotation/freezed_annotation.dart';

import 'common.dart';
import 'report.dart';

part 'driver.freezed.dart';
part 'driver.g.dart';

/// Status masa berlaku SIM / sertifikat dari backend: `valid`, `expiring` (≤ 60 hari), `expired`,
/// atau `lifetime` (sertifikat tanpa tanggal kedaluwarsa).
abstract final class ExpiryState {
  static const valid = 'valid';
  static const expiring = 'expiring';
  static const expired = 'expired';
  static const lifetime = 'lifetime';

  static String label(String? state) => switch (state) {
        expired => 'Kedaluwarsa',
        expiring => 'Segera kedaluwarsa',
        lifetime => 'Berlaku seumur hidup',
        _ => 'Berlaku',
      };
}

/// Data kepegawaian driver (`driver_profile` di `/me` dan `/driver/profile`).
@freezed
abstract class DriverProfile with _$DriverProfile {
  const factory DriverProfile({
    int? clinicId,
    Clinic? clinic,
    String? employeeNumber,
    String? licenseNumber,
    LabeledValue? licenseClass,
    DateTime? licenseExpiresAt,
    String? licenseExpiryState,
    String? photoUrl,
    @Default(false) bool isOnDuty,
  }) = _DriverProfile;

  factory DriverProfile.fromJson(Map<String, dynamic> json) => _$DriverProfileFromJson(json);
}

@freezed
abstract class DriverCertification with _$DriverCertification {
  const DriverCertification._();

  const factory DriverCertification({
    required int id,
    required String name,
    String? certificateNumber,
    String? issuer,
    DateTime? issuedAt,
    DateTime? expiresAt,
    String? expiryState,
    String? fileUrl,
  }) = _DriverCertification;

  factory DriverCertification.fromJson(Map<String, dynamic> json) => _$DriverCertificationFromJson(json);

  bool get isExpired => expiryState == ExpiryState.expired;
}

@freezed
abstract class AmbulanceType with _$AmbulanceType {
  const factory AmbulanceType({
    required int id,
    required String code,
    required String name,
    String? description,
    String? mapIcon,
  }) = _AmbulanceType;

  factory AmbulanceType.fromJson(Map<String, dynamic> json) => _$AmbulanceTypeFromJson(json);
}

/// Ambulans milik klinik driver (`GET /driver/ambulances/available`, `open_shift.ambulance`).
@freezed
abstract class Ambulance with _$Ambulance {
  const factory Ambulance({
    required int id,
    required String plateNumber,
    String? vehicleName,
    int? year,
    LabeledValue? status,
    String? notes,
    int? clinicId,
    AmbulanceType? ambulanceType,
  }) = _Ambulance;

  factory Ambulance.fromJson(Map<String, dynamic> json) => _$AmbulanceFromJson(json);
}

/// Shift driver. Driver "Aktif" = punya shift terbuka.
@freezed
abstract class Shift with _$Shift {
  const factory Shift({
    required int id,
    int? driverId,
    DateTime? startedAt,
    DateTime? endedAt,
    LabeledValue? endReason,
    @Default(false) bool isOpen,
    Ambulance? ambulance,
  }) = _Shift;

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);
}

/// Profil lengkap driver dari `GET /driver/profile`: akun + kepegawaian + shift terbuka +
/// sertifikat + badge terverifikasi. Tidak ada rating dalam bentuk apa pun.
@freezed
abstract class DriverAccount with _$DriverAccount {
  const DriverAccount._();

  const factory DriverAccount({
    required int id,
    required String name,
    String? initials,
    String? phone,
    required String email,
    DriverProfile? driverProfile,
    Shift? openShift,
    @Default(false) bool isVerified,
    @Default([]) List<DriverCertification> certifications,
  }) = _DriverAccount;

  factory DriverAccount.fromJson(Map<String, dynamic> json) => _$DriverAccountFromJson(json);

  bool get hasOpenShift => openShift != null;

  bool get isOnDuty => driverProfile?.isOnDuty ?? false;

  String get displayInitials {
    if (initials != null && initials!.isNotEmpty) {
      return initials!;
    }
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).take(2);
    return parts.map((part) => part[0].toUpperCase()).join();
  }
}

/// Jawaban driver atas tawaran (`report_dispatches.response`).
abstract final class DispatchResponse {
  static const menunggu = 'menunggu';
  static const diterima = 'diterima';
  static const kalahCepat = 'kalah_cepat';
  static const kedaluwarsa = 'kedaluwarsa';
  static const diabaikan = 'diabaikan';
}

/// Tawaran laporan untuk driver (`report_dispatches`): dari `GET /driver/dispatches/active`
/// (ringkas) atau `GET /driver/dispatches/{id}` (laporan lengkap).
@freezed
abstract class Dispatch with _$Dispatch {
  const Dispatch._();

  const factory Dispatch({
    required int id,
    required int reportId,
    @Default(0) double distanceKm,
    DateTime? sentAt,
    DateTime? openedAt,
    DateTime? respondedAt,
    LabeledValue? response,
    Report? report,
  }) = _Dispatch;

  factory Dispatch.fromJson(Map<String, dynamic> json) => _$DispatchFromJson(json);

  bool get isPending => (response?.value ?? DispatchResponse.menunggu) == DispatchResponse.menunggu;
}

/// Tawaran yang datang lewat push FCM `type=dispatch` (data message berisi string).
/// Cukup untuk membuka layar tawaran; isi lengkap diambil dari `GET /driver/dispatches/{id}`.
class DispatchOffer {
  const DispatchOffer({
    required this.dispatchId,
    required this.reportId,
    this.reportCode,
    this.reportTypeCode,
    this.distanceKm,
    this.priority,
  });

  /// `null` bila data push bukan tawaran atau tidak lengkap.
  static DispatchOffer? fromPushData(Map<String, String> data) {
    if (data['type'] != 'dispatch') {
      return null;
    }
    final dispatchId = int.tryParse(data['dispatch_id'] ?? '');
    final reportId = int.tryParse(data['report_id'] ?? '');
    if (dispatchId == null || reportId == null) {
      return null;
    }
    return DispatchOffer(
      dispatchId: dispatchId,
      reportId: reportId,
      reportCode: data['report_code'],
      reportTypeCode: data['report_type'],
      distanceKm: double.tryParse(data['distance_km'] ?? ''),
      priority: int.tryParse(data['priority'] ?? ''),
    );
  }

  final int dispatchId;
  final int reportId;
  final String? reportCode;
  final String? reportTypeCode;
  final double? distanceKm;
  final int? priority;
}

/// Isi form pasien & serah terima (`POST /driver/reports/{id}/patients`, `PUT /driver/patients/{id}`).
/// Semua field opsional di backend; field kosong dikirim `null` agar bisa dikosongkan lagi.
class PatientInput {
  const PatientInput({
    this.name,
    this.gender,
    this.ageEstimate,
    this.consciousness,
    this.isBreathing,
    this.conditionNote,
    this.handedOverTo,
    this.handedOverAt,
  });

  factory PatientInput.fromPatient(ReportPatient patient) => PatientInput(
        name: patient.name,
        gender: patient.gender,
        ageEstimate: patient.ageEstimate,
        consciousness: patient.consciousness?.value,
        isBreathing: patient.isBreathing,
        conditionNote: patient.conditionNote,
        handedOverTo: patient.handedOverTo,
        handedOverAt: patient.handedOverAt,
      );

  final String? name;

  /// `L` atau `P`.
  final String? gender;
  final int? ageEstimate;

  /// `sadar`, `tidak_sadar`, atau `tidak_diketahui`.
  final String? consciousness;
  final bool? isBreathing;
  final String? conditionNote;
  final String? handedOverTo;
  final DateTime? handedOverAt;

  Map<String, dynamic> toJson() => {
        'name': _blankToNull(name),
        'gender': gender,
        'age_estimate': ageEstimate,
        'consciousness': consciousness,
        'is_breathing': isBreathing,
        'condition_note': _blankToNull(conditionNote),
        'handed_over_to': _blankToNull(handedOverTo),
        'handed_over_at': handedOverAt == null ? null : formatIsoWithOffset(handedOverAt!),
      };

  static String? _blankToNull(String? value) => value == null || value.trim().isEmpty ? null : value.trim();
}

/// ISO 8601 dengan zona waktu perangkat (`2026-10-15T10:12:03.120+07:00`), format yang diminta
/// backend untuk `recorded_at` dan `handed_over_at`.
String formatIsoWithOffset(DateTime value) {
  final local = value.toLocal();
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  String two(int number) => number.toString().padLeft(2, '0');
  final millis = local.millisecond.toString().padLeft(3, '0');

  return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-${two(local.day)}'
      'T${two(local.hour)}:${two(local.minute)}:${two(local.second)}.$millis$sign$hours:$minutes';
}

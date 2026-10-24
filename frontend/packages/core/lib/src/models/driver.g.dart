// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverProfile _$DriverProfileFromJson(Map<String, dynamic> json) =>
    _DriverProfile(
      clinicId: (json['clinic_id'] as num?)?.toInt(),
      clinic: json['clinic'] == null
          ? null
          : Clinic.fromJson(json['clinic'] as Map<String, dynamic>),
      employeeNumber: json['employee_number'] as String?,
      licenseNumber: json['license_number'] as String?,
      licenseClass: json['license_class'] == null
          ? null
          : LabeledValue.fromJson(
              json['license_class'] as Map<String, dynamic>,
            ),
      licenseExpiresAt: json['license_expires_at'] == null
          ? null
          : DateTime.parse(json['license_expires_at'] as String),
      licenseExpiryState: json['license_expiry_state'] as String?,
      photoUrl: json['photo_url'] as String?,
      isOnDuty: json['is_on_duty'] as bool? ?? false,
    );

Map<String, dynamic> _$DriverProfileToJson(_DriverProfile instance) =>
    <String, dynamic>{
      'clinic_id': instance.clinicId,
      'clinic': instance.clinic?.toJson(),
      'employee_number': instance.employeeNumber,
      'license_number': instance.licenseNumber,
      'license_class': instance.licenseClass?.toJson(),
      'license_expires_at': instance.licenseExpiresAt?.toIso8601String(),
      'license_expiry_state': instance.licenseExpiryState,
      'photo_url': instance.photoUrl,
      'is_on_duty': instance.isOnDuty,
    };

_DriverCertification _$DriverCertificationFromJson(Map<String, dynamic> json) =>
    _DriverCertification(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      certificateNumber: json['certificate_number'] as String?,
      issuer: json['issuer'] as String?,
      issuedAt: json['issued_at'] == null
          ? null
          : DateTime.parse(json['issued_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      expiryState: json['expiry_state'] as String?,
      fileUrl: json['file_url'] as String?,
    );

Map<String, dynamic> _$DriverCertificationToJson(
  _DriverCertification instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'certificate_number': instance.certificateNumber,
  'issuer': instance.issuer,
  'issued_at': instance.issuedAt?.toIso8601String(),
  'expires_at': instance.expiresAt?.toIso8601String(),
  'expiry_state': instance.expiryState,
  'file_url': instance.fileUrl,
};

_AmbulanceType _$AmbulanceTypeFromJson(Map<String, dynamic> json) =>
    _AmbulanceType(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      mapIcon: json['map_icon'] as String?,
    );

Map<String, dynamic> _$AmbulanceTypeToJson(_AmbulanceType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'map_icon': instance.mapIcon,
    };

_Ambulance _$AmbulanceFromJson(Map<String, dynamic> json) => _Ambulance(
  id: (json['id'] as num).toInt(),
  plateNumber: json['plate_number'] as String,
  vehicleName: json['vehicle_name'] as String?,
  year: (json['year'] as num?)?.toInt(),
  status: json['status'] == null
      ? null
      : LabeledValue.fromJson(json['status'] as Map<String, dynamic>),
  notes: json['notes'] as String?,
  clinicId: (json['clinic_id'] as num?)?.toInt(),
  ambulanceType: json['ambulance_type'] == null
      ? null
      : AmbulanceType.fromJson(json['ambulance_type'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AmbulanceToJson(_Ambulance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plate_number': instance.plateNumber,
      'vehicle_name': instance.vehicleName,
      'year': instance.year,
      'status': instance.status?.toJson(),
      'notes': instance.notes,
      'clinic_id': instance.clinicId,
      'ambulance_type': instance.ambulanceType?.toJson(),
    };

_Shift _$ShiftFromJson(Map<String, dynamic> json) => _Shift(
  id: (json['id'] as num).toInt(),
  driverId: (json['driver_id'] as num?)?.toInt(),
  startedAt: json['started_at'] == null
      ? null
      : DateTime.parse(json['started_at'] as String),
  endedAt: json['ended_at'] == null
      ? null
      : DateTime.parse(json['ended_at'] as String),
  endReason: json['end_reason'] == null
      ? null
      : LabeledValue.fromJson(json['end_reason'] as Map<String, dynamic>),
  isOpen: json['is_open'] as bool? ?? false,
  ambulance: json['ambulance'] == null
      ? null
      : Ambulance.fromJson(json['ambulance'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ShiftToJson(_Shift instance) => <String, dynamic>{
  'id': instance.id,
  'driver_id': instance.driverId,
  'started_at': instance.startedAt?.toIso8601String(),
  'ended_at': instance.endedAt?.toIso8601String(),
  'end_reason': instance.endReason?.toJson(),
  'is_open': instance.isOpen,
  'ambulance': instance.ambulance?.toJson(),
};

_DriverAccount _$DriverAccountFromJson(
  Map<String, dynamic> json,
) => _DriverAccount(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  initials: json['initials'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String,
  driverProfile: json['driver_profile'] == null
      ? null
      : DriverProfile.fromJson(json['driver_profile'] as Map<String, dynamic>),
  openShift: json['open_shift'] == null
      ? null
      : Shift.fromJson(json['open_shift'] as Map<String, dynamic>),
  isVerified: json['is_verified'] as bool? ?? false,
  certifications:
      (json['certifications'] as List<dynamic>?)
          ?.map((e) => DriverCertification.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$DriverAccountToJson(_DriverAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'initials': instance.initials,
      'phone': instance.phone,
      'email': instance.email,
      'driver_profile': instance.driverProfile?.toJson(),
      'open_shift': instance.openShift?.toJson(),
      'is_verified': instance.isVerified,
      'certifications': instance.certifications.map((e) => e.toJson()).toList(),
    };

_Dispatch _$DispatchFromJson(Map<String, dynamic> json) => _Dispatch(
  id: (json['id'] as num).toInt(),
  reportId: (json['report_id'] as num).toInt(),
  distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
  sentAt: json['sent_at'] == null
      ? null
      : DateTime.parse(json['sent_at'] as String),
  openedAt: json['opened_at'] == null
      ? null
      : DateTime.parse(json['opened_at'] as String),
  respondedAt: json['responded_at'] == null
      ? null
      : DateTime.parse(json['responded_at'] as String),
  response: json['response'] == null
      ? null
      : LabeledValue.fromJson(json['response'] as Map<String, dynamic>),
  report: json['report'] == null
      ? null
      : Report.fromJson(json['report'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DispatchToJson(_Dispatch instance) => <String, dynamic>{
  'id': instance.id,
  'report_id': instance.reportId,
  'distance_km': instance.distanceKm,
  'sent_at': instance.sentAt?.toIso8601String(),
  'opened_at': instance.openedAt?.toIso8601String(),
  'responded_at': instance.respondedAt?.toIso8601String(),
  'response': instance.response?.toJson(),
  'report': instance.report?.toJson(),
};

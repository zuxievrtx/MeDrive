// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportDestination _$ReportDestinationFromJson(Map<String, dynamic> json) =>
    _ReportDestination(
      name: json['name'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ReportDestinationToJson(_ReportDestination instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_ReportDriver _$ReportDriverFromJson(Map<String, dynamic> json) =>
    _ReportDriver(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      phone: json['phone'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      photoUrl: json['photo_url'] as String?,
      clinic: json['clinic'] as String?,
    );

Map<String, dynamic> _$ReportDriverToJson(_ReportDriver instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'is_verified': instance.isVerified,
      'photo_url': instance.photoUrl,
      'clinic': instance.clinic,
    };

_ReportReporter _$ReportReporterFromJson(Map<String, dynamic> json) =>
    _ReportReporter(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$ReportReporterToJson(_ReportReporter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
    };

_ReportAmbulance _$ReportAmbulanceFromJson(Map<String, dynamic> json) =>
    _ReportAmbulance(
      id: (json['id'] as num?)?.toInt(),
      plateNumber: json['plate_number'] as String,
      vehicleName: json['vehicle_name'] as String?,
      type: json['type'] as String?,
      mapIcon: json['map_icon'] as String?,
      clinic: json['clinic'] as String?,
    );

Map<String, dynamic> _$ReportAmbulanceToJson(_ReportAmbulance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plate_number': instance.plateNumber,
      'vehicle_name': instance.vehicleName,
      'type': instance.type,
      'map_icon': instance.mapIcon,
      'clinic': instance.clinic,
    };

_ReportPatient _$ReportPatientFromJson(Map<String, dynamic> json) =>
    _ReportPatient(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      gender: json['gender'] as String?,
      ageEstimate: (json['age_estimate'] as num?)?.toInt(),
      consciousness: json['consciousness'] == null
          ? null
          : LabeledValue.fromJson(
              json['consciousness'] as Map<String, dynamic>,
            ),
      isBreathing: json['is_breathing'] as bool?,
      conditionNote: json['condition_note'] as String?,
      handedOverTo: json['handed_over_to'] as String?,
      handedOverAt: json['handed_over_at'] == null
          ? null
          : DateTime.parse(json['handed_over_at'] as String),
    );

Map<String, dynamic> _$ReportPatientToJson(_ReportPatient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'gender': instance.gender,
      'age_estimate': instance.ageEstimate,
      'consciousness': instance.consciousness?.toJson(),
      'is_breathing': instance.isBreathing,
      'condition_note': instance.conditionNote,
      'handed_over_to': instance.handedOverTo,
      'handed_over_at': instance.handedOverAt?.toIso8601String(),
    };

_ReportAttachment _$ReportAttachmentFromJson(Map<String, dynamic> json) =>
    _ReportAttachment(
      id: (json['id'] as num).toInt(),
      type: LabeledValue.fromJson(json['type'] as Map<String, dynamic>),
      mimeType: json['mime_type'] as String?,
      isImage: json['is_image'] as bool? ?? true,
      sizeKb: (json['size_kb'] as num?)?.toInt(),
      url: json['url'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ReportAttachmentToJson(_ReportAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type.toJson(),
      'mime_type': instance.mimeType,
      'is_image': instance.isImage,
      'size_kb': instance.sizeKb,
      'url': instance.url,
      'created_at': instance.createdAt?.toIso8601String(),
    };

_ReportStatusLog _$ReportStatusLogFromJson(Map<String, dynamic> json) =>
    _ReportStatusLog(
      id: (json['id'] as num).toInt(),
      fromStatus: json['from_status'] == null
          ? null
          : LabeledValue.fromJson(json['from_status'] as Map<String, dynamic>),
      toStatus: LabeledValue.fromJson(
        json['to_status'] as Map<String, dynamic>,
      ),
      note: json['note'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ReportStatusLogToJson(_ReportStatusLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'from_status': instance.fromStatus?.toJson(),
      'to_status': instance.toStatus.toJson(),
      'note': instance.note,
      'created_at': instance.createdAt?.toIso8601String(),
    };

AccidentDetails _$AccidentDetailsFromJson(Map<String, dynamic> json) =>
    AccidentDetails(
      accidentType: json['accident_type'] == null
          ? null
          : LabeledValue.fromJson(
              json['accident_type'] as Map<String, dynamic>,
            ),
      estimatedVictimCount: (json['estimated_victim_count'] as num?)?.toInt(),
      hasTrappedVictim: json['has_trapped_victim'] as bool?,
      hasFireHazard: json['has_fire_hazard'] as bool?,
      isRoadBlocked: json['is_road_blocked'] as bool?,
      $type: json['kind'] as String?,
    );

Map<String, dynamic> _$AccidentDetailsToJson(AccidentDetails instance) =>
    <String, dynamic>{
      'accident_type': instance.accidentType?.toJson(),
      'estimated_victim_count': instance.estimatedVictimCount,
      'has_trapped_victim': instance.hasTrappedVictim,
      'has_fire_hazard': instance.hasFireHazard,
      'is_road_blocked': instance.isRoadBlocked,
      'kind': instance.$type,
    };

MedicalDetails _$MedicalDetailsFromJson(Map<String, dynamic> json) =>
    MedicalDetails(
      medicalCategory: json['medical_category'] == null
          ? null
          : LabeledValue.fromJson(
              json['medical_category'] as Map<String, dynamic>,
            ),
      symptomOnsetAt: json['symptom_onset_at'] == null
          ? null
          : DateTime.parse(json['symptom_onset_at'] as String),
      hasMedicalHistory: json['has_medical_history'] as bool?,
      medicalHistoryNotes: json['medical_history_notes'] as String?,
      $type: json['kind'] as String?,
    );

Map<String, dynamic> _$MedicalDetailsToJson(MedicalDetails instance) =>
    <String, dynamic>{
      'medical_category': instance.medicalCategory?.toJson(),
      'symptom_onset_at': instance.symptomOnsetAt?.toIso8601String(),
      'has_medical_history': instance.hasMedicalHistory,
      'medical_history_notes': instance.medicalHistoryNotes,
      'kind': instance.$type,
    };

MaternityDetails _$MaternityDetailsFromJson(Map<String, dynamic> json) =>
    MaternityDetails(
      gestationalAgeWeeks: (json['gestational_age_weeks'] as num?)?.toInt(),
      contractionIntervalMinutes: (json['contraction_interval_minutes'] as num?)
          ?.toInt(),
      isWaterBroken: json['is_water_broken'] as bool?,
      hasBleeding: json['has_bleeding'] as bool?,
      pregnancyNumber: (json['pregnancy_number'] as num?)?.toInt(),
      destinationClinic: json['destination_clinic'] == null
          ? null
          : ReportDetailClinic.fromJson(
              json['destination_clinic'] as Map<String, dynamic>,
            ),
      $type: json['kind'] as String?,
    );

Map<String, dynamic> _$MaternityDetailsToJson(MaternityDetails instance) =>
    <String, dynamic>{
      'gestational_age_weeks': instance.gestationalAgeWeeks,
      'contraction_interval_minutes': instance.contractionIntervalMinutes,
      'is_water_broken': instance.isWaterBroken,
      'has_bleeding': instance.hasBleeding,
      'pregnancy_number': instance.pregnancyNumber,
      'destination_clinic': instance.destinationClinic?.toJson(),
      'kind': instance.$type,
    };

FuneralDetails _$FuneralDetailsFromJson(Map<String, dynamic> json) =>
    FuneralDetails(
      deceasedName: json['deceased_name'] as String?,
      pickupPlaceType: json['pickup_place_type'] == null
          ? null
          : LabeledValue.fromJson(
              json['pickup_place_type'] as Map<String, dynamic>,
            ),
      scheduledPickupAt: json['scheduled_pickup_at'] == null
          ? null
          : DateTime.parse(json['scheduled_pickup_at'] as String),
      hasDeathCertificate: json['has_death_certificate'] as bool?,
      familyContactName: json['family_contact_name'] as String?,
      familyContactPhone: json['family_contact_phone'] as String?,
      $type: json['kind'] as String?,
    );

Map<String, dynamic> _$FuneralDetailsToJson(FuneralDetails instance) =>
    <String, dynamic>{
      'deceased_name': instance.deceasedName,
      'pickup_place_type': instance.pickupPlaceType?.toJson(),
      'scheduled_pickup_at': instance.scheduledPickupAt?.toIso8601String(),
      'has_death_certificate': instance.hasDeathCertificate,
      'family_contact_name': instance.familyContactName,
      'family_contact_phone': instance.familyContactPhone,
      'kind': instance.$type,
    };

UnknownDetails _$UnknownDetailsFromJson(Map<String, dynamic> json) =>
    UnknownDetails($type: json['kind'] as String?);

Map<String, dynamic> _$UnknownDetailsToJson(UnknownDetails instance) =>
    <String, dynamic>{'kind': instance.$type};

_ReportDetailClinic _$ReportDetailClinicFromJson(Map<String, dynamic> json) =>
    _ReportDetailClinic(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$ReportDetailClinicToJson(_ReportDetailClinic instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_Report _$ReportFromJson(Map<String, dynamic> json) => _Report(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  status: LabeledValue.fromJson(json['status'] as Map<String, dynamic>),
  reportType: json['report_type'] == null
      ? null
      : ReportType.fromJson(json['report_type'] as Map<String, dynamic>),
  address: json['address'] as String?,
  shortAddress: json['short_address'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  destination: json['destination'] == null
      ? null
      : ReportDestination.fromJson(json['destination'] as Map<String, dynamic>),
  driver: json['driver'] == null
      ? null
      : ReportDriver.fromJson(json['driver'] as Map<String, dynamic>),
  reporter: json['reporter'] == null
      ? null
      : ReportReporter.fromJson(json['reporter'] as Map<String, dynamic>),
  ambulance: json['ambulance'] == null
      ? null
      : ReportAmbulance.fromJson(json['ambulance'] as Map<String, dynamic>),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  takenAt: json['taken_at'] == null
      ? null
      : DateTime.parse(json['taken_at'] as String),
  arrivedAt: json['arrived_at'] == null
      ? null
      : DateTime.parse(json['arrived_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  responseTimeMinutes: (json['response_time_minutes'] as num?)?.toInt(),
  waitingMinutes: (json['waiting_minutes'] as num?)?.toInt(),
  description: json['description'] as String?,
  details: json['details'] == null
      ? null
      : ReportDetails.fromJson(json['details'] as Map<String, dynamic>),
  patients:
      (json['patients'] as List<dynamic>?)
          ?.map((e) => ReportPatient.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => ReportAttachment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  timeline:
      (json['timeline'] as List<dynamic>?)
          ?.map((e) => ReportStatusLog.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isTrackingAvailable: json['is_tracking_available'] as bool? ?? false,
);

Map<String, dynamic> _$ReportToJson(_Report instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'status': instance.status.toJson(),
  'report_type': instance.reportType?.toJson(),
  'address': instance.address,
  'short_address': instance.shortAddress,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'destination': instance.destination?.toJson(),
  'driver': instance.driver?.toJson(),
  'reporter': instance.reporter?.toJson(),
  'ambulance': instance.ambulance?.toJson(),
  'created_at': instance.createdAt?.toIso8601String(),
  'taken_at': instance.takenAt?.toIso8601String(),
  'arrived_at': instance.arrivedAt?.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
  'response_time_minutes': instance.responseTimeMinutes,
  'waiting_minutes': instance.waitingMinutes,
  'description': instance.description,
  'details': instance.details?.toJson(),
  'patients': instance.patients.map((e) => e.toJson()).toList(),
  'attachments': instance.attachments.map((e) => e.toJson()).toList(),
  'timeline': instance.timeline.map((e) => e.toJson()).toList(),
  'is_tracking_available': instance.isTrackingAvailable,
};

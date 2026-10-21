// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LabeledValue _$LabeledValueFromJson(Map<String, dynamic> json) =>
    _LabeledValue(
      value: json['value'] as String,
      label: json['label'] as String,
      tone: json['tone'] as String?,
    );

Map<String, dynamic> _$LabeledValueToJson(_LabeledValue instance) =>
    <String, dynamic>{
      'value': instance.value,
      'label': instance.label,
      'tone': instance.tone,
    };

_DriverLocation _$DriverLocationFromJson(Map<String, dynamic> json) =>
    _DriverLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      heading: (json['heading'] as num?)?.toInt(),
      speedKmh: (json['speed_kmh'] as num?)?.toDouble(),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$DriverLocationToJson(_DriverLocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'heading': instance.heading,
      'speed_kmh': instance.speedKmh,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_Clinic _$ClinicFromJson(Map<String, dynamic> json) => _Clinic(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String?,
  address: json['address'] as String?,
  phone: json['phone'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  type: json['type'] == null
      ? null
      : LabeledValue.fromJson(json['type'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ClinicToJson(_Clinic instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'address': instance.address,
  'phone': instance.phone,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'type': instance.type?.toJson(),
};

_GeocodeResult _$GeocodeResultFromJson(Map<String, dynamic> json) =>
    _GeocodeResult(
      label: json['label'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$GeocodeResultToJson(_GeocodeResult instance) =>
    <String, dynamic>{
      'label': instance.label,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_ReverseGeocode _$ReverseGeocodeFromJson(Map<String, dynamic> json) =>
    _ReverseGeocode(
      address: json['address'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$ReverseGeocodeToJson(_ReverseGeocode instance) =>
    <String, dynamic>{
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_RouteResult _$RouteResultFromJson(Map<String, dynamic> json) => _RouteResult(
  reportId: (json['report_id'] as num?)?.toInt(),
  distanceKm: (json['distance_km'] as num).toDouble(),
  durationMin: (json['duration_min'] as num).toDouble(),
  geometry:
      (json['geometry'] as List<dynamic>?)
          ?.map(
            (e) =>
                (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
          )
          .toList() ??
      const [],
  target: json['target'] as String? ?? 'pickup',
  stale: json['stale'] as bool? ?? false,
  computedAt: json['computed_at'] == null
      ? null
      : DateTime.parse(json['computed_at'] as String),
);

Map<String, dynamic> _$RouteResultToJson(_RouteResult instance) =>
    <String, dynamic>{
      'report_id': instance.reportId,
      'distance_km': instance.distanceKm,
      'duration_min': instance.durationMin,
      'geometry': instance.geometry,
      'target': instance.target,
      'stale': instance.stale,
      'computed_at': instance.computedAt?.toIso8601String(),
    };

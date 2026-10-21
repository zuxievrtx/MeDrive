import 'package:freezed_annotation/freezed_annotation.dart';

part 'common.freezed.dart';
part 'common.g.dart';

/// Nilai enum dari backend: `{value, label, tone?}` (status, role, kategori, dsb.).
@freezed
abstract class LabeledValue with _$LabeledValue {
  const factory LabeledValue({
    required String value,
    required String label,
    String? tone,
  }) = _LabeledValue;

  factory LabeledValue.fromJson(Map<String, dynamic> json) => _$LabeledValueFromJson(json);
}

/// Posisi ambulans terbaru (kanal `report.{id}` dan `GET .../driver-location`).
@freezed
abstract class DriverLocation with _$DriverLocation {
  const factory DriverLocation({
    required double lat,
    required double lng,
    int? heading,
    double? speedKmh,
    DateTime? updatedAt,
  }) = _DriverLocation;

  factory DriverLocation.fromJson(Map<String, dynamic> json) => _$DriverLocationFromJson(json);
}

@freezed
abstract class Clinic with _$Clinic {
  const factory Clinic({
    required int id,
    required String name,
    String? code,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
    LabeledValue? type,
  }) = _Clinic;

  factory Clinic.fromJson(Map<String, dynamic> json) => _$ClinicFromJson(json);
}

/// Hasil `/geocode/search`.
@freezed
abstract class GeocodeResult with _$GeocodeResult {
  const factory GeocodeResult({
    required String label,
    required double latitude,
    required double longitude,
  }) = _GeocodeResult;

  factory GeocodeResult.fromJson(Map<String, dynamic> json) => _$GeocodeResultFromJson(json);
}

/// Hasil `/geocode/reverse`. [address] null bila titik tidak punya alamat (mis. di laut).
@freezed
abstract class ReverseGeocode with _$ReverseGeocode {
  const factory ReverseGeocode({
    String? address,
    required double latitude,
    required double longitude,
  }) = _ReverseGeocode;

  factory ReverseGeocode.fromJson(Map<String, dynamic> json) => _$ReverseGeocodeFromJson(json);
}

/// Rute ambulans → tujuan dari `/reporter/reports/{id}/route`. [geometry] berisi `[lat, lng]`.
@freezed
abstract class RouteResult with _$RouteResult {
  const RouteResult._();

  const factory RouteResult({
    int? reportId,
    required double distanceKm,
    required double durationMin,
    @Default([]) List<List<double>> geometry,
    @Default('pickup') String target,
    @Default(false) bool stale,
    DateTime? computedAt,
  }) = _RouteResult;

  factory RouteResult.fromJson(Map<String, dynamic> json) => _$RouteResultFromJson(json);

  bool get toDestination => target == 'destination';
}

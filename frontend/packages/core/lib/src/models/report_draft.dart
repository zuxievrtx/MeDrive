import 'package:dio/dio.dart';

/// Isi form laporan sebelum dikirim ke `POST /reporter/reports` (multipart).
///
/// [details] memakai nama kolom tabel detail v3 (mis. `accident_type`, `gestational_age_weeks`).
class ReportDraft {
  ReportDraft({
    required this.reportTypeCode,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.address,
    this.details = const {},
    this.destinationClinicId,
    this.destinationName,
    this.destinationAddress,
    this.destinationLatitude,
    this.destinationLongitude,
    this.photoPaths = const [],
    this.deathCertificatePath,
  });

  final String reportTypeCode;
  final double latitude;
  final double longitude;
  final String? address;
  final String description;
  final Map<String, Object?> details;
  final int? destinationClinicId;
  final String? destinationName;
  final String? destinationAddress;
  final double? destinationLatitude;
  final double? destinationLongitude;

  /// Path berkas foto yang sudah dikompres (≤ 300 KB).
  final List<String> photoPaths;
  final String? deathCertificatePath;

  /// Field teks untuk form multipart. Boolean dikirim "1"/"0" agar lolos validasi `boolean` Laravel.
  Map<String, String> toFields() {
    final fields = <String, String>{
      'report_type_code': reportTypeCode,
      'latitude': latitude.toStringAsFixed(7),
      'longitude': longitude.toStringAsFixed(7),
      'description': description.trim(),
    };

    void put(String key, Object? value) {
      if (value == null || (value is String && value.trim().isEmpty)) {
        return;
      }
      fields[key] = switch (value) {
        final bool flag => flag ? '1' : '0',
        final DateTime time => time.toIso8601String(),
        final double number => number.toStringAsFixed(7),
        _ => value.toString().trim(),
      };
    }

    put('address', address);
    put('destination_clinic_id', destinationClinicId);
    put('destination_name', destinationName);
    put('destination_address', destinationAddress);
    put('destination_lat', destinationLatitude);
    put('destination_lng', destinationLongitude);
    details.forEach((key, value) => put('details[$key]', value));

    return fields;
  }

  Future<FormData> toFormData() async {
    final form = FormData();
    form.fields.addAll(toFields().entries);

    for (final path in photoPaths) {
      form.files.add(MapEntry('photos[]', await MultipartFile.fromFile(path, filename: _name(path))));
    }
    if (deathCertificatePath != null) {
      form.files.add(MapEntry(
        'death_certificate',
        await MultipartFile.fromFile(deathCertificatePath!, filename: _name(deathCertificatePath!)),
      ));
    }

    return form;
  }

  static String _name(String path) => path.split(RegExp(r'[\\/]')).last;
}

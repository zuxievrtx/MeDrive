import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import 'destination_picker.dart';

/// Pilihan nilai sesuai aturan validasi `StoreReportRequest` backend.
abstract final class ReportOptions {
  static const accidentTypes = [
    ChoiceOption('tabrakan', 'Tabrakan'),
    ChoiceOption('tunggal', 'Kecelakaan tunggal'),
    ChoiceOption('tertabrak', 'Tertabrak'),
    ChoiceOption('lainnya', 'Lainnya'),
  ];

  static const medicalCategories = [
    ChoiceOption('jantung', 'Nyeri dada / jantung'),
    ChoiceOption('stroke', 'Stroke'),
    ChoiceOption('sesak_napas', 'Sesak napas'),
    ChoiceOption('tidak_sadar', 'Pingsan / tidak sadar'),
    ChoiceOption('kejang', 'Kejang'),
    ChoiceOption('cedera', 'Luka / cedera'),
    ChoiceOption('keracunan', 'Keracunan'),
    ChoiceOption('lainnya', 'Lainnya'),
  ];

  /// Waktu gejala mulai dalam menit yang lalu; null = tidak tahu.
  static const symptomOnset = [
    ChoiceOption<int?>(0, 'Baru saja'),
    ChoiceOption<int?>(30, '± 30 menit lalu'),
    ChoiceOption<int?>(60, '± 1 jam lalu'),
    ChoiceOption<int?>(180, 'Lebih dari 2 jam'),
    ChoiceOption<int?>(-1, 'Tidak tahu'),
  ];

  static const pickupPlaces = [
    ChoiceOption('rumah_sakit', 'Rumah sakit'),
    ChoiceOption('rumah_duka', 'Rumah duka'),
    ChoiceOption('lainnya', 'Lainnya'),
  ];
}

/// Nilai form laporan (satu template untuk empat jenis).
class ReportFormData {
  String? accidentType;
  String victimCount = '';
  bool trappedVictim = false;
  bool fireHazard = false;
  bool roadBlocked = false;

  String? medicalCategory;
  int? symptomOnsetMinutes;
  bool hasMedicalHistory = false;
  String medicalHistoryNotes = '';

  String gestationalWeeks = '';
  String contractionMinutes = '';
  bool waterBroken = false;
  bool bleeding = false;
  String pregnancyNumber = '';

  String deceasedName = '';
  String? pickupPlace;
  DateTime? scheduledPickup;
  bool hasDeathCertificate = false;
  String? deathCertificatePath;
  String familyName = '';
  String familyPhone = '';

  DestinationChoice? destination;
  String description = '';
  final photos = <String>[];

  /// Validasi sisi klien. Kunci memakai nama field server agar error server bisa digabung.
  Map<String, String> validate(ReportType type) {
    final errors = <String, String>{};

    String? range(String raw, int min, int max, String label) {
      if (raw.trim().isEmpty) {
        return null;
      }
      final value = int.tryParse(raw.trim());
      return value == null || value < min || value > max ? '$label harus $min-$max.' : null;
    }

    void put(String key, String? message) {
      if (message != null) {
        errors[key] = message;
      }
    }

    switch (type.kind) {
      case ReportKind.accident:
        put('details.accident_type', accidentType == null ? 'Pilih jenis kecelakaan.' : null);
        put('details.estimated_victim_count', range(victimCount, 1, 255, 'Jumlah korban'));
      case ReportKind.medical:
        put('details.medical_category', medicalCategory == null ? 'Pilih kondisi pasien.' : null);
      case ReportKind.maternity:
        put('details.gestational_age_weeks', range(gestationalWeeks, 1, 45, 'Usia kehamilan'));
        put('details.contraction_interval_minutes', range(contractionMinutes, 0, 255, 'Jarak kontraksi'));
        put('details.pregnancy_number', range(pregnancyNumber, 1, 30, 'Kehamilan ke-'));
      case ReportKind.funeral:
        put('details.deceased_name', deceasedName.trim().isEmpty ? 'Nama almarhum/almarhumah wajib diisi.' : null);
        put('details.pickup_place_type', pickupPlace == null ? 'Pilih tempat penjemputan.' : null);
        put('details.family_contact_name', familyName.trim().isEmpty ? 'Nama kontak keluarga wajib diisi.' : null);
        put(
          'details.family_contact_phone',
          RegExp(r'^[0-9+\-\s]{8,20}$').hasMatch(familyPhone.trim()) ? null : 'Telepon keluarga 8-20 digit.',
        );
      case ReportKind.unknown:
        break;
    }

    if (type.requiresDestination && destination == null) {
      errors['destination'] = 'Pilih tujuan antar.';
    }
    if (description.length > 500) {
      errors['description'] = 'Keterangan maksimal 500 karakter.';
    }

    return errors;
  }

  Map<String, Object?> details(ReportType type) => switch (type.kind) {
        ReportKind.accident => {
            'accident_type': accidentType,
            'estimated_victim_count': int.tryParse(victimCount.trim()),
            'has_trapped_victim': trappedVictim,
            'has_fire_hazard': fireHazard,
            'is_road_blocked': roadBlocked,
          },
        ReportKind.medical => {
            'medical_category': medicalCategory,
            'symptom_onset_at': symptomOnsetMinutes == null || symptomOnsetMinutes! < 0
                ? null
                : DateTime.now().subtract(Duration(minutes: symptomOnsetMinutes!)),
            'has_medical_history': hasMedicalHistory,
            'medical_history_notes': hasMedicalHistory ? medicalHistoryNotes : null,
          },
        ReportKind.maternity => {
            'gestational_age_weeks': int.tryParse(gestationalWeeks.trim()),
            'contraction_interval_minutes': int.tryParse(contractionMinutes.trim()),
            'is_water_broken': waterBroken,
            'has_bleeding': bleeding,
            'pregnancy_number': int.tryParse(pregnancyNumber.trim()),
          },
        ReportKind.funeral => {
            'deceased_name': deceasedName,
            'pickup_place_type': pickupPlace,
            'scheduled_pickup_at': scheduledPickup,
            'has_death_certificate': hasDeathCertificate,
            'family_contact_name': familyName,
            'family_contact_phone': familyPhone,
          },
        ReportKind.unknown => const {},
      };

  /// Backend mewajibkan deskripsi, sedangkan Figma menjadikannya opsional. Bila pelapor tidak
  /// menulis apa pun, deskripsi disusun dari pilihan di form agar laporan tetap terkirim cepat.
  String effectiveDescription(ReportType type) {
    if (description.trim().isNotEmpty) {
      return description.trim();
    }

    String label<T>(List<ChoiceOption<T>> options, T? value) =>
        options.where((option) => option.value == value).map((option) => option.label).firstOrNull ?? '';

    final parts = <String>[type.name];
    switch (type.kind) {
      case ReportKind.accident:
        parts.add(label(ReportOptions.accidentTypes, accidentType));
        if (victimCount.trim().isNotEmpty) {
          parts.add('perkiraan ${victimCount.trim()} korban');
        }
        if (trappedVictim) parts.add('ada korban terjepit');
        if (fireHazard) parts.add('potensi api');
        if (roadBlocked) parts.add('jalan tertutup');
      case ReportKind.medical:
        parts.add(label(ReportOptions.medicalCategories, medicalCategory));
      case ReportKind.maternity:
        if (gestationalWeeks.trim().isNotEmpty) parts.add('usia kehamilan ${gestationalWeeks.trim()} minggu');
        if (waterBroken) parts.add('ketuban pecah');
        if (bleeding) parts.add('ada perdarahan');
      case ReportKind.funeral:
        parts.add('a.n. ${deceasedName.trim()}');
      case ReportKind.unknown:
        break;
    }
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  ReportDraft toDraft({
    required ReportType type,
    required double latitude,
    required double longitude,
    required String? address,
  }) {
    final place = destination;
    return ReportDraft(
      reportTypeCode: type.code,
      latitude: latitude,
      longitude: longitude,
      address: address,
      description: effectiveDescription(type),
      details: details(type),
      destinationClinicId: place?.clinic?.id,
      destinationName: place?.clinic == null ? place?.name : null,
      destinationAddress: place?.clinic == null ? place?.address : null,
      destinationLatitude: place?.clinic == null ? place?.latitude : null,
      destinationLongitude: place?.clinic == null ? place?.longitude : null,
      photoPaths: List.of(photos),
      deathCertificatePath: type.kind == ReportKind.funeral && hasDeathCertificate ? deathCertificatePath : null,
    );
  }
}

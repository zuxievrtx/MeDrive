import 'package:flutter_test/flutter_test.dart';
import 'package:medrive_core/medrive_core.dart';

import 'fixtures.dart';

void main() {
  group('Report', () {
    test('parses the reporter detail resource including the medical details union', () {
      final report = Report.fromJson(reportDetailJson);

      expect(report.code, 'MDR-261009-0001');
      expect(report.isActive, isTrue);
      expect(report.longitude, 110.0);
      expect(report.reportType!.kind, ReportKind.medical);
      expect(report.driver!.isVerified, isTrue);
      expect(report.ambulance!.plateNumber, 'H 1234 AB');
      expect(report.patients.single.ageEstimate, 55);
      expect(report.attachments.single.url, endsWith('/media/attachment/5'));
      expect(report.timeline.single.fromStatus, isNull);

      final details = report.details;
      expect(details, isA<MedicalDetails>());
      expect((details! as MedicalDetails).medicalHistoryNotes, 'Riwayat hipertensi');
    });

    test('falls back to the unknown detail variant for an unrecognised kind', () {
      final report = Report.fromJson({
        ...reportDetailJson,
        'details': {'kind': 'baru'},
      });
      expect(report.details, isA<UnknownDetails>());
    });

    test('parses list items without the detail-only fields', () {
      final report = Report.fromJson({
        'id': 7,
        'code': 'MDR-261021-0007',
        'status': {'value': 'menunggu', 'label': 'Menunggu', 'tone': 'amber'},
        'latitude': -6.99,
        'longitude': 110.42,
        'driver': null,
        'ambulance': null,
      });
      expect(report.isWaiting, isTrue);
      expect(report.patients, isEmpty);
      expect(report.details, isNull);
    });
  });

  test('AuthSession parses login responses', () {
    final session = AuthSession.fromJson({'token': '1|abc', 'token_type': 'Bearer', 'must_change_password': true, 'user': userJson});
    expect(session.mustChangePassword, isTrue);
    expect(session.user.isReporter, isTrue);
    expect(session.user.displayInitials, 'BS');
  });

  test('RouteResult keeps [lat, lng] geometry and the stale flag', () {
    final route = RouteResult.fromJson({
      'report_id': 3,
      'distance_km': 3.46,
      'duration_min': 7,
      'geometry': [
        [-6.9932, 110.4203],
        [-6.995, 110.422],
      ],
      'target': 'destination',
      'stale': true,
      'computed_at': '2026-10-21T10:15:02+07:00',
    });
    expect(route.durationMin, 7.0);
    expect(route.geometry.first, [-6.9932, 110.4203]);
    expect(route.toDestination, isTrue);
    expect(route.stale, isTrue);
  });

  test('UnreadSummary sums counts per report', () {
    final summary = UnreadSummary.fromJson({
      'total': 3,
      'reports': [
        {'report_id': 3, 'code': 'MDR-1', 'count': 2},
        {'report_id': 1, 'code': 'MDR-2', 'count': 1},
      ],
    });
    expect(summary.forReport(3), 2);
    expect(summary.forReport(99), 0);
  });

  test('ReportStatus groups active and closed statuses like the backend', () {
    expect(ReportStatus.isActive(ReportStatus.mengantarPasien), isTrue);
    expect(ReportStatus.isActive(ReportStatus.menunggu), isFalse);
    expect(ReportStatus.isClosed(ReportStatus.dibatalkan), isTrue);
    expect(ReportStatus.label('tiba_di_lokasi'), 'Tiba di Lokasi');
  });

  test('ReportDraft encodes details as Laravel form fields with booleans as 1/0', () {
    final fields = ReportDraft(
      reportTypeCode: 'kecelakaan',
      latitude: -6.99,
      longitude: 110.42,
      description: '  Tabrakan motor  ',
      address: 'Jl. Pandanaran',
      details: {'accident_type': 'tabrakan', 'estimated_victim_count': 2, 'has_fire_hazard': false, 'is_road_blocked': true, 'notes': null},
    ).toFields();

    expect(fields['report_type_code'], 'kecelakaan');
    expect(fields['description'], 'Tabrakan motor');
    expect(fields['details[accident_type]'], 'tabrakan');
    expect(fields['details[estimated_victim_count]'], '2');
    expect(fields['details[has_fire_hazard]'], '0');
    expect(fields['details[is_road_blocked]'], '1');
    expect(fields.containsKey('details[notes]'), isFalse);
    expect(fields.containsKey('destination_clinic_id'), isFalse);
  });
}

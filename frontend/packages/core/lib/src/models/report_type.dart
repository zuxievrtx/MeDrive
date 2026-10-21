import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_type.freezed.dart';
part 'report_type.g.dart';

/// Jenis laporan (`report_types`). Warna & ikon berasal dari database.
@freezed
abstract class ReportType with _$ReportType {
  const ReportType._();

  const factory ReportType({
    int? id,
    required String code,
    required String name,
    String? description,
    @Default(1) int priority,
    @Default(true) bool isEmergency,
    @Default(false) bool requiresDestination,
    String? icon,
    String? color,
    String? textColor,
    @Default(0) int sortOrder,
  }) = _ReportType;

  factory ReportType.fromJson(Map<String, dynamic> json) => _$ReportTypeFromJson(json);

  ReportKind get kind => ReportKind.fromCode(code);
}

/// Empat kelompok detail laporan di backend (`detailKind()` / tabel detail v3).
enum ReportKind {
  accident('kecelakaan'),
  medical('medis_darurat'),
  maternity('ibu_hamil'),
  funeral('pengantaran_jenazah'),
  unknown('');

  const ReportKind(this.code);

  final String code;

  static ReportKind fromCode(String code) =>
      values.firstWhere((kind) => kind.code == code, orElse: () => ReportKind.unknown);
}

/// Jenis laporan bawaan, sama dengan `MasterDataSeeder` backend. Dipakai karena API pelapor
/// belum punya endpoint daftar jenis laporan (lihat ASSUMPTIONS.md); bila endpoint itu ada,
/// [ReportTypeRepository] memakai data server.
const defaultReportTypes = <ReportType>[
  ReportType(
    id: 1,
    code: 'kecelakaan',
    name: 'Kecelakaan',
    description: 'Kecelakaan lalu lintas atau kecelakaan lain dengan korban',
    priority: 1,
    icon: 'car-crash',
    color: '#B5523B',
    sortOrder: 1,
  ),
  ReportType(
    id: 2,
    code: 'medis_darurat',
    name: 'Medis Darurat',
    description: 'Kondisi medis mendadak: jantung, stroke, sesak, kejang',
    priority: 1,
    icon: 'heart-pulse',
    color: '#C2410C',
    sortOrder: 2,
  ),
  ReportType(
    id: 3,
    code: 'ibu_hamil',
    name: 'Ibu Hamil',
    description: 'Ibu hamil yang akan melahirkan atau mengalami komplikasi',
    priority: 2,
    requiresDestination: true,
    icon: 'baby',
    color: '#2F6F6A',
    sortOrder: 3,
  ),
  ReportType(
    id: 4,
    code: 'pengantaran_jenazah',
    name: 'Pengantaran Jenazah',
    description: 'Pengantaran jenazah, dapat dijadwalkan',
    priority: 4,
    isEmergency: false,
    requiresDestination: true,
    icon: 'bed',
    color: '#4E6A85',
    sortOrder: 4,
  ),
];

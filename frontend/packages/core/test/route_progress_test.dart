import 'package:flutter_test/flutter_test.dart';
import 'package:medrive_core/medrive_core.dart';

void main() {
  // Rute lurus ke utara dari titik awal snapshot server: tiap langkah ±111 m (0,001 derajat).
  const lng = 110.4203;
  final route = <List<double>>[
    for (var step = 0; step <= 4; step++) [-6.9932 + step * 0.001, lng],
  ];

  test('garis dimulai dari posisi GPS terkini, bukan titik awal snapshot server', () {
    final position = [-6.9912, lng]; // sudah maju dua langkah

    final trimmed = trimRouteToPosition(route, position[0], position[1]);

    expect(trimmed.first, position);
    expect(trimmed.first, isNot(route.first));
  });

  test('bagian rute yang sudah dilewati dibuang dan sisanya tetap utuh', () {
    final trimmed = trimRouteToPosition(route, -6.99105, lng); // di antara titik 2 dan 3

    expect(trimmed.first, [-6.99105, lng]);
    expect(trimmed.skip(2), [route[3], route[4]]);
    expect(trimmed.length, 4);
  });

  test('posisi tepat di titik rute tidak menggandakan titik itu', () {
    final trimmed = trimRouteToPosition(route, route[2][0], route[2][1]);

    expect(trimmed.skip(1).where((point) => point[0] == route[2][0]), hasLength(1));
    expect(trimmed.last, route.last);
  });

  test('di ujung rute hasilnya posisi dan titik akhir saja', () {
    final trimmed = trimRouteToPosition(route, route.last[0], route.last[1]);

    expect(trimmed, hasLength(2));
    expect(trimmed.last, route.last);
  });

  test('driver menyimpang dari rute: garis terhubung ke titik terdekat di rute', () {
    final trimmed = trimRouteToPosition(route, -6.9902, lng + 0.002); // ±220 m di timur titik 3

    expect(trimmed.first, [-6.9902, lng + 0.002]);
    expect(trimmed[1][1], closeTo(lng, 1e-9), reason: 'titik terdekat berada di jalur rute');
    expect(trimmed[1][0], closeTo(-6.9902, 1e-6));
    expect(trimmed.last, route.last);
  });

  test('rute kosong atau satu titik tidak menimbulkan error', () {
    expect(trimRouteToPosition(const [], -6.99, lng), isEmpty);
    expect(trimRouteToPosition([route.first], -6.99, lng), [
      [-6.99, lng],
      route.first,
    ]);
  });

  test('ruas dengan dua titik identik tidak menyebabkan pembagian nol', () {
    final degenerate = <List<double>>[route[0], route[0], route[1]];

    final trimmed = trimRouteToPosition(degenerate, -6.9931, lng);

    expect(trimmed.every((point) => point.every((value) => value.isFinite)), isTrue);
    expect(trimmed.last, route[1]);
  });
}

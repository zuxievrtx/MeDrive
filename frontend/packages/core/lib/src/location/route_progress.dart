import 'dart:math' as math;

/// Potong [geometry] rute (`[[lat, lng], ...]` dari `GET /driver/route`) sesuai posisi terkini
/// ([lat], [lng]): bagian yang sudah dilewati dibuang dan garis dimulai dari posisi itu.
///
/// Rute dari server adalah snapshot (titik awalnya posisi driver saat OSRM dihitung, dan hanya
/// diganti sekitar tiap 30 detik). Tanpa pemotongan, garis tertinggal di belakang marker GPS.
///
/// Hasil: `[posisi, titik terdekat di rute, titik rute berikutnya, ...]`. Bila driver sudah di
/// ujung rute, hasilnya `[posisi, titik akhir]`. Bila driver jauh dari rute, garis
/// menghubungkan posisi ke titik terdekat di rute (rute baru datang dari server pada refresh
/// berikutnya). [geometry] kosong menghasilkan daftar kosong.
List<List<double>> trimRouteToPosition(List<List<double>> geometry, double lat, double lng) {
  if (geometry.isEmpty) {
    return const [];
  }
  final position = [lat, lng];
  if (geometry.length == 1) {
    return [position, geometry.first];
  }

  // Bidang datar lokal dalam meter berpusat di posisi driver. Cukup akurat untuk jarak
  // beberapa kilometer dan jauh lebih murah daripada haversine untuk setiap ruas.
  const metersPerDegree = 111320.0;
  final lngScale = math.cos(lat * math.pi / 180) * metersPerDegree;
  double x(List<double> point) => (point[1] - lng) * lngScale;
  double y(List<double> point) => (point[0] - lat) * metersPerDegree;

  var bestSegment = 0;
  var bestT = 0.0;
  var bestDistance = double.infinity;

  for (var index = 0; index < geometry.length - 1; index++) {
    final ax = x(geometry[index]);
    final ay = y(geometry[index]);
    final dx = x(geometry[index + 1]) - ax;
    final dy = y(geometry[index + 1]) - ay;
    final lengthSquared = dx * dx + dy * dy;
    final t = lengthSquared == 0 ? 0.0 : (-(ax * dx + ay * dy) / lengthSquared).clamp(0.0, 1.0);
    final px = ax + t * dx;
    final py = ay + t * dy;
    final distance = px * px + py * py;
    if (distance < bestDistance) {
      bestDistance = distance;
      bestSegment = index;
      bestT = t;
    }
  }

  final from = geometry[bestSegment];
  final to = geometry[bestSegment + 1];
  final nearest = [from[0] + bestT * (to[0] - from[0]), from[1] + bestT * (to[1] - from[1])];
  // t == 1 berarti titik terdekat adalah ujung ruas; jangan mengulang titik yang sama.
  final firstKept = bestT >= 1 ? bestSegment + 2 : bestSegment + 1;

  return [position, nearest, ...geometry.skip(firstKept)];
}

import '../api/api_client.dart';
import '../models/common.dart';

/// Proxy geocoding backend. Aplikasi tidak pernah memanggil Nominatim langsung.
class GeocodeRepository {
  GeocodeRepository(this._api);

  final ApiClient _api;

  Future<ReverseGeocode> reverse(double latitude, double longitude) async {
    final response = await _api.get('/geocode/reverse', query: {'lat': latitude, 'lng': longitude});
    return ReverseGeocode.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<GeocodeResult>> search(String query, {int limit = 5}) async {
    final response = await _api.get('/geocode/search', query: {'q': query.trim(), 'limit': limit});
    final data = response.data;
    return data is List ? data.whereType<Map<String, dynamic>>().map(GeocodeResult.fromJson).toList() : const [];
  }
}

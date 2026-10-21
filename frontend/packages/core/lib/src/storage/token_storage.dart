import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Penyimpanan token Sanctum. Nilai disimpan juga di memori agar header Authorization
/// (termasuk untuk gambar privat) bisa dibaca tanpa menunggu secure storage.
abstract class TokenStorage {
  String? get cachedToken;

  Future<String?> read();

  Future<void> write(String token);

  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'medrive.auth_token';

  final FlutterSecureStorage _storage;
  String? _cache;
  bool _loaded = false;

  @override
  String? get cachedToken => _cache;

  @override
  Future<String?> read() async {
    if (!_loaded) {
      _cache = await _storage.read(key: _key);
      _loaded = true;
    }
    return _cache;
  }

  @override
  Future<void> write(String token) async {
    _cache = token;
    _loaded = true;
    await _storage.write(key: _key, value: token);
  }

  @override
  Future<void> clear() async {
    _cache = null;
    _loaded = true;
    await _storage.delete(key: _key);
  }
}

/// Untuk test dan pratinjau widget.
class MemoryTokenStorage implements TokenStorage {
  MemoryTokenStorage([this._token]);

  String? _token;

  @override
  String? get cachedToken => _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}

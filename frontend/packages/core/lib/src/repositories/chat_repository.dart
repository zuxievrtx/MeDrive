import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import '../config/app_role.dart';
import '../models/chat.dart';

/// Chat pelapor ↔ driver per laporan (`/{reporter|driver}/reports/{id}/chat*`). Endpoint kedua
/// aplikasi identik; hanya prefix grupnya yang berbeda.
class ChatRepository {
  ChatRepository(this._api, {AppRole role = AppRole.reporter}) : _prefix = '/${role.pathPrefix}';

  final ApiClient _api;
  final String _prefix;

  Future<ChatPage> history(int reportId, {int? beforeId}) async {
    final response = await _api.get('$_prefix/reports/$reportId/chat', query: {'before_id': beforeId});
    final cursor = response.meta['cursor'];
    final cursorMap = cursor is Map ? cursor : const {};

    return ChatPage(
      messages: _list(response.data).map(ChatMessage.fromJson).toList(),
      hasMore: cursorMap['has_more'] == true,
      nextBeforeId: (cursorMap['next_before_id'] as num?)?.toInt(),
      isOpen: response.meta['is_open'] != false,
    );
  }

  Future<ChatMessage> sendText(int reportId, String body) async {
    final response = await _api.post('$_prefix/reports/$reportId/chat', data: {'type': 'text', 'body': body.trim()});
    return ChatMessage.fromJson(_map(response.data));
  }

  /// [imagePath] harus sudah dikompres di aplikasi (server menolak di atas 1 MB).
  Future<ChatMessage> sendImage(int reportId, String imagePath) async {
    final form = FormData()
      ..fields.add(const MapEntry('type', 'image'))
      ..files.add(MapEntry('image', await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last)));
    final response = await _api.post('$_prefix/reports/$reportId/chat', data: form);
    return ChatMessage.fromJson(_map(response.data));
  }

  Future<int> markRead(int reportId) async {
    final response = await _api.post('$_prefix/reports/$reportId/chat/read');
    return ((_map(response.data)['marked'] as num?) ?? 0).toInt();
  }

  Future<UnreadSummary> unreadCount() async {
    final response = await _api.get('$_prefix/chat/unread-count');
    return UnreadSummary.fromJson(_map(response.data));
  }

  static Map<String, dynamic> _map(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ApiError(code: 'invalid_response', message: 'Respons server tidak dikenali. Coba lagi.');
  }

  static List<Map<String, dynamic>> _list(Object? data) =>
      data is List ? data.whereType<Map<String, dynamic>>().toList() : const [];
}

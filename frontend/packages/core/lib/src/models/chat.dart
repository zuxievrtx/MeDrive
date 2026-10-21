import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

/// Pesan chat pelapor ↔ driver. [isMine] hanya ada di respons API; untuk event realtime
/// bandingkan [senderId] dengan id user.
@freezed
abstract class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required int id,
    required int reportId,
    required int senderId,
    String? senderName,
    @Default('text') String type,
    String? body,
    String? imageUrl,
    String? mimeType,
    int? sizeKb,
    DateTime? readAt,
    DateTime? createdAt,
    bool? isMine,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

  bool get isImage => type == 'image';
}

/// Satu halaman riwayat chat (urut lama → baru) dengan kursor untuk memuat pesan lebih lama.
class ChatPage {
  const ChatPage({
    required this.messages,
    required this.hasMore,
    required this.nextBeforeId,
    required this.isOpen,
  });

  final List<ChatMessage> messages;
  final bool hasMore;
  final int? nextBeforeId;
  final bool isOpen;
}

@freezed
abstract class UnreadReport with _$UnreadReport {
  const factory UnreadReport({required int reportId, required String code, required int count}) = _UnreadReport;

  factory UnreadReport.fromJson(Map<String, dynamic> json) => _$UnreadReportFromJson(json);
}

@freezed
abstract class UnreadSummary with _$UnreadSummary {
  const UnreadSummary._();

  const factory UnreadSummary({
    @Default(0) int total,
    @Default([]) List<UnreadReport> reports,
  }) = _UnreadSummary;

  factory UnreadSummary.fromJson(Map<String, dynamic> json) => _$UnreadSummaryFromJson(json);

  int forReport(int reportId) =>
      reports.where((report) => report.reportId == reportId).fold(0, (sum, report) => sum + report.count);
}

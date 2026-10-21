// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: (json['id'] as num).toInt(),
  reportId: (json['report_id'] as num).toInt(),
  senderId: (json['sender_id'] as num).toInt(),
  senderName: json['sender_name'] as String?,
  type: json['type'] as String? ?? 'text',
  body: json['body'] as String?,
  imageUrl: json['image_url'] as String?,
  mimeType: json['mime_type'] as String?,
  sizeKb: (json['size_kb'] as num?)?.toInt(),
  readAt: json['read_at'] == null
      ? null
      : DateTime.parse(json['read_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  isMine: json['is_mine'] as bool?,
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'report_id': instance.reportId,
      'sender_id': instance.senderId,
      'sender_name': instance.senderName,
      'type': instance.type,
      'body': instance.body,
      'image_url': instance.imageUrl,
      'mime_type': instance.mimeType,
      'size_kb': instance.sizeKb,
      'read_at': instance.readAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'is_mine': instance.isMine,
    };

_UnreadReport _$UnreadReportFromJson(Map<String, dynamic> json) =>
    _UnreadReport(
      reportId: (json['report_id'] as num).toInt(),
      code: json['code'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$UnreadReportToJson(_UnreadReport instance) =>
    <String, dynamic>{
      'report_id': instance.reportId,
      'code': instance.code,
      'count': instance.count,
    };

_UnreadSummary _$UnreadSummaryFromJson(Map<String, dynamic> json) =>
    _UnreadSummary(
      total: (json['total'] as num?)?.toInt() ?? 0,
      reports:
          (json['reports'] as List<dynamic>?)
              ?.map((e) => UnreadReport.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UnreadSummaryToJson(_UnreadSummary instance) =>
    <String, dynamic>{
      'total': instance.total,
      'reports': instance.reports.map((e) => e.toJson()).toList(),
    };

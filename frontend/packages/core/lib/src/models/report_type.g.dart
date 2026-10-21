// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportType _$ReportTypeFromJson(Map<String, dynamic> json) => _ReportType(
  id: (json['id'] as num?)?.toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  priority: (json['priority'] as num?)?.toInt() ?? 1,
  isEmergency: json['is_emergency'] as bool? ?? true,
  requiresDestination: json['requires_destination'] as bool? ?? false,
  icon: json['icon'] as String?,
  color: json['color'] as String?,
  textColor: json['text_color'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ReportTypeToJson(_ReportType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'priority': instance.priority,
      'is_emergency': instance.isEmergency,
      'requires_destination': instance.requiresDestination,
      'icon': instance.icon,
      'color': instance.color,
      'text_color': instance.textColor,
      'sort_order': instance.sortOrder,
    };

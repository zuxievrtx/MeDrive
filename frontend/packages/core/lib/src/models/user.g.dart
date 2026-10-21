// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  initials: json['initials'] as String?,
  phone: json['phone'] as String,
  email: json['email'] as String,
  role: LabeledValue.fromJson(json['role'] as Map<String, dynamic>),
  accountStatus: json['account_status'] == null
      ? null
      : LabeledValue.fromJson(json['account_status'] as Map<String, dynamic>),
  mustChangePassword: json['must_change_password'] as bool? ?? false,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'initials': instance.initials,
  'phone': instance.phone,
  'email': instance.email,
  'role': instance.role.toJson(),
  'account_status': instance.accountStatus?.toJson(),
  'must_change_password': instance.mustChangePassword,
  'created_at': instance.createdAt?.toIso8601String(),
};

_AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => _AuthSession(
  token: json['token'] as String,
  mustChangePassword: json['must_change_password'] as bool? ?? false,
  user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthSessionToJson(_AuthSession instance) =>
    <String, dynamic>{
      'token': instance.token,
      'must_change_password': instance.mustChangePassword,
      'user': instance.user.toJson(),
    };

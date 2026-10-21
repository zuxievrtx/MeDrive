// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessage {

 int get id; int get reportId; int get senderId; String? get senderName; String get type; String? get body; String? get imageUrl; String? get mimeType; int? get sizeKb; DateTime? get readAt; DateTime? get createdAt; bool? get isMine;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChatMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.reportId, _this.reportId) || other.reportId == _this.reportId)&&(identical(other.senderId, _this.senderId) || other.senderId == _this.senderId)&&(identical(other.senderName, _this.senderName) || other.senderName == _this.senderName)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.mimeType, _this.mimeType) || other.mimeType == _this.mimeType)&&(identical(other.sizeKb, _this.sizeKb) || other.sizeKb == _this.sizeKb)&&(identical(other.readAt, _this.readAt) || other.readAt == _this.readAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.isMine, _this.isMine) || other.isMine == _this.isMine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChatMessage;
  return Object.hash(runtimeType,_this.id,_this.reportId,_this.senderId,_this.senderName,_this.type,_this.body,_this.imageUrl,_this.mimeType,_this.sizeKb,_this.readAt,_this.createdAt,_this.isMine);
}

@override
String toString() {
  final _this = this as ChatMessage;
  return 'ChatMessage(id: ${_this.id}, reportId: ${_this.reportId}, senderId: ${_this.senderId}, senderName: ${_this.senderName}, type: ${_this.type}, body: ${_this.body}, imageUrl: ${_this.imageUrl}, mimeType: ${_this.mimeType}, sizeKb: ${_this.sizeKb}, readAt: ${_this.readAt}, createdAt: ${_this.createdAt}, isMine: ${_this.isMine})';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 int id, int reportId, int senderId, String? senderName, String type, String? body, String? imageUrl, String? mimeType, int? sizeKb, DateTime? readAt, DateTime? createdAt, bool? isMine
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reportId = null,Object? senderId = null,Object? senderName = freezed,Object? type = null,Object? body = freezed,Object? imageUrl = freezed,Object? mimeType = freezed,Object? sizeKb = freezed,Object? readAt = freezed,Object? createdAt = freezed,Object? isMine = freezed,}) {
  return _then(ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as int,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as int,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeKb: freezed == sizeKb ? _self.sizeKb : sizeKb // ignore: cast_nullable_to_non_nullable
as int?,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isMine: freezed == isMine ? _self.isMine : isMine // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int reportId,  int senderId,  String? senderName,  String type,  String? body,  String? imageUrl,  String? mimeType,  int? sizeKb,  DateTime? readAt,  DateTime? createdAt,  bool? isMine)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.reportId,_that.senderId,_that.senderName,_that.type,_that.body,_that.imageUrl,_that.mimeType,_that.sizeKb,_that.readAt,_that.createdAt,_that.isMine);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int reportId,  int senderId,  String? senderName,  String type,  String? body,  String? imageUrl,  String? mimeType,  int? sizeKb,  DateTime? readAt,  DateTime? createdAt,  bool? isMine)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.id,_that.reportId,_that.senderId,_that.senderName,_that.type,_that.body,_that.imageUrl,_that.mimeType,_that.sizeKb,_that.readAt,_that.createdAt,_that.isMine);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int reportId,  int senderId,  String? senderName,  String type,  String? body,  String? imageUrl,  String? mimeType,  int? sizeKb,  DateTime? readAt,  DateTime? createdAt,  bool? isMine)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.reportId,_that.senderId,_that.senderName,_that.type,_that.body,_that.imageUrl,_that.mimeType,_that.sizeKb,_that.readAt,_that.createdAt,_that.isMine);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessage extends ChatMessage {
  const _ChatMessage({required this.id, required this.reportId, required this.senderId, this.senderName, this.type = 'text', this.body, this.imageUrl, this.mimeType, this.sizeKb, this.readAt, this.createdAt, this.isMine}): super._();
  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

@override final  int id;
@override final  int reportId;
@override final  int senderId;
@override final  String? senderName;
@override@JsonKey() final  String type;
@override final  String? body;
@override final  String? imageUrl;
@override final  String? mimeType;
@override final  int? sizeKb;
@override final  DateTime? readAt;
@override final  DateTime? createdAt;
@override final  bool? isMine;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.type, type) || other.type == type)&&(identical(other.body, body) || other.body == body)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeKb, sizeKb) || other.sizeKb == sizeKb)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isMine, isMine) || other.isMine == isMine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,reportId,senderId,senderName,type,body,imageUrl,mimeType,sizeKb,readAt,createdAt,isMine);
}

@override
String toString() {
    return 'ChatMessage(id: $id, reportId: $reportId, senderId: $senderId, senderName: $senderName, type: $type, body: $body, imageUrl: $imageUrl, mimeType: $mimeType, sizeKb: $sizeKb, readAt: $readAt, createdAt: $createdAt, isMine: $isMine)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 int id, int reportId, int senderId, String? senderName, String type, String? body, String? imageUrl, String? mimeType, int? sizeKb, DateTime? readAt, DateTime? createdAt, bool? isMine
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reportId = null,Object? senderId = null,Object? senderName = freezed,Object? type = null,Object? body = freezed,Object? imageUrl = freezed,Object? mimeType = freezed,Object? sizeKb = freezed,Object? readAt = freezed,Object? createdAt = freezed,Object? isMine = freezed,}) {
  return _then(_ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as int,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as int,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeKb: freezed == sizeKb ? _self.sizeKb : sizeKb // ignore: cast_nullable_to_non_nullable
as int?,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isMine: freezed == isMine ? _self.isMine : isMine // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$UnreadReport {

 int get reportId; String get code; int get count;
/// Create a copy of UnreadReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnreadReportCopyWith<UnreadReport> get copyWith => _$UnreadReportCopyWithImpl<UnreadReport>(this as UnreadReport, _$identity);

  /// Serializes this UnreadReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UnreadReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnreadReport&&(identical(other.reportId, _this.reportId) || other.reportId == _this.reportId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.count, _this.count) || other.count == _this.count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UnreadReport;
  return Object.hash(runtimeType,_this.reportId,_this.code,_this.count);
}

@override
String toString() {
  final _this = this as UnreadReport;
  return 'UnreadReport(reportId: ${_this.reportId}, code: ${_this.code}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $UnreadReportCopyWith<$Res>  {
  factory $UnreadReportCopyWith(UnreadReport value, $Res Function(UnreadReport) _then) = _$UnreadReportCopyWithImpl;
@useResult
$Res call({
 int reportId, String code, int count
});




}
/// @nodoc
class _$UnreadReportCopyWithImpl<$Res>
    implements $UnreadReportCopyWith<$Res> {
  _$UnreadReportCopyWithImpl(this._self, this._then);

  final UnreadReport _self;
  final $Res Function(UnreadReport) _then;

/// Create a copy of UnreadReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reportId = null,Object? code = null,Object? count = null,}) {
  return _then(UnreadReport(
reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UnreadReport].
extension UnreadReportPatterns on UnreadReport {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnreadReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnreadReport() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnreadReport value)  $default,){
final _that = this;
switch (_that) {
case _UnreadReport():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnreadReport value)?  $default,){
final _that = this;
switch (_that) {
case _UnreadReport() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int reportId,  String code,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnreadReport() when $default != null:
return $default(_that.reportId,_that.code,_that.count);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int reportId,  String code,  int count)  $default,) {final _that = this;
switch (_that) {
case _UnreadReport():
return $default(_that.reportId,_that.code,_that.count);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int reportId,  String code,  int count)?  $default,) {final _that = this;
switch (_that) {
case _UnreadReport() when $default != null:
return $default(_that.reportId,_that.code,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnreadReport implements UnreadReport {
  const _UnreadReport({required this.reportId, required this.code, required this.count});
  factory _UnreadReport.fromJson(Map<String, dynamic> json) => _$UnreadReportFromJson(json);

@override final  int reportId;
@override final  String code;
@override final  int count;

/// Create a copy of UnreadReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnreadReportCopyWith<_UnreadReport> get copyWith => __$UnreadReportCopyWithImpl<_UnreadReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnreadReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnreadReport&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.code, code) || other.code == code)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reportId,code,count);
}

@override
String toString() {
    return 'UnreadReport(reportId: $reportId, code: $code, count: $count)';
}


}

/// @nodoc
abstract mixin class _$UnreadReportCopyWith<$Res> implements $UnreadReportCopyWith<$Res> {
  factory _$UnreadReportCopyWith(_UnreadReport value, $Res Function(_UnreadReport) _then) = __$UnreadReportCopyWithImpl;
@override @useResult
$Res call({
 int reportId, String code, int count
});




}
/// @nodoc
class __$UnreadReportCopyWithImpl<$Res>
    implements _$UnreadReportCopyWith<$Res> {
  __$UnreadReportCopyWithImpl(this._self, this._then);

  final _UnreadReport _self;
  final $Res Function(_UnreadReport) _then;

/// Create a copy of UnreadReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reportId = null,Object? code = null,Object? count = null,}) {
  return _then(_UnreadReport(
reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$UnreadSummary {

 int get total; List<UnreadReport> get reports;
/// Create a copy of UnreadSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnreadSummaryCopyWith<UnreadSummary> get copyWith => _$UnreadSummaryCopyWithImpl<UnreadSummary>(this as UnreadSummary, _$identity);

  /// Serializes this UnreadSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UnreadSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnreadSummary&&(identical(other.total, _this.total) || other.total == _this.total)&&const DeepCollectionEquality().equals(other.reports, _this.reports));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UnreadSummary;
  return Object.hash(runtimeType,_this.total,const DeepCollectionEquality().hash(_this.reports));
}

@override
String toString() {
  final _this = this as UnreadSummary;
  return 'UnreadSummary(total: ${_this.total}, reports: ${_this.reports})';
}


}

/// @nodoc
abstract mixin class $UnreadSummaryCopyWith<$Res>  {
  factory $UnreadSummaryCopyWith(UnreadSummary value, $Res Function(UnreadSummary) _then) = _$UnreadSummaryCopyWithImpl;
@useResult
$Res call({
 int total, List<UnreadReport> reports
});




}
/// @nodoc
class _$UnreadSummaryCopyWithImpl<$Res>
    implements $UnreadSummaryCopyWith<$Res> {
  _$UnreadSummaryCopyWithImpl(this._self, this._then);

  final UnreadSummary _self;
  final $Res Function(UnreadSummary) _then;

/// Create a copy of UnreadSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? reports = null,}) {
  return _then(UnreadSummary(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,reports: null == reports ? _self.reports : reports // ignore: cast_nullable_to_non_nullable
as List<UnreadReport>,
  ));
}

}


/// Adds pattern-matching-related methods to [UnreadSummary].
extension UnreadSummaryPatterns on UnreadSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnreadSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnreadSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnreadSummary value)  $default,){
final _that = this;
switch (_that) {
case _UnreadSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnreadSummary value)?  $default,){
final _that = this;
switch (_that) {
case _UnreadSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  List<UnreadReport> reports)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnreadSummary() when $default != null:
return $default(_that.total,_that.reports);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  List<UnreadReport> reports)  $default,) {final _that = this;
switch (_that) {
case _UnreadSummary():
return $default(_that.total,_that.reports);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  List<UnreadReport> reports)?  $default,) {final _that = this;
switch (_that) {
case _UnreadSummary() when $default != null:
return $default(_that.total,_that.reports);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnreadSummary extends UnreadSummary {
  const _UnreadSummary({this.total = 0,  List<UnreadReport> reports = const []}): _reports = reports,super._();
  factory _UnreadSummary.fromJson(Map<String, dynamic> json) => _$UnreadSummaryFromJson(json);

@override@JsonKey() final  int total;
 final  List<UnreadReport> _reports;
@override@JsonKey() List<UnreadReport> get reports {
  if (_reports is EqualUnmodifiableListView) return _reports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reports);
}


/// Create a copy of UnreadSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnreadSummaryCopyWith<_UnreadSummary> get copyWith => __$UnreadSummaryCopyWithImpl<_UnreadSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnreadSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnreadSummary&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.reports, _reports));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,total,const DeepCollectionEquality().hash(_reports));
}

@override
String toString() {
    return 'UnreadSummary(total: $total, reports: $reports)';
}


}

/// @nodoc
abstract mixin class _$UnreadSummaryCopyWith<$Res> implements $UnreadSummaryCopyWith<$Res> {
  factory _$UnreadSummaryCopyWith(_UnreadSummary value, $Res Function(_UnreadSummary) _then) = __$UnreadSummaryCopyWithImpl;
@override @useResult
$Res call({
 int total, List<UnreadReport> reports
});




}
/// @nodoc
class __$UnreadSummaryCopyWithImpl<$Res>
    implements _$UnreadSummaryCopyWith<$Res> {
  __$UnreadSummaryCopyWithImpl(this._self, this._then);

  final _UnreadSummary _self;
  final $Res Function(_UnreadSummary) _then;

/// Create a copy of UnreadSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? reports = null,}) {
  return _then(_UnreadSummary(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,reports: null == reports ? _self._reports : reports // ignore: cast_nullable_to_non_nullable
as List<UnreadReport>,
  ));
}


}

// dart format on

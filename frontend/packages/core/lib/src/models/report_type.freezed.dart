// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportType {

 int? get id; String get code; String get name; String? get description; int get priority; bool get isEmergency; bool get requiresDestination; String? get icon; String? get color; String? get textColor; int get sortOrder;
/// Create a copy of ReportType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportTypeCopyWith<ReportType> get copyWith => _$ReportTypeCopyWithImpl<ReportType>(this as ReportType, _$identity);

  /// Serializes this ReportType to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportType;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportType&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.isEmergency, _this.isEmergency) || other.isEmergency == _this.isEmergency)&&(identical(other.requiresDestination, _this.requiresDestination) || other.requiresDestination == _this.requiresDestination)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.textColor, _this.textColor) || other.textColor == _this.textColor)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportType;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name,_this.description,_this.priority,_this.isEmergency,_this.requiresDestination,_this.icon,_this.color,_this.textColor,_this.sortOrder);
}

@override
String toString() {
  final _this = this as ReportType;
  return 'ReportType(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, description: ${_this.description}, priority: ${_this.priority}, isEmergency: ${_this.isEmergency}, requiresDestination: ${_this.requiresDestination}, icon: ${_this.icon}, color: ${_this.color}, textColor: ${_this.textColor}, sortOrder: ${_this.sortOrder})';
}


}

/// @nodoc
abstract mixin class $ReportTypeCopyWith<$Res>  {
  factory $ReportTypeCopyWith(ReportType value, $Res Function(ReportType) _then) = _$ReportTypeCopyWithImpl;
@useResult
$Res call({
 int? id, String code, String name, String? description, int priority, bool isEmergency, bool requiresDestination, String? icon, String? color, String? textColor, int sortOrder
});




}
/// @nodoc
class _$ReportTypeCopyWithImpl<$Res>
    implements $ReportTypeCopyWith<$Res> {
  _$ReportTypeCopyWithImpl(this._self, this._then);

  final ReportType _self;
  final $Res Function(ReportType) _then;

/// Create a copy of ReportType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? code = null,Object? name = null,Object? description = freezed,Object? priority = null,Object? isEmergency = null,Object? requiresDestination = null,Object? icon = freezed,Object? color = freezed,Object? textColor = freezed,Object? sortOrder = null,}) {
  return _then(ReportType(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,isEmergency: null == isEmergency ? _self.isEmergency : isEmergency // ignore: cast_nullable_to_non_nullable
as bool,requiresDestination: null == requiresDestination ? _self.requiresDestination : requiresDestination // ignore: cast_nullable_to_non_nullable
as bool,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,textColor: freezed == textColor ? _self.textColor : textColor // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportType].
extension ReportTypePatterns on ReportType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportType() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportType value)  $default,){
final _that = this;
switch (_that) {
case _ReportType():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportType value)?  $default,){
final _that = this;
switch (_that) {
case _ReportType() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String code,  String name,  String? description,  int priority,  bool isEmergency,  bool requiresDestination,  String? icon,  String? color,  String? textColor,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportType() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.description,_that.priority,_that.isEmergency,_that.requiresDestination,_that.icon,_that.color,_that.textColor,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String code,  String name,  String? description,  int priority,  bool isEmergency,  bool requiresDestination,  String? icon,  String? color,  String? textColor,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _ReportType():
return $default(_that.id,_that.code,_that.name,_that.description,_that.priority,_that.isEmergency,_that.requiresDestination,_that.icon,_that.color,_that.textColor,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String code,  String name,  String? description,  int priority,  bool isEmergency,  bool requiresDestination,  String? icon,  String? color,  String? textColor,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _ReportType() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.description,_that.priority,_that.isEmergency,_that.requiresDestination,_that.icon,_that.color,_that.textColor,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportType extends ReportType {
  const _ReportType({this.id, required this.code, required this.name, this.description, this.priority = 1, this.isEmergency = true, this.requiresDestination = false, this.icon, this.color, this.textColor, this.sortOrder = 0}): super._();
  factory _ReportType.fromJson(Map<String, dynamic> json) => _$ReportTypeFromJson(json);

@override final  int? id;
@override final  String code;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  int priority;
@override@JsonKey() final  bool isEmergency;
@override@JsonKey() final  bool requiresDestination;
@override final  String? icon;
@override final  String? color;
@override final  String? textColor;
@override@JsonKey() final  int sortOrder;

/// Create a copy of ReportType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportTypeCopyWith<_ReportType> get copyWith => __$ReportTypeCopyWithImpl<_ReportType>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportTypeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportType&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.isEmergency, isEmergency) || other.isEmergency == isEmergency)&&(identical(other.requiresDestination, requiresDestination) || other.requiresDestination == requiresDestination)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.textColor, textColor) || other.textColor == textColor)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name,description,priority,isEmergency,requiresDestination,icon,color,textColor,sortOrder);
}

@override
String toString() {
    return 'ReportType(id: $id, code: $code, name: $name, description: $description, priority: $priority, isEmergency: $isEmergency, requiresDestination: $requiresDestination, icon: $icon, color: $color, textColor: $textColor, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$ReportTypeCopyWith<$Res> implements $ReportTypeCopyWith<$Res> {
  factory _$ReportTypeCopyWith(_ReportType value, $Res Function(_ReportType) _then) = __$ReportTypeCopyWithImpl;
@override @useResult
$Res call({
 int? id, String code, String name, String? description, int priority, bool isEmergency, bool requiresDestination, String? icon, String? color, String? textColor, int sortOrder
});




}
/// @nodoc
class __$ReportTypeCopyWithImpl<$Res>
    implements _$ReportTypeCopyWith<$Res> {
  __$ReportTypeCopyWithImpl(this._self, this._then);

  final _ReportType _self;
  final $Res Function(_ReportType) _then;

/// Create a copy of ReportType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? code = null,Object? name = null,Object? description = freezed,Object? priority = null,Object? isEmergency = null,Object? requiresDestination = null,Object? icon = freezed,Object? color = freezed,Object? textColor = freezed,Object? sortOrder = null,}) {
  return _then(_ReportType(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,isEmergency: null == isEmergency ? _self.isEmergency : isEmergency // ignore: cast_nullable_to_non_nullable
as bool,requiresDestination: null == requiresDestination ? _self.requiresDestination : requiresDestination // ignore: cast_nullable_to_non_nullable
as bool,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,textColor: freezed == textColor ? _self.textColor : textColor // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

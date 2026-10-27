// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'common.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LabeledValue {

 String get value; String get label; String? get tone;
/// Create a copy of LabeledValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<LabeledValue> get copyWith => _$LabeledValueCopyWithImpl<LabeledValue>(this as LabeledValue, _$identity);

  /// Serializes this LabeledValue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LabeledValue;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabeledValue&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.tone, _this.tone) || other.tone == _this.tone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LabeledValue;
  return Object.hash(runtimeType,_this.value,_this.label,_this.tone);
}

@override
String toString() {
  final _this = this as LabeledValue;
  return 'LabeledValue(value: ${_this.value}, label: ${_this.label}, tone: ${_this.tone})';
}


}

/// @nodoc
abstract mixin class $LabeledValueCopyWith<$Res>  {
  factory $LabeledValueCopyWith(LabeledValue value, $Res Function(LabeledValue) _then) = _$LabeledValueCopyWithImpl;
@useResult
$Res call({
 String value, String label, String? tone
});




}
/// @nodoc
class _$LabeledValueCopyWithImpl<$Res>
    implements $LabeledValueCopyWith<$Res> {
  _$LabeledValueCopyWithImpl(this._self, this._then);

  final LabeledValue _self;
  final $Res Function(LabeledValue) _then;

/// Create a copy of LabeledValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? label = null,Object? tone = freezed,}) {
  return _then(LabeledValue(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,tone: freezed == tone ? _self.tone : tone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LabeledValue].
extension LabeledValuePatterns on LabeledValue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabeledValue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabeledValue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabeledValue value)  $default,){
final _that = this;
switch (_that) {
case _LabeledValue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabeledValue value)?  $default,){
final _that = this;
switch (_that) {
case _LabeledValue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String label,  String? tone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabeledValue() when $default != null:
return $default(_that.value,_that.label,_that.tone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String label,  String? tone)  $default,) {final _that = this;
switch (_that) {
case _LabeledValue():
return $default(_that.value,_that.label,_that.tone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String label,  String? tone)?  $default,) {final _that = this;
switch (_that) {
case _LabeledValue() when $default != null:
return $default(_that.value,_that.label,_that.tone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LabeledValue implements LabeledValue {
  const _LabeledValue({required this.value, required this.label, this.tone});
  factory _LabeledValue.fromJson(Map<String, dynamic> json) => _$LabeledValueFromJson(json);

@override final  String value;
@override final  String label;
@override final  String? tone;

/// Create a copy of LabeledValue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabeledValueCopyWith<_LabeledValue> get copyWith => __$LabeledValueCopyWithImpl<_LabeledValue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LabeledValueToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabeledValue&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label)&&(identical(other.tone, tone) || other.tone == tone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,value,label,tone);
}

@override
String toString() {
    return 'LabeledValue(value: $value, label: $label, tone: $tone)';
}


}

/// @nodoc
abstract mixin class _$LabeledValueCopyWith<$Res> implements $LabeledValueCopyWith<$Res> {
  factory _$LabeledValueCopyWith(_LabeledValue value, $Res Function(_LabeledValue) _then) = __$LabeledValueCopyWithImpl;
@override @useResult
$Res call({
 String value, String label, String? tone
});




}
/// @nodoc
class __$LabeledValueCopyWithImpl<$Res>
    implements _$LabeledValueCopyWith<$Res> {
  __$LabeledValueCopyWithImpl(this._self, this._then);

  final _LabeledValue _self;
  final $Res Function(_LabeledValue) _then;

/// Create a copy of LabeledValue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? label = null,Object? tone = freezed,}) {
  return _then(_LabeledValue(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,tone: freezed == tone ? _self.tone : tone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DriverLocation {

 double get lat; double get lng; int? get heading; double? get speedKmh; DateTime? get updatedAt;
/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverLocationCopyWith<DriverLocation> get copyWith => _$DriverLocationCopyWithImpl<DriverLocation>(this as DriverLocation, _$identity);

  /// Serializes this DriverLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DriverLocation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverLocation&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lng, _this.lng) || other.lng == _this.lng)&&(identical(other.heading, _this.heading) || other.heading == _this.heading)&&(identical(other.speedKmh, _this.speedKmh) || other.speedKmh == _this.speedKmh)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DriverLocation;
  return Object.hash(runtimeType,_this.lat,_this.lng,_this.heading,_this.speedKmh,_this.updatedAt);
}

@override
String toString() {
  final _this = this as DriverLocation;
  return 'DriverLocation(lat: ${_this.lat}, lng: ${_this.lng}, heading: ${_this.heading}, speedKmh: ${_this.speedKmh}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $DriverLocationCopyWith<$Res>  {
  factory $DriverLocationCopyWith(DriverLocation value, $Res Function(DriverLocation) _then) = _$DriverLocationCopyWithImpl;
@useResult
$Res call({
 double lat, double lng, int? heading, double? speedKmh, DateTime? updatedAt
});




}
/// @nodoc
class _$DriverLocationCopyWithImpl<$Res>
    implements $DriverLocationCopyWith<$Res> {
  _$DriverLocationCopyWithImpl(this._self, this._then);

  final DriverLocation _self;
  final $Res Function(DriverLocation) _then;

/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lat = null,Object? lng = null,Object? heading = freezed,Object? speedKmh = freezed,Object? updatedAt = freezed,}) {
  return _then(DriverLocation(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as int?,speedKmh: freezed == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverLocation].
extension DriverLocationPatterns on DriverLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverLocation value)  $default,){
final _that = this;
switch (_that) {
case _DriverLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverLocation value)?  $default,){
final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double lat,  double lng,  int? heading,  double? speedKmh,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
return $default(_that.lat,_that.lng,_that.heading,_that.speedKmh,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double lat,  double lng,  int? heading,  double? speedKmh,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DriverLocation():
return $default(_that.lat,_that.lng,_that.heading,_that.speedKmh,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double lat,  double lng,  int? heading,  double? speedKmh,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
return $default(_that.lat,_that.lng,_that.heading,_that.speedKmh,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverLocation implements DriverLocation {
  const _DriverLocation({required this.lat, required this.lng, this.heading, this.speedKmh, this.updatedAt});
  factory _DriverLocation.fromJson(Map<String, dynamic> json) => _$DriverLocationFromJson(json);

@override final  double lat;
@override final  double lng;
@override final  int? heading;
@override final  double? speedKmh;
@override final  DateTime? updatedAt;

/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverLocationCopyWith<_DriverLocation> get copyWith => __$DriverLocationCopyWithImpl<_DriverLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverLocationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverLocation&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lat,lng,heading,speedKmh,updatedAt);
}

@override
String toString() {
    return 'DriverLocation(lat: $lat, lng: $lng, heading: $heading, speedKmh: $speedKmh, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DriverLocationCopyWith<$Res> implements $DriverLocationCopyWith<$Res> {
  factory _$DriverLocationCopyWith(_DriverLocation value, $Res Function(_DriverLocation) _then) = __$DriverLocationCopyWithImpl;
@override @useResult
$Res call({
 double lat, double lng, int? heading, double? speedKmh, DateTime? updatedAt
});




}
/// @nodoc
class __$DriverLocationCopyWithImpl<$Res>
    implements _$DriverLocationCopyWith<$Res> {
  __$DriverLocationCopyWithImpl(this._self, this._then);

  final _DriverLocation _self;
  final $Res Function(_DriverLocation) _then;

/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lat = null,Object? lng = null,Object? heading = freezed,Object? speedKmh = freezed,Object? updatedAt = freezed,}) {
  return _then(_DriverLocation(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as int?,speedKmh: freezed == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Institution {

 int get id; String get name; String? get code; LabeledValue? get type; String? get phone;
/// Create a copy of Institution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InstitutionCopyWith<Institution> get copyWith => _$InstitutionCopyWithImpl<Institution>(this as Institution, _$identity);

  /// Serializes this Institution to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Institution;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Institution&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.phone, _this.phone) || other.phone == _this.phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Institution;
  return Object.hash(runtimeType,_this.id,_this.name,_this.code,_this.type,_this.phone);
}

@override
String toString() {
  final _this = this as Institution;
  return 'Institution(id: ${_this.id}, name: ${_this.name}, code: ${_this.code}, type: ${_this.type}, phone: ${_this.phone})';
}


}

/// @nodoc
abstract mixin class $InstitutionCopyWith<$Res>  {
  factory $InstitutionCopyWith(Institution value, $Res Function(Institution) _then) = _$InstitutionCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? code, LabeledValue? type, String? phone
});


$LabeledValueCopyWith<$Res>? get type;

}
/// @nodoc
class _$InstitutionCopyWithImpl<$Res>
    implements $InstitutionCopyWith<$Res> {
  _$InstitutionCopyWithImpl(this._self, this._then);

  final Institution _self;
  final $Res Function(Institution) _then;

/// Create a copy of Institution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? code = freezed,Object? type = freezed,Object? phone = freezed,}) {
  return _then(Institution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LabeledValue?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Institution
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get type {
    if (_self.type == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.type!, (value) {
    return _then(_self.copyWith(type: value));
  });
}
}


/// Adds pattern-matching-related methods to [Institution].
extension InstitutionPatterns on Institution {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Institution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Institution() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Institution value)  $default,){
final _that = this;
switch (_that) {
case _Institution():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Institution value)?  $default,){
final _that = this;
switch (_that) {
case _Institution() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? code,  LabeledValue? type,  String? phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Institution() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.type,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? code,  LabeledValue? type,  String? phone)  $default,) {final _that = this;
switch (_that) {
case _Institution():
return $default(_that.id,_that.name,_that.code,_that.type,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? code,  LabeledValue? type,  String? phone)?  $default,) {final _that = this;
switch (_that) {
case _Institution() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.type,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Institution implements Institution {
  const _Institution({required this.id, required this.name, this.code, this.type, this.phone});
  factory _Institution.fromJson(Map<String, dynamic> json) => _$InstitutionFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? code;
@override final  LabeledValue? type;
@override final  String? phone;

/// Create a copy of Institution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InstitutionCopyWith<_Institution> get copyWith => __$InstitutionCopyWithImpl<_Institution>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InstitutionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Institution&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,code,type,phone);
}

@override
String toString() {
    return 'Institution(id: $id, name: $name, code: $code, type: $type, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$InstitutionCopyWith<$Res> implements $InstitutionCopyWith<$Res> {
  factory _$InstitutionCopyWith(_Institution value, $Res Function(_Institution) _then) = __$InstitutionCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? code, LabeledValue? type, String? phone
});


@override $LabeledValueCopyWith<$Res>? get type;

}
/// @nodoc
class __$InstitutionCopyWithImpl<$Res>
    implements _$InstitutionCopyWith<$Res> {
  __$InstitutionCopyWithImpl(this._self, this._then);

  final _Institution _self;
  final $Res Function(_Institution) _then;

/// Create a copy of Institution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? code = freezed,Object? type = freezed,Object? phone = freezed,}) {
  return _then(_Institution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LabeledValue?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Institution
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get type {
    if (_self.type == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.type!, (value) {
    return _then(_self.copyWith(type: value));
  });
}
}


/// @nodoc
mixin _$Clinic {

 int get id; String get name; String? get code; String? get address; String? get phone; double? get latitude; double? get longitude; LabeledValue? get type; Institution? get institution;
/// Create a copy of Clinic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicCopyWith<Clinic> get copyWith => _$ClinicCopyWithImpl<Clinic>(this as Clinic, _$identity);

  /// Serializes this Clinic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Clinic;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Clinic&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.institution, _this.institution) || other.institution == _this.institution));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Clinic;
  return Object.hash(runtimeType,_this.id,_this.name,_this.code,_this.address,_this.phone,_this.latitude,_this.longitude,_this.type,_this.institution);
}

@override
String toString() {
  final _this = this as Clinic;
  return 'Clinic(id: ${_this.id}, name: ${_this.name}, code: ${_this.code}, address: ${_this.address}, phone: ${_this.phone}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, type: ${_this.type}, institution: ${_this.institution})';
}


}

/// @nodoc
abstract mixin class $ClinicCopyWith<$Res>  {
  factory $ClinicCopyWith(Clinic value, $Res Function(Clinic) _then) = _$ClinicCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? code, String? address, String? phone, double? latitude, double? longitude, LabeledValue? type, Institution? institution
});


$LabeledValueCopyWith<$Res>? get type;$InstitutionCopyWith<$Res>? get institution;

}
/// @nodoc
class _$ClinicCopyWithImpl<$Res>
    implements $ClinicCopyWith<$Res> {
  _$ClinicCopyWithImpl(this._self, this._then);

  final Clinic _self;
  final $Res Function(Clinic) _then;

/// Create a copy of Clinic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? code = freezed,Object? address = freezed,Object? phone = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? type = freezed,Object? institution = freezed,}) {
  return _then(Clinic(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LabeledValue?,institution: freezed == institution ? _self.institution : institution // ignore: cast_nullable_to_non_nullable
as Institution?,
  ));
}
/// Create a copy of Clinic
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get type {
    if (_self.type == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.type!, (value) {
    return _then(_self.copyWith(type: value));
  });
}/// Create a copy of Clinic
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InstitutionCopyWith<$Res>? get institution {
    if (_self.institution == null) {
    return null;
  }

  return $InstitutionCopyWith<$Res>(_self.institution!, (value) {
    return _then(_self.copyWith(institution: value));
  });
}
}


/// Adds pattern-matching-related methods to [Clinic].
extension ClinicPatterns on Clinic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Clinic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Clinic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Clinic value)  $default,){
final _that = this;
switch (_that) {
case _Clinic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Clinic value)?  $default,){
final _that = this;
switch (_that) {
case _Clinic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? code,  String? address,  String? phone,  double? latitude,  double? longitude,  LabeledValue? type,  Institution? institution)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Clinic() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.address,_that.phone,_that.latitude,_that.longitude,_that.type,_that.institution);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? code,  String? address,  String? phone,  double? latitude,  double? longitude,  LabeledValue? type,  Institution? institution)  $default,) {final _that = this;
switch (_that) {
case _Clinic():
return $default(_that.id,_that.name,_that.code,_that.address,_that.phone,_that.latitude,_that.longitude,_that.type,_that.institution);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? code,  String? address,  String? phone,  double? latitude,  double? longitude,  LabeledValue? type,  Institution? institution)?  $default,) {final _that = this;
switch (_that) {
case _Clinic() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.address,_that.phone,_that.latitude,_that.longitude,_that.type,_that.institution);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Clinic implements Clinic {
  const _Clinic({required this.id, required this.name, this.code, this.address, this.phone, this.latitude, this.longitude, this.type, this.institution});
  factory _Clinic.fromJson(Map<String, dynamic> json) => _$ClinicFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? code;
@override final  String? address;
@override final  String? phone;
@override final  double? latitude;
@override final  double? longitude;
@override final  LabeledValue? type;
@override final  Institution? institution;

/// Create a copy of Clinic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicCopyWith<_Clinic> get copyWith => __$ClinicCopyWithImpl<_Clinic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClinicToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Clinic&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.type, type) || other.type == type)&&(identical(other.institution, institution) || other.institution == institution));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,code,address,phone,latitude,longitude,type,institution);
}

@override
String toString() {
    return 'Clinic(id: $id, name: $name, code: $code, address: $address, phone: $phone, latitude: $latitude, longitude: $longitude, type: $type, institution: $institution)';
}


}

/// @nodoc
abstract mixin class _$ClinicCopyWith<$Res> implements $ClinicCopyWith<$Res> {
  factory _$ClinicCopyWith(_Clinic value, $Res Function(_Clinic) _then) = __$ClinicCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? code, String? address, String? phone, double? latitude, double? longitude, LabeledValue? type, Institution? institution
});


@override $LabeledValueCopyWith<$Res>? get type;@override $InstitutionCopyWith<$Res>? get institution;

}
/// @nodoc
class __$ClinicCopyWithImpl<$Res>
    implements _$ClinicCopyWith<$Res> {
  __$ClinicCopyWithImpl(this._self, this._then);

  final _Clinic _self;
  final $Res Function(_Clinic) _then;

/// Create a copy of Clinic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? code = freezed,Object? address = freezed,Object? phone = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? type = freezed,Object? institution = freezed,}) {
  return _then(_Clinic(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LabeledValue?,institution: freezed == institution ? _self.institution : institution // ignore: cast_nullable_to_non_nullable
as Institution?,
  ));
}

/// Create a copy of Clinic
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get type {
    if (_self.type == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.type!, (value) {
    return _then(_self.copyWith(type: value));
  });
}/// Create a copy of Clinic
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InstitutionCopyWith<$Res>? get institution {
    if (_self.institution == null) {
    return null;
  }

  return $InstitutionCopyWith<$Res>(_self.institution!, (value) {
    return _then(_self.copyWith(institution: value));
  });
}
}


/// @nodoc
mixin _$GeocodeResult {

 String get label; double get latitude; double get longitude;
/// Create a copy of GeocodeResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeocodeResultCopyWith<GeocodeResult> get copyWith => _$GeocodeResultCopyWithImpl<GeocodeResult>(this as GeocodeResult, _$identity);

  /// Serializes this GeocodeResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GeocodeResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeocodeResult&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GeocodeResult;
  return Object.hash(runtimeType,_this.label,_this.latitude,_this.longitude);
}

@override
String toString() {
  final _this = this as GeocodeResult;
  return 'GeocodeResult(label: ${_this.label}, latitude: ${_this.latitude}, longitude: ${_this.longitude})';
}


}

/// @nodoc
abstract mixin class $GeocodeResultCopyWith<$Res>  {
  factory $GeocodeResultCopyWith(GeocodeResult value, $Res Function(GeocodeResult) _then) = _$GeocodeResultCopyWithImpl;
@useResult
$Res call({
 String label, double latitude, double longitude
});




}
/// @nodoc
class _$GeocodeResultCopyWithImpl<$Res>
    implements $GeocodeResultCopyWith<$Res> {
  _$GeocodeResultCopyWithImpl(this._self, this._then);

  final GeocodeResult _self;
  final $Res Function(GeocodeResult) _then;

/// Create a copy of GeocodeResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? latitude = null,Object? longitude = null,}) {
  return _then(GeocodeResult(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [GeocodeResult].
extension GeocodeResultPatterns on GeocodeResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeocodeResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeocodeResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeocodeResult value)  $default,){
final _that = this;
switch (_that) {
case _GeocodeResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeocodeResult value)?  $default,){
final _that = this;
switch (_that) {
case _GeocodeResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  double latitude,  double longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeocodeResult() when $default != null:
return $default(_that.label,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  double latitude,  double longitude)  $default,) {final _that = this;
switch (_that) {
case _GeocodeResult():
return $default(_that.label,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  double latitude,  double longitude)?  $default,) {final _that = this;
switch (_that) {
case _GeocodeResult() when $default != null:
return $default(_that.label,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GeocodeResult implements GeocodeResult {
  const _GeocodeResult({required this.label, required this.latitude, required this.longitude});
  factory _GeocodeResult.fromJson(Map<String, dynamic> json) => _$GeocodeResultFromJson(json);

@override final  String label;
@override final  double latitude;
@override final  double longitude;

/// Create a copy of GeocodeResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeocodeResultCopyWith<_GeocodeResult> get copyWith => __$GeocodeResultCopyWithImpl<_GeocodeResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GeocodeResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeocodeResult&&(identical(other.label, label) || other.label == label)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,latitude,longitude);
}

@override
String toString() {
    return 'GeocodeResult(label: $label, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$GeocodeResultCopyWith<$Res> implements $GeocodeResultCopyWith<$Res> {
  factory _$GeocodeResultCopyWith(_GeocodeResult value, $Res Function(_GeocodeResult) _then) = __$GeocodeResultCopyWithImpl;
@override @useResult
$Res call({
 String label, double latitude, double longitude
});




}
/// @nodoc
class __$GeocodeResultCopyWithImpl<$Res>
    implements _$GeocodeResultCopyWith<$Res> {
  __$GeocodeResultCopyWithImpl(this._self, this._then);

  final _GeocodeResult _self;
  final $Res Function(_GeocodeResult) _then;

/// Create a copy of GeocodeResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? latitude = null,Object? longitude = null,}) {
  return _then(_GeocodeResult(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ReverseGeocode {

 String? get address; double get latitude; double get longitude;
/// Create a copy of ReverseGeocode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReverseGeocodeCopyWith<ReverseGeocode> get copyWith => _$ReverseGeocodeCopyWithImpl<ReverseGeocode>(this as ReverseGeocode, _$identity);

  /// Serializes this ReverseGeocode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReverseGeocode;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReverseGeocode&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReverseGeocode;
  return Object.hash(runtimeType,_this.address,_this.latitude,_this.longitude);
}

@override
String toString() {
  final _this = this as ReverseGeocode;
  return 'ReverseGeocode(address: ${_this.address}, latitude: ${_this.latitude}, longitude: ${_this.longitude})';
}


}

/// @nodoc
abstract mixin class $ReverseGeocodeCopyWith<$Res>  {
  factory $ReverseGeocodeCopyWith(ReverseGeocode value, $Res Function(ReverseGeocode) _then) = _$ReverseGeocodeCopyWithImpl;
@useResult
$Res call({
 String? address, double latitude, double longitude
});




}
/// @nodoc
class _$ReverseGeocodeCopyWithImpl<$Res>
    implements $ReverseGeocodeCopyWith<$Res> {
  _$ReverseGeocodeCopyWithImpl(this._self, this._then);

  final ReverseGeocode _self;
  final $Res Function(ReverseGeocode) _then;

/// Create a copy of ReverseGeocode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = freezed,Object? latitude = null,Object? longitude = null,}) {
  return _then(ReverseGeocode(
address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ReverseGeocode].
extension ReverseGeocodePatterns on ReverseGeocode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReverseGeocode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReverseGeocode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReverseGeocode value)  $default,){
final _that = this;
switch (_that) {
case _ReverseGeocode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReverseGeocode value)?  $default,){
final _that = this;
switch (_that) {
case _ReverseGeocode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? address,  double latitude,  double longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReverseGeocode() when $default != null:
return $default(_that.address,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? address,  double latitude,  double longitude)  $default,) {final _that = this;
switch (_that) {
case _ReverseGeocode():
return $default(_that.address,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? address,  double latitude,  double longitude)?  $default,) {final _that = this;
switch (_that) {
case _ReverseGeocode() when $default != null:
return $default(_that.address,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReverseGeocode implements ReverseGeocode {
  const _ReverseGeocode({this.address, required this.latitude, required this.longitude});
  factory _ReverseGeocode.fromJson(Map<String, dynamic> json) => _$ReverseGeocodeFromJson(json);

@override final  String? address;
@override final  double latitude;
@override final  double longitude;

/// Create a copy of ReverseGeocode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReverseGeocodeCopyWith<_ReverseGeocode> get copyWith => __$ReverseGeocodeCopyWithImpl<_ReverseGeocode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReverseGeocodeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReverseGeocode&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,address,latitude,longitude);
}

@override
String toString() {
    return 'ReverseGeocode(address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$ReverseGeocodeCopyWith<$Res> implements $ReverseGeocodeCopyWith<$Res> {
  factory _$ReverseGeocodeCopyWith(_ReverseGeocode value, $Res Function(_ReverseGeocode) _then) = __$ReverseGeocodeCopyWithImpl;
@override @useResult
$Res call({
 String? address, double latitude, double longitude
});




}
/// @nodoc
class __$ReverseGeocodeCopyWithImpl<$Res>
    implements _$ReverseGeocodeCopyWith<$Res> {
  __$ReverseGeocodeCopyWithImpl(this._self, this._then);

  final _ReverseGeocode _self;
  final $Res Function(_ReverseGeocode) _then;

/// Create a copy of ReverseGeocode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = freezed,Object? latitude = null,Object? longitude = null,}) {
  return _then(_ReverseGeocode(
address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$RouteResult {

 int? get reportId; double get distanceKm; double get durationMin; List<List<double>> get geometry; String get target; bool get stale; DateTime? get computedAt;
/// Create a copy of RouteResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteResultCopyWith<RouteResult> get copyWith => _$RouteResultCopyWithImpl<RouteResult>(this as RouteResult, _$identity);

  /// Serializes this RouteResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RouteResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteResult&&(identical(other.reportId, _this.reportId) || other.reportId == _this.reportId)&&(identical(other.distanceKm, _this.distanceKm) || other.distanceKm == _this.distanceKm)&&(identical(other.durationMin, _this.durationMin) || other.durationMin == _this.durationMin)&&const DeepCollectionEquality().equals(other.geometry, _this.geometry)&&(identical(other.target, _this.target) || other.target == _this.target)&&(identical(other.stale, _this.stale) || other.stale == _this.stale)&&(identical(other.computedAt, _this.computedAt) || other.computedAt == _this.computedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RouteResult;
  return Object.hash(runtimeType,_this.reportId,_this.distanceKm,_this.durationMin,const DeepCollectionEquality().hash(_this.geometry),_this.target,_this.stale,_this.computedAt);
}

@override
String toString() {
  final _this = this as RouteResult;
  return 'RouteResult(reportId: ${_this.reportId}, distanceKm: ${_this.distanceKm}, durationMin: ${_this.durationMin}, geometry: ${_this.geometry}, target: ${_this.target}, stale: ${_this.stale}, computedAt: ${_this.computedAt})';
}


}

/// @nodoc
abstract mixin class $RouteResultCopyWith<$Res>  {
  factory $RouteResultCopyWith(RouteResult value, $Res Function(RouteResult) _then) = _$RouteResultCopyWithImpl;
@useResult
$Res call({
 int? reportId, double distanceKm, double durationMin, List<List<double>> geometry, String target, bool stale, DateTime? computedAt
});




}
/// @nodoc
class _$RouteResultCopyWithImpl<$Res>
    implements $RouteResultCopyWith<$Res> {
  _$RouteResultCopyWithImpl(this._self, this._then);

  final RouteResult _self;
  final $Res Function(RouteResult) _then;

/// Create a copy of RouteResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reportId = freezed,Object? distanceKm = null,Object? durationMin = null,Object? geometry = null,Object? target = null,Object? stale = null,Object? computedAt = freezed,}) {
  return _then(RouteResult(
reportId: freezed == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as int?,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,durationMin: null == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as double,geometry: null == geometry ? _self.geometry : geometry // ignore: cast_nullable_to_non_nullable
as List<List<double>>,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,computedAt: freezed == computedAt ? _self.computedAt : computedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteResult].
extension RouteResultPatterns on RouteResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteResult value)  $default,){
final _that = this;
switch (_that) {
case _RouteResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteResult value)?  $default,){
final _that = this;
switch (_that) {
case _RouteResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? reportId,  double distanceKm,  double durationMin,  List<List<double>> geometry,  String target,  bool stale,  DateTime? computedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteResult() when $default != null:
return $default(_that.reportId,_that.distanceKm,_that.durationMin,_that.geometry,_that.target,_that.stale,_that.computedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? reportId,  double distanceKm,  double durationMin,  List<List<double>> geometry,  String target,  bool stale,  DateTime? computedAt)  $default,) {final _that = this;
switch (_that) {
case _RouteResult():
return $default(_that.reportId,_that.distanceKm,_that.durationMin,_that.geometry,_that.target,_that.stale,_that.computedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? reportId,  double distanceKm,  double durationMin,  List<List<double>> geometry,  String target,  bool stale,  DateTime? computedAt)?  $default,) {final _that = this;
switch (_that) {
case _RouteResult() when $default != null:
return $default(_that.reportId,_that.distanceKm,_that.durationMin,_that.geometry,_that.target,_that.stale,_that.computedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteResult extends RouteResult {
  const _RouteResult({this.reportId, required this.distanceKm, required this.durationMin,  List<List<double>> geometry = const [], this.target = 'pickup', this.stale = false, this.computedAt}): _geometry = geometry,super._();
  factory _RouteResult.fromJson(Map<String, dynamic> json) => _$RouteResultFromJson(json);

@override final  int? reportId;
@override final  double distanceKm;
@override final  double durationMin;
 final  List<List<double>> _geometry;
@override@JsonKey() List<List<double>> get geometry {
  if (_geometry is EqualUnmodifiableListView) return _geometry;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_geometry);
}

@override@JsonKey() final  String target;
@override@JsonKey() final  bool stale;
@override final  DateTime? computedAt;

/// Create a copy of RouteResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteResultCopyWith<_RouteResult> get copyWith => __$RouteResultCopyWithImpl<_RouteResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteResult&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.durationMin, durationMin) || other.durationMin == durationMin)&&const DeepCollectionEquality().equals(other.geometry, _geometry)&&(identical(other.target, target) || other.target == target)&&(identical(other.stale, stale) || other.stale == stale)&&(identical(other.computedAt, computedAt) || other.computedAt == computedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reportId,distanceKm,durationMin,const DeepCollectionEquality().hash(_geometry),target,stale,computedAt);
}

@override
String toString() {
    return 'RouteResult(reportId: $reportId, distanceKm: $distanceKm, durationMin: $durationMin, geometry: $geometry, target: $target, stale: $stale, computedAt: $computedAt)';
}


}

/// @nodoc
abstract mixin class _$RouteResultCopyWith<$Res> implements $RouteResultCopyWith<$Res> {
  factory _$RouteResultCopyWith(_RouteResult value, $Res Function(_RouteResult) _then) = __$RouteResultCopyWithImpl;
@override @useResult
$Res call({
 int? reportId, double distanceKm, double durationMin, List<List<double>> geometry, String target, bool stale, DateTime? computedAt
});




}
/// @nodoc
class __$RouteResultCopyWithImpl<$Res>
    implements _$RouteResultCopyWith<$Res> {
  __$RouteResultCopyWithImpl(this._self, this._then);

  final _RouteResult _self;
  final $Res Function(_RouteResult) _then;

/// Create a copy of RouteResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reportId = freezed,Object? distanceKm = null,Object? durationMin = null,Object? geometry = null,Object? target = null,Object? stale = null,Object? computedAt = freezed,}) {
  return _then(_RouteResult(
reportId: freezed == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as int?,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,durationMin: null == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as double,geometry: null == geometry ? _self._geometry : geometry // ignore: cast_nullable_to_non_nullable
as List<List<double>>,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,computedAt: freezed == computedAt ? _self.computedAt : computedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

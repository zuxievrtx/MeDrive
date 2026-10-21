// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportDestination {

 String? get name; String? get address; double? get latitude; double? get longitude;
/// Create a copy of ReportDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportDestinationCopyWith<ReportDestination> get copyWith => _$ReportDestinationCopyWithImpl<ReportDestination>(this as ReportDestination, _$identity);

  /// Serializes this ReportDestination to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportDestination;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportDestination&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportDestination;
  return Object.hash(runtimeType,_this.name,_this.address,_this.latitude,_this.longitude);
}

@override
String toString() {
  final _this = this as ReportDestination;
  return 'ReportDestination(name: ${_this.name}, address: ${_this.address}, latitude: ${_this.latitude}, longitude: ${_this.longitude})';
}


}

/// @nodoc
abstract mixin class $ReportDestinationCopyWith<$Res>  {
  factory $ReportDestinationCopyWith(ReportDestination value, $Res Function(ReportDestination) _then) = _$ReportDestinationCopyWithImpl;
@useResult
$Res call({
 String? name, String? address, double? latitude, double? longitude
});




}
/// @nodoc
class _$ReportDestinationCopyWithImpl<$Res>
    implements $ReportDestinationCopyWith<$Res> {
  _$ReportDestinationCopyWithImpl(this._self, this._then);

  final ReportDestination _self;
  final $Res Function(ReportDestination) _then;

/// Create a copy of ReportDestination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(ReportDestination(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportDestination].
extension ReportDestinationPatterns on ReportDestination {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportDestination value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportDestination() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportDestination value)  $default,){
final _that = this;
switch (_that) {
case _ReportDestination():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportDestination value)?  $default,){
final _that = this;
switch (_that) {
case _ReportDestination() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? address,  double? latitude,  double? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportDestination() when $default != null:
return $default(_that.name,_that.address,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? address,  double? latitude,  double? longitude)  $default,) {final _that = this;
switch (_that) {
case _ReportDestination():
return $default(_that.name,_that.address,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? address,  double? latitude,  double? longitude)?  $default,) {final _that = this;
switch (_that) {
case _ReportDestination() when $default != null:
return $default(_that.name,_that.address,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportDestination implements ReportDestination {
  const _ReportDestination({this.name, this.address, this.latitude, this.longitude});
  factory _ReportDestination.fromJson(Map<String, dynamic> json) => _$ReportDestinationFromJson(json);

@override final  String? name;
@override final  String? address;
@override final  double? latitude;
@override final  double? longitude;

/// Create a copy of ReportDestination
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportDestinationCopyWith<_ReportDestination> get copyWith => __$ReportDestinationCopyWithImpl<_ReportDestination>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportDestinationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportDestination&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,address,latitude,longitude);
}

@override
String toString() {
    return 'ReportDestination(name: $name, address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$ReportDestinationCopyWith<$Res> implements $ReportDestinationCopyWith<$Res> {
  factory _$ReportDestinationCopyWith(_ReportDestination value, $Res Function(_ReportDestination) _then) = __$ReportDestinationCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? address, double? latitude, double? longitude
});




}
/// @nodoc
class __$ReportDestinationCopyWithImpl<$Res>
    implements _$ReportDestinationCopyWith<$Res> {
  __$ReportDestinationCopyWithImpl(this._self, this._then);

  final _ReportDestination _self;
  final $Res Function(_ReportDestination) _then;

/// Create a copy of ReportDestination
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_ReportDestination(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$ReportDriver {

 int get id; String get name; String? get phone; bool get isVerified; String? get photoUrl; String? get clinic;
/// Create a copy of ReportDriver
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportDriverCopyWith<ReportDriver> get copyWith => _$ReportDriverCopyWithImpl<ReportDriver>(this as ReportDriver, _$identity);

  /// Serializes this ReportDriver to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportDriver;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportDriver&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.isVerified, _this.isVerified) || other.isVerified == _this.isVerified)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&(identical(other.clinic, _this.clinic) || other.clinic == _this.clinic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportDriver;
  return Object.hash(runtimeType,_this.id,_this.name,_this.phone,_this.isVerified,_this.photoUrl,_this.clinic);
}

@override
String toString() {
  final _this = this as ReportDriver;
  return 'ReportDriver(id: ${_this.id}, name: ${_this.name}, phone: ${_this.phone}, isVerified: ${_this.isVerified}, photoUrl: ${_this.photoUrl}, clinic: ${_this.clinic})';
}


}

/// @nodoc
abstract mixin class $ReportDriverCopyWith<$Res>  {
  factory $ReportDriverCopyWith(ReportDriver value, $Res Function(ReportDriver) _then) = _$ReportDriverCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? phone, bool isVerified, String? photoUrl, String? clinic
});




}
/// @nodoc
class _$ReportDriverCopyWithImpl<$Res>
    implements $ReportDriverCopyWith<$Res> {
  _$ReportDriverCopyWithImpl(this._self, this._then);

  final ReportDriver _self;
  final $Res Function(ReportDriver) _then;

/// Create a copy of ReportDriver
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? phone = freezed,Object? isVerified = null,Object? photoUrl = freezed,Object? clinic = freezed,}) {
  return _then(ReportDriver(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,clinic: freezed == clinic ? _self.clinic : clinic // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportDriver].
extension ReportDriverPatterns on ReportDriver {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportDriver value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportDriver() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportDriver value)  $default,){
final _that = this;
switch (_that) {
case _ReportDriver():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportDriver value)?  $default,){
final _that = this;
switch (_that) {
case _ReportDriver() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? phone,  bool isVerified,  String? photoUrl,  String? clinic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportDriver() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.isVerified,_that.photoUrl,_that.clinic);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? phone,  bool isVerified,  String? photoUrl,  String? clinic)  $default,) {final _that = this;
switch (_that) {
case _ReportDriver():
return $default(_that.id,_that.name,_that.phone,_that.isVerified,_that.photoUrl,_that.clinic);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? phone,  bool isVerified,  String? photoUrl,  String? clinic)?  $default,) {final _that = this;
switch (_that) {
case _ReportDriver() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.isVerified,_that.photoUrl,_that.clinic);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportDriver implements ReportDriver {
  const _ReportDriver({required this.id, required this.name, this.phone, this.isVerified = false, this.photoUrl, this.clinic});
  factory _ReportDriver.fromJson(Map<String, dynamic> json) => _$ReportDriverFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? phone;
@override@JsonKey() final  bool isVerified;
@override final  String? photoUrl;
@override final  String? clinic;

/// Create a copy of ReportDriver
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportDriverCopyWith<_ReportDriver> get copyWith => __$ReportDriverCopyWithImpl<_ReportDriver>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportDriverToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportDriver&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.clinic, clinic) || other.clinic == clinic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,phone,isVerified,photoUrl,clinic);
}

@override
String toString() {
    return 'ReportDriver(id: $id, name: $name, phone: $phone, isVerified: $isVerified, photoUrl: $photoUrl, clinic: $clinic)';
}


}

/// @nodoc
abstract mixin class _$ReportDriverCopyWith<$Res> implements $ReportDriverCopyWith<$Res> {
  factory _$ReportDriverCopyWith(_ReportDriver value, $Res Function(_ReportDriver) _then) = __$ReportDriverCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? phone, bool isVerified, String? photoUrl, String? clinic
});




}
/// @nodoc
class __$ReportDriverCopyWithImpl<$Res>
    implements _$ReportDriverCopyWith<$Res> {
  __$ReportDriverCopyWithImpl(this._self, this._then);

  final _ReportDriver _self;
  final $Res Function(_ReportDriver) _then;

/// Create a copy of ReportDriver
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? phone = freezed,Object? isVerified = null,Object? photoUrl = freezed,Object? clinic = freezed,}) {
  return _then(_ReportDriver(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,clinic: freezed == clinic ? _self.clinic : clinic // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ReportAmbulance {

 int? get id; String get plateNumber; String? get vehicleName; String? get type; String? get mapIcon; String? get clinic;
/// Create a copy of ReportAmbulance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportAmbulanceCopyWith<ReportAmbulance> get copyWith => _$ReportAmbulanceCopyWithImpl<ReportAmbulance>(this as ReportAmbulance, _$identity);

  /// Serializes this ReportAmbulance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportAmbulance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportAmbulance&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.plateNumber, _this.plateNumber) || other.plateNumber == _this.plateNumber)&&(identical(other.vehicleName, _this.vehicleName) || other.vehicleName == _this.vehicleName)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.mapIcon, _this.mapIcon) || other.mapIcon == _this.mapIcon)&&(identical(other.clinic, _this.clinic) || other.clinic == _this.clinic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportAmbulance;
  return Object.hash(runtimeType,_this.id,_this.plateNumber,_this.vehicleName,_this.type,_this.mapIcon,_this.clinic);
}

@override
String toString() {
  final _this = this as ReportAmbulance;
  return 'ReportAmbulance(id: ${_this.id}, plateNumber: ${_this.plateNumber}, vehicleName: ${_this.vehicleName}, type: ${_this.type}, mapIcon: ${_this.mapIcon}, clinic: ${_this.clinic})';
}


}

/// @nodoc
abstract mixin class $ReportAmbulanceCopyWith<$Res>  {
  factory $ReportAmbulanceCopyWith(ReportAmbulance value, $Res Function(ReportAmbulance) _then) = _$ReportAmbulanceCopyWithImpl;
@useResult
$Res call({
 int? id, String plateNumber, String? vehicleName, String? type, String? mapIcon, String? clinic
});




}
/// @nodoc
class _$ReportAmbulanceCopyWithImpl<$Res>
    implements $ReportAmbulanceCopyWith<$Res> {
  _$ReportAmbulanceCopyWithImpl(this._self, this._then);

  final ReportAmbulance _self;
  final $Res Function(ReportAmbulance) _then;

/// Create a copy of ReportAmbulance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? plateNumber = null,Object? vehicleName = freezed,Object? type = freezed,Object? mapIcon = freezed,Object? clinic = freezed,}) {
  return _then(ReportAmbulance(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,plateNumber: null == plateNumber ? _self.plateNumber : plateNumber // ignore: cast_nullable_to_non_nullable
as String,vehicleName: freezed == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,mapIcon: freezed == mapIcon ? _self.mapIcon : mapIcon // ignore: cast_nullable_to_non_nullable
as String?,clinic: freezed == clinic ? _self.clinic : clinic // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportAmbulance].
extension ReportAmbulancePatterns on ReportAmbulance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportAmbulance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportAmbulance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportAmbulance value)  $default,){
final _that = this;
switch (_that) {
case _ReportAmbulance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportAmbulance value)?  $default,){
final _that = this;
switch (_that) {
case _ReportAmbulance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String plateNumber,  String? vehicleName,  String? type,  String? mapIcon,  String? clinic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportAmbulance() when $default != null:
return $default(_that.id,_that.plateNumber,_that.vehicleName,_that.type,_that.mapIcon,_that.clinic);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String plateNumber,  String? vehicleName,  String? type,  String? mapIcon,  String? clinic)  $default,) {final _that = this;
switch (_that) {
case _ReportAmbulance():
return $default(_that.id,_that.plateNumber,_that.vehicleName,_that.type,_that.mapIcon,_that.clinic);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String plateNumber,  String? vehicleName,  String? type,  String? mapIcon,  String? clinic)?  $default,) {final _that = this;
switch (_that) {
case _ReportAmbulance() when $default != null:
return $default(_that.id,_that.plateNumber,_that.vehicleName,_that.type,_that.mapIcon,_that.clinic);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportAmbulance implements ReportAmbulance {
  const _ReportAmbulance({this.id, required this.plateNumber, this.vehicleName, this.type, this.mapIcon, this.clinic});
  factory _ReportAmbulance.fromJson(Map<String, dynamic> json) => _$ReportAmbulanceFromJson(json);

@override final  int? id;
@override final  String plateNumber;
@override final  String? vehicleName;
@override final  String? type;
@override final  String? mapIcon;
@override final  String? clinic;

/// Create a copy of ReportAmbulance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportAmbulanceCopyWith<_ReportAmbulance> get copyWith => __$ReportAmbulanceCopyWithImpl<_ReportAmbulance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportAmbulanceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportAmbulance&&(identical(other.id, id) || other.id == id)&&(identical(other.plateNumber, plateNumber) || other.plateNumber == plateNumber)&&(identical(other.vehicleName, vehicleName) || other.vehicleName == vehicleName)&&(identical(other.type, type) || other.type == type)&&(identical(other.mapIcon, mapIcon) || other.mapIcon == mapIcon)&&(identical(other.clinic, clinic) || other.clinic == clinic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,plateNumber,vehicleName,type,mapIcon,clinic);
}

@override
String toString() {
    return 'ReportAmbulance(id: $id, plateNumber: $plateNumber, vehicleName: $vehicleName, type: $type, mapIcon: $mapIcon, clinic: $clinic)';
}


}

/// @nodoc
abstract mixin class _$ReportAmbulanceCopyWith<$Res> implements $ReportAmbulanceCopyWith<$Res> {
  factory _$ReportAmbulanceCopyWith(_ReportAmbulance value, $Res Function(_ReportAmbulance) _then) = __$ReportAmbulanceCopyWithImpl;
@override @useResult
$Res call({
 int? id, String plateNumber, String? vehicleName, String? type, String? mapIcon, String? clinic
});




}
/// @nodoc
class __$ReportAmbulanceCopyWithImpl<$Res>
    implements _$ReportAmbulanceCopyWith<$Res> {
  __$ReportAmbulanceCopyWithImpl(this._self, this._then);

  final _ReportAmbulance _self;
  final $Res Function(_ReportAmbulance) _then;

/// Create a copy of ReportAmbulance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? plateNumber = null,Object? vehicleName = freezed,Object? type = freezed,Object? mapIcon = freezed,Object? clinic = freezed,}) {
  return _then(_ReportAmbulance(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,plateNumber: null == plateNumber ? _self.plateNumber : plateNumber // ignore: cast_nullable_to_non_nullable
as String,vehicleName: freezed == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,mapIcon: freezed == mapIcon ? _self.mapIcon : mapIcon // ignore: cast_nullable_to_non_nullable
as String?,clinic: freezed == clinic ? _self.clinic : clinic // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ReportPatient {

 int get id; String? get name; String? get gender; int? get ageEstimate; LabeledValue? get consciousness; bool? get isBreathing; String? get conditionNote; String? get handedOverTo; DateTime? get handedOverAt;
/// Create a copy of ReportPatient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportPatientCopyWith<ReportPatient> get copyWith => _$ReportPatientCopyWithImpl<ReportPatient>(this as ReportPatient, _$identity);

  /// Serializes this ReportPatient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportPatient;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportPatient&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.ageEstimate, _this.ageEstimate) || other.ageEstimate == _this.ageEstimate)&&(identical(other.consciousness, _this.consciousness) || other.consciousness == _this.consciousness)&&(identical(other.isBreathing, _this.isBreathing) || other.isBreathing == _this.isBreathing)&&(identical(other.conditionNote, _this.conditionNote) || other.conditionNote == _this.conditionNote)&&(identical(other.handedOverTo, _this.handedOverTo) || other.handedOverTo == _this.handedOverTo)&&(identical(other.handedOverAt, _this.handedOverAt) || other.handedOverAt == _this.handedOverAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportPatient;
  return Object.hash(runtimeType,_this.id,_this.name,_this.gender,_this.ageEstimate,_this.consciousness,_this.isBreathing,_this.conditionNote,_this.handedOverTo,_this.handedOverAt);
}

@override
String toString() {
  final _this = this as ReportPatient;
  return 'ReportPatient(id: ${_this.id}, name: ${_this.name}, gender: ${_this.gender}, ageEstimate: ${_this.ageEstimate}, consciousness: ${_this.consciousness}, isBreathing: ${_this.isBreathing}, conditionNote: ${_this.conditionNote}, handedOverTo: ${_this.handedOverTo}, handedOverAt: ${_this.handedOverAt})';
}


}

/// @nodoc
abstract mixin class $ReportPatientCopyWith<$Res>  {
  factory $ReportPatientCopyWith(ReportPatient value, $Res Function(ReportPatient) _then) = _$ReportPatientCopyWithImpl;
@useResult
$Res call({
 int id, String? name, String? gender, int? ageEstimate, LabeledValue? consciousness, bool? isBreathing, String? conditionNote, String? handedOverTo, DateTime? handedOverAt
});


$LabeledValueCopyWith<$Res>? get consciousness;

}
/// @nodoc
class _$ReportPatientCopyWithImpl<$Res>
    implements $ReportPatientCopyWith<$Res> {
  _$ReportPatientCopyWithImpl(this._self, this._then);

  final ReportPatient _self;
  final $Res Function(ReportPatient) _then;

/// Create a copy of ReportPatient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? gender = freezed,Object? ageEstimate = freezed,Object? consciousness = freezed,Object? isBreathing = freezed,Object? conditionNote = freezed,Object? handedOverTo = freezed,Object? handedOverAt = freezed,}) {
  return _then(ReportPatient(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,ageEstimate: freezed == ageEstimate ? _self.ageEstimate : ageEstimate // ignore: cast_nullable_to_non_nullable
as int?,consciousness: freezed == consciousness ? _self.consciousness : consciousness // ignore: cast_nullable_to_non_nullable
as LabeledValue?,isBreathing: freezed == isBreathing ? _self.isBreathing : isBreathing // ignore: cast_nullable_to_non_nullable
as bool?,conditionNote: freezed == conditionNote ? _self.conditionNote : conditionNote // ignore: cast_nullable_to_non_nullable
as String?,handedOverTo: freezed == handedOverTo ? _self.handedOverTo : handedOverTo // ignore: cast_nullable_to_non_nullable
as String?,handedOverAt: freezed == handedOverAt ? _self.handedOverAt : handedOverAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ReportPatient
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get consciousness {
    if (_self.consciousness == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.consciousness!, (value) {
    return _then(_self.copyWith(consciousness: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReportPatient].
extension ReportPatientPatterns on ReportPatient {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportPatient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportPatient() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportPatient value)  $default,){
final _that = this;
switch (_that) {
case _ReportPatient():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportPatient value)?  $default,){
final _that = this;
switch (_that) {
case _ReportPatient() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? name,  String? gender,  int? ageEstimate,  LabeledValue? consciousness,  bool? isBreathing,  String? conditionNote,  String? handedOverTo,  DateTime? handedOverAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportPatient() when $default != null:
return $default(_that.id,_that.name,_that.gender,_that.ageEstimate,_that.consciousness,_that.isBreathing,_that.conditionNote,_that.handedOverTo,_that.handedOverAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? name,  String? gender,  int? ageEstimate,  LabeledValue? consciousness,  bool? isBreathing,  String? conditionNote,  String? handedOverTo,  DateTime? handedOverAt)  $default,) {final _that = this;
switch (_that) {
case _ReportPatient():
return $default(_that.id,_that.name,_that.gender,_that.ageEstimate,_that.consciousness,_that.isBreathing,_that.conditionNote,_that.handedOverTo,_that.handedOverAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? name,  String? gender,  int? ageEstimate,  LabeledValue? consciousness,  bool? isBreathing,  String? conditionNote,  String? handedOverTo,  DateTime? handedOverAt)?  $default,) {final _that = this;
switch (_that) {
case _ReportPatient() when $default != null:
return $default(_that.id,_that.name,_that.gender,_that.ageEstimate,_that.consciousness,_that.isBreathing,_that.conditionNote,_that.handedOverTo,_that.handedOverAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportPatient implements ReportPatient {
  const _ReportPatient({required this.id, this.name, this.gender, this.ageEstimate, this.consciousness, this.isBreathing, this.conditionNote, this.handedOverTo, this.handedOverAt});
  factory _ReportPatient.fromJson(Map<String, dynamic> json) => _$ReportPatientFromJson(json);

@override final  int id;
@override final  String? name;
@override final  String? gender;
@override final  int? ageEstimate;
@override final  LabeledValue? consciousness;
@override final  bool? isBreathing;
@override final  String? conditionNote;
@override final  String? handedOverTo;
@override final  DateTime? handedOverAt;

/// Create a copy of ReportPatient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportPatientCopyWith<_ReportPatient> get copyWith => __$ReportPatientCopyWithImpl<_ReportPatient>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportPatientToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportPatient&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.ageEstimate, ageEstimate) || other.ageEstimate == ageEstimate)&&(identical(other.consciousness, consciousness) || other.consciousness == consciousness)&&(identical(other.isBreathing, isBreathing) || other.isBreathing == isBreathing)&&(identical(other.conditionNote, conditionNote) || other.conditionNote == conditionNote)&&(identical(other.handedOverTo, handedOverTo) || other.handedOverTo == handedOverTo)&&(identical(other.handedOverAt, handedOverAt) || other.handedOverAt == handedOverAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,gender,ageEstimate,consciousness,isBreathing,conditionNote,handedOverTo,handedOverAt);
}

@override
String toString() {
    return 'ReportPatient(id: $id, name: $name, gender: $gender, ageEstimate: $ageEstimate, consciousness: $consciousness, isBreathing: $isBreathing, conditionNote: $conditionNote, handedOverTo: $handedOverTo, handedOverAt: $handedOverAt)';
}


}

/// @nodoc
abstract mixin class _$ReportPatientCopyWith<$Res> implements $ReportPatientCopyWith<$Res> {
  factory _$ReportPatientCopyWith(_ReportPatient value, $Res Function(_ReportPatient) _then) = __$ReportPatientCopyWithImpl;
@override @useResult
$Res call({
 int id, String? name, String? gender, int? ageEstimate, LabeledValue? consciousness, bool? isBreathing, String? conditionNote, String? handedOverTo, DateTime? handedOverAt
});


@override $LabeledValueCopyWith<$Res>? get consciousness;

}
/// @nodoc
class __$ReportPatientCopyWithImpl<$Res>
    implements _$ReportPatientCopyWith<$Res> {
  __$ReportPatientCopyWithImpl(this._self, this._then);

  final _ReportPatient _self;
  final $Res Function(_ReportPatient) _then;

/// Create a copy of ReportPatient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? gender = freezed,Object? ageEstimate = freezed,Object? consciousness = freezed,Object? isBreathing = freezed,Object? conditionNote = freezed,Object? handedOverTo = freezed,Object? handedOverAt = freezed,}) {
  return _then(_ReportPatient(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,ageEstimate: freezed == ageEstimate ? _self.ageEstimate : ageEstimate // ignore: cast_nullable_to_non_nullable
as int?,consciousness: freezed == consciousness ? _self.consciousness : consciousness // ignore: cast_nullable_to_non_nullable
as LabeledValue?,isBreathing: freezed == isBreathing ? _self.isBreathing : isBreathing // ignore: cast_nullable_to_non_nullable
as bool?,conditionNote: freezed == conditionNote ? _self.conditionNote : conditionNote // ignore: cast_nullable_to_non_nullable
as String?,handedOverTo: freezed == handedOverTo ? _self.handedOverTo : handedOverTo // ignore: cast_nullable_to_non_nullable
as String?,handedOverAt: freezed == handedOverAt ? _self.handedOverAt : handedOverAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ReportPatient
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get consciousness {
    if (_self.consciousness == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.consciousness!, (value) {
    return _then(_self.copyWith(consciousness: value));
  });
}
}


/// @nodoc
mixin _$ReportAttachment {

 int get id; LabeledValue get type; String? get mimeType; bool get isImage; int? get sizeKb; String get url; DateTime? get createdAt;
/// Create a copy of ReportAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportAttachmentCopyWith<ReportAttachment> get copyWith => _$ReportAttachmentCopyWithImpl<ReportAttachment>(this as ReportAttachment, _$identity);

  /// Serializes this ReportAttachment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportAttachment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportAttachment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.mimeType, _this.mimeType) || other.mimeType == _this.mimeType)&&(identical(other.isImage, _this.isImage) || other.isImage == _this.isImage)&&(identical(other.sizeKb, _this.sizeKb) || other.sizeKb == _this.sizeKb)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportAttachment;
  return Object.hash(runtimeType,_this.id,_this.type,_this.mimeType,_this.isImage,_this.sizeKb,_this.url,_this.createdAt);
}

@override
String toString() {
  final _this = this as ReportAttachment;
  return 'ReportAttachment(id: ${_this.id}, type: ${_this.type}, mimeType: ${_this.mimeType}, isImage: ${_this.isImage}, sizeKb: ${_this.sizeKb}, url: ${_this.url}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ReportAttachmentCopyWith<$Res>  {
  factory $ReportAttachmentCopyWith(ReportAttachment value, $Res Function(ReportAttachment) _then) = _$ReportAttachmentCopyWithImpl;
@useResult
$Res call({
 int id, LabeledValue type, String? mimeType, bool isImage, int? sizeKb, String url, DateTime? createdAt
});


$LabeledValueCopyWith<$Res> get type;

}
/// @nodoc
class _$ReportAttachmentCopyWithImpl<$Res>
    implements $ReportAttachmentCopyWith<$Res> {
  _$ReportAttachmentCopyWithImpl(this._self, this._then);

  final ReportAttachment _self;
  final $Res Function(ReportAttachment) _then;

/// Create a copy of ReportAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? mimeType = freezed,Object? isImage = null,Object? sizeKb = freezed,Object? url = null,Object? createdAt = freezed,}) {
  return _then(ReportAttachment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LabeledValue,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,isImage: null == isImage ? _self.isImage : isImage // ignore: cast_nullable_to_non_nullable
as bool,sizeKb: freezed == sizeKb ? _self.sizeKb : sizeKb // ignore: cast_nullable_to_non_nullable
as int?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ReportAttachment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res> get type {
  
  return $LabeledValueCopyWith<$Res>(_self.type, (value) {
    return _then(_self.copyWith(type: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReportAttachment].
extension ReportAttachmentPatterns on ReportAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportAttachment value)  $default,){
final _that = this;
switch (_that) {
case _ReportAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _ReportAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  LabeledValue type,  String? mimeType,  bool isImage,  int? sizeKb,  String url,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportAttachment() when $default != null:
return $default(_that.id,_that.type,_that.mimeType,_that.isImage,_that.sizeKb,_that.url,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  LabeledValue type,  String? mimeType,  bool isImage,  int? sizeKb,  String url,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ReportAttachment():
return $default(_that.id,_that.type,_that.mimeType,_that.isImage,_that.sizeKb,_that.url,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  LabeledValue type,  String? mimeType,  bool isImage,  int? sizeKb,  String url,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ReportAttachment() when $default != null:
return $default(_that.id,_that.type,_that.mimeType,_that.isImage,_that.sizeKb,_that.url,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportAttachment implements ReportAttachment {
  const _ReportAttachment({required this.id, required this.type, this.mimeType, this.isImage = true, this.sizeKb, required this.url, this.createdAt});
  factory _ReportAttachment.fromJson(Map<String, dynamic> json) => _$ReportAttachmentFromJson(json);

@override final  int id;
@override final  LabeledValue type;
@override final  String? mimeType;
@override@JsonKey() final  bool isImage;
@override final  int? sizeKb;
@override final  String url;
@override final  DateTime? createdAt;

/// Create a copy of ReportAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportAttachmentCopyWith<_ReportAttachment> get copyWith => __$ReportAttachmentCopyWithImpl<_ReportAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.isImage, isImage) || other.isImage == isImage)&&(identical(other.sizeKb, sizeKb) || other.sizeKb == sizeKb)&&(identical(other.url, url) || other.url == url)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,mimeType,isImage,sizeKb,url,createdAt);
}

@override
String toString() {
    return 'ReportAttachment(id: $id, type: $type, mimeType: $mimeType, isImage: $isImage, sizeKb: $sizeKb, url: $url, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReportAttachmentCopyWith<$Res> implements $ReportAttachmentCopyWith<$Res> {
  factory _$ReportAttachmentCopyWith(_ReportAttachment value, $Res Function(_ReportAttachment) _then) = __$ReportAttachmentCopyWithImpl;
@override @useResult
$Res call({
 int id, LabeledValue type, String? mimeType, bool isImage, int? sizeKb, String url, DateTime? createdAt
});


@override $LabeledValueCopyWith<$Res> get type;

}
/// @nodoc
class __$ReportAttachmentCopyWithImpl<$Res>
    implements _$ReportAttachmentCopyWith<$Res> {
  __$ReportAttachmentCopyWithImpl(this._self, this._then);

  final _ReportAttachment _self;
  final $Res Function(_ReportAttachment) _then;

/// Create a copy of ReportAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? mimeType = freezed,Object? isImage = null,Object? sizeKb = freezed,Object? url = null,Object? createdAt = freezed,}) {
  return _then(_ReportAttachment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LabeledValue,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,isImage: null == isImage ? _self.isImage : isImage // ignore: cast_nullable_to_non_nullable
as bool,sizeKb: freezed == sizeKb ? _self.sizeKb : sizeKb // ignore: cast_nullable_to_non_nullable
as int?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ReportAttachment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res> get type {
  
  return $LabeledValueCopyWith<$Res>(_self.type, (value) {
    return _then(_self.copyWith(type: value));
  });
}
}


/// @nodoc
mixin _$ReportStatusLog {

 int get id; LabeledValue? get fromStatus; LabeledValue get toStatus; String? get note; DateTime? get createdAt;
/// Create a copy of ReportStatusLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportStatusLogCopyWith<ReportStatusLog> get copyWith => _$ReportStatusLogCopyWithImpl<ReportStatusLog>(this as ReportStatusLog, _$identity);

  /// Serializes this ReportStatusLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportStatusLog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportStatusLog&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fromStatus, _this.fromStatus) || other.fromStatus == _this.fromStatus)&&(identical(other.toStatus, _this.toStatus) || other.toStatus == _this.toStatus)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportStatusLog;
  return Object.hash(runtimeType,_this.id,_this.fromStatus,_this.toStatus,_this.note,_this.createdAt);
}

@override
String toString() {
  final _this = this as ReportStatusLog;
  return 'ReportStatusLog(id: ${_this.id}, fromStatus: ${_this.fromStatus}, toStatus: ${_this.toStatus}, note: ${_this.note}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ReportStatusLogCopyWith<$Res>  {
  factory $ReportStatusLogCopyWith(ReportStatusLog value, $Res Function(ReportStatusLog) _then) = _$ReportStatusLogCopyWithImpl;
@useResult
$Res call({
 int id, LabeledValue? fromStatus, LabeledValue toStatus, String? note, DateTime? createdAt
});


$LabeledValueCopyWith<$Res>? get fromStatus;$LabeledValueCopyWith<$Res> get toStatus;

}
/// @nodoc
class _$ReportStatusLogCopyWithImpl<$Res>
    implements $ReportStatusLogCopyWith<$Res> {
  _$ReportStatusLogCopyWithImpl(this._self, this._then);

  final ReportStatusLog _self;
  final $Res Function(ReportStatusLog) _then;

/// Create a copy of ReportStatusLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromStatus = freezed,Object? toStatus = null,Object? note = freezed,Object? createdAt = freezed,}) {
  return _then(ReportStatusLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fromStatus: freezed == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as LabeledValue?,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as LabeledValue,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ReportStatusLog
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get fromStatus {
    if (_self.fromStatus == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.fromStatus!, (value) {
    return _then(_self.copyWith(fromStatus: value));
  });
}/// Create a copy of ReportStatusLog
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res> get toStatus {
  
  return $LabeledValueCopyWith<$Res>(_self.toStatus, (value) {
    return _then(_self.copyWith(toStatus: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReportStatusLog].
extension ReportStatusLogPatterns on ReportStatusLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportStatusLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportStatusLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportStatusLog value)  $default,){
final _that = this;
switch (_that) {
case _ReportStatusLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportStatusLog value)?  $default,){
final _that = this;
switch (_that) {
case _ReportStatusLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  LabeledValue? fromStatus,  LabeledValue toStatus,  String? note,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportStatusLog() when $default != null:
return $default(_that.id,_that.fromStatus,_that.toStatus,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  LabeledValue? fromStatus,  LabeledValue toStatus,  String? note,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ReportStatusLog():
return $default(_that.id,_that.fromStatus,_that.toStatus,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  LabeledValue? fromStatus,  LabeledValue toStatus,  String? note,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ReportStatusLog() when $default != null:
return $default(_that.id,_that.fromStatus,_that.toStatus,_that.note,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportStatusLog implements ReportStatusLog {
  const _ReportStatusLog({required this.id, this.fromStatus, required this.toStatus, this.note, this.createdAt});
  factory _ReportStatusLog.fromJson(Map<String, dynamic> json) => _$ReportStatusLogFromJson(json);

@override final  int id;
@override final  LabeledValue? fromStatus;
@override final  LabeledValue toStatus;
@override final  String? note;
@override final  DateTime? createdAt;

/// Create a copy of ReportStatusLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportStatusLogCopyWith<_ReportStatusLog> get copyWith => __$ReportStatusLogCopyWithImpl<_ReportStatusLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportStatusLogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportStatusLog&&(identical(other.id, id) || other.id == id)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fromStatus,toStatus,note,createdAt);
}

@override
String toString() {
    return 'ReportStatusLog(id: $id, fromStatus: $fromStatus, toStatus: $toStatus, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReportStatusLogCopyWith<$Res> implements $ReportStatusLogCopyWith<$Res> {
  factory _$ReportStatusLogCopyWith(_ReportStatusLog value, $Res Function(_ReportStatusLog) _then) = __$ReportStatusLogCopyWithImpl;
@override @useResult
$Res call({
 int id, LabeledValue? fromStatus, LabeledValue toStatus, String? note, DateTime? createdAt
});


@override $LabeledValueCopyWith<$Res>? get fromStatus;@override $LabeledValueCopyWith<$Res> get toStatus;

}
/// @nodoc
class __$ReportStatusLogCopyWithImpl<$Res>
    implements _$ReportStatusLogCopyWith<$Res> {
  __$ReportStatusLogCopyWithImpl(this._self, this._then);

  final _ReportStatusLog _self;
  final $Res Function(_ReportStatusLog) _then;

/// Create a copy of ReportStatusLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromStatus = freezed,Object? toStatus = null,Object? note = freezed,Object? createdAt = freezed,}) {
  return _then(_ReportStatusLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fromStatus: freezed == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as LabeledValue?,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as LabeledValue,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ReportStatusLog
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get fromStatus {
    if (_self.fromStatus == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.fromStatus!, (value) {
    return _then(_self.copyWith(fromStatus: value));
  });
}/// Create a copy of ReportStatusLog
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res> get toStatus {
  
  return $LabeledValueCopyWith<$Res>(_self.toStatus, (value) {
    return _then(_self.copyWith(toStatus: value));
  });
}
}

ReportDetails _$ReportDetailsFromJson(
  Map<String, dynamic> json
) {
        switch (json['kind']) {
                  case 'kecelakaan':
          return AccidentDetails.fromJson(
            json
          );
                case 'medis':
          return MedicalDetails.fromJson(
            json
          );
                case 'ibu_hamil':
          return MaternityDetails.fromJson(
            json
          );
                case 'jenazah':
          return FuneralDetails.fromJson(
            json
          );
        
          default:
            return UnknownDetails.fromJson(
  json
);
        }
      
}

/// @nodoc
mixin _$ReportDetails {



  /// Serializes this ReportDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportDetails);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ReportDetails()';
}


}

/// @nodoc
class $ReportDetailsCopyWith<$Res>  {
$ReportDetailsCopyWith(ReportDetails _, $Res Function(ReportDetails) __);
}


/// Adds pattern-matching-related methods to [ReportDetails].
extension ReportDetailsPatterns on ReportDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AccidentDetails value)?  accident,TResult Function( MedicalDetails value)?  medical,TResult Function( MaternityDetails value)?  maternity,TResult Function( FuneralDetails value)?  funeral,TResult Function( UnknownDetails value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AccidentDetails() when accident != null:
return accident(_that);case MedicalDetails() when medical != null:
return medical(_that);case MaternityDetails() when maternity != null:
return maternity(_that);case FuneralDetails() when funeral != null:
return funeral(_that);case UnknownDetails() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AccidentDetails value)  accident,required TResult Function( MedicalDetails value)  medical,required TResult Function( MaternityDetails value)  maternity,required TResult Function( FuneralDetails value)  funeral,required TResult Function( UnknownDetails value)  unknown,}){
final _that = this;
switch (_that) {
case AccidentDetails():
return accident(_that);case MedicalDetails():
return medical(_that);case MaternityDetails():
return maternity(_that);case FuneralDetails():
return funeral(_that);case UnknownDetails():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AccidentDetails value)?  accident,TResult? Function( MedicalDetails value)?  medical,TResult? Function( MaternityDetails value)?  maternity,TResult? Function( FuneralDetails value)?  funeral,TResult? Function( UnknownDetails value)?  unknown,}){
final _that = this;
switch (_that) {
case AccidentDetails() when accident != null:
return accident(_that);case MedicalDetails() when medical != null:
return medical(_that);case MaternityDetails() when maternity != null:
return maternity(_that);case FuneralDetails() when funeral != null:
return funeral(_that);case UnknownDetails() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( LabeledValue? accidentType,  int? estimatedVictimCount,  bool? hasTrappedVictim,  bool? hasFireHazard,  bool? isRoadBlocked)?  accident,TResult Function( LabeledValue? medicalCategory,  DateTime? symptomOnsetAt,  bool? hasMedicalHistory,  String? medicalHistoryNotes)?  medical,TResult Function( int? gestationalAgeWeeks,  int? contractionIntervalMinutes,  bool? isWaterBroken,  bool? hasBleeding,  int? pregnancyNumber,  ReportDetailClinic? destinationClinic)?  maternity,TResult Function( String? deceasedName,  LabeledValue? pickupPlaceType,  DateTime? scheduledPickupAt,  bool? hasDeathCertificate,  String? familyContactName,  String? familyContactPhone)?  funeral,TResult Function()?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AccidentDetails() when accident != null:
return accident(_that.accidentType,_that.estimatedVictimCount,_that.hasTrappedVictim,_that.hasFireHazard,_that.isRoadBlocked);case MedicalDetails() when medical != null:
return medical(_that.medicalCategory,_that.symptomOnsetAt,_that.hasMedicalHistory,_that.medicalHistoryNotes);case MaternityDetails() when maternity != null:
return maternity(_that.gestationalAgeWeeks,_that.contractionIntervalMinutes,_that.isWaterBroken,_that.hasBleeding,_that.pregnancyNumber,_that.destinationClinic);case FuneralDetails() when funeral != null:
return funeral(_that.deceasedName,_that.pickupPlaceType,_that.scheduledPickupAt,_that.hasDeathCertificate,_that.familyContactName,_that.familyContactPhone);case UnknownDetails() when unknown != null:
return unknown();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( LabeledValue? accidentType,  int? estimatedVictimCount,  bool? hasTrappedVictim,  bool? hasFireHazard,  bool? isRoadBlocked)  accident,required TResult Function( LabeledValue? medicalCategory,  DateTime? symptomOnsetAt,  bool? hasMedicalHistory,  String? medicalHistoryNotes)  medical,required TResult Function( int? gestationalAgeWeeks,  int? contractionIntervalMinutes,  bool? isWaterBroken,  bool? hasBleeding,  int? pregnancyNumber,  ReportDetailClinic? destinationClinic)  maternity,required TResult Function( String? deceasedName,  LabeledValue? pickupPlaceType,  DateTime? scheduledPickupAt,  bool? hasDeathCertificate,  String? familyContactName,  String? familyContactPhone)  funeral,required TResult Function()  unknown,}) {final _that = this;
switch (_that) {
case AccidentDetails():
return accident(_that.accidentType,_that.estimatedVictimCount,_that.hasTrappedVictim,_that.hasFireHazard,_that.isRoadBlocked);case MedicalDetails():
return medical(_that.medicalCategory,_that.symptomOnsetAt,_that.hasMedicalHistory,_that.medicalHistoryNotes);case MaternityDetails():
return maternity(_that.gestationalAgeWeeks,_that.contractionIntervalMinutes,_that.isWaterBroken,_that.hasBleeding,_that.pregnancyNumber,_that.destinationClinic);case FuneralDetails():
return funeral(_that.deceasedName,_that.pickupPlaceType,_that.scheduledPickupAt,_that.hasDeathCertificate,_that.familyContactName,_that.familyContactPhone);case UnknownDetails():
return unknown();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( LabeledValue? accidentType,  int? estimatedVictimCount,  bool? hasTrappedVictim,  bool? hasFireHazard,  bool? isRoadBlocked)?  accident,TResult? Function( LabeledValue? medicalCategory,  DateTime? symptomOnsetAt,  bool? hasMedicalHistory,  String? medicalHistoryNotes)?  medical,TResult? Function( int? gestationalAgeWeeks,  int? contractionIntervalMinutes,  bool? isWaterBroken,  bool? hasBleeding,  int? pregnancyNumber,  ReportDetailClinic? destinationClinic)?  maternity,TResult? Function( String? deceasedName,  LabeledValue? pickupPlaceType,  DateTime? scheduledPickupAt,  bool? hasDeathCertificate,  String? familyContactName,  String? familyContactPhone)?  funeral,TResult? Function()?  unknown,}) {final _that = this;
switch (_that) {
case AccidentDetails() when accident != null:
return accident(_that.accidentType,_that.estimatedVictimCount,_that.hasTrappedVictim,_that.hasFireHazard,_that.isRoadBlocked);case MedicalDetails() when medical != null:
return medical(_that.medicalCategory,_that.symptomOnsetAt,_that.hasMedicalHistory,_that.medicalHistoryNotes);case MaternityDetails() when maternity != null:
return maternity(_that.gestationalAgeWeeks,_that.contractionIntervalMinutes,_that.isWaterBroken,_that.hasBleeding,_that.pregnancyNumber,_that.destinationClinic);case FuneralDetails() when funeral != null:
return funeral(_that.deceasedName,_that.pickupPlaceType,_that.scheduledPickupAt,_that.hasDeathCertificate,_that.familyContactName,_that.familyContactPhone);case UnknownDetails() when unknown != null:
return unknown();case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class AccidentDetails implements ReportDetails {
  const AccidentDetails({this.accidentType, this.estimatedVictimCount, this.hasTrappedVictim, this.hasFireHazard, this.isRoadBlocked,  String? $type}): $type = $type ?? 'kecelakaan';
  factory AccidentDetails.fromJson(Map<String, dynamic> json) => _$AccidentDetailsFromJson(json);

 final  LabeledValue? accidentType;
 final  int? estimatedVictimCount;
 final  bool? hasTrappedVictim;
 final  bool? hasFireHazard;
 final  bool? isRoadBlocked;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ReportDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccidentDetailsCopyWith<AccidentDetails> get copyWith => _$AccidentDetailsCopyWithImpl<AccidentDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccidentDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AccidentDetails&&(identical(other.accidentType, accidentType) || other.accidentType == accidentType)&&(identical(other.estimatedVictimCount, estimatedVictimCount) || other.estimatedVictimCount == estimatedVictimCount)&&(identical(other.hasTrappedVictim, hasTrappedVictim) || other.hasTrappedVictim == hasTrappedVictim)&&(identical(other.hasFireHazard, hasFireHazard) || other.hasFireHazard == hasFireHazard)&&(identical(other.isRoadBlocked, isRoadBlocked) || other.isRoadBlocked == isRoadBlocked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,accidentType,estimatedVictimCount,hasTrappedVictim,hasFireHazard,isRoadBlocked);
}

@override
String toString() {
    return 'ReportDetails.accident(accidentType: $accidentType, estimatedVictimCount: $estimatedVictimCount, hasTrappedVictim: $hasTrappedVictim, hasFireHazard: $hasFireHazard, isRoadBlocked: $isRoadBlocked)';
}


}

/// @nodoc
abstract mixin class $AccidentDetailsCopyWith<$Res> implements $ReportDetailsCopyWith<$Res> {
  factory $AccidentDetailsCopyWith(AccidentDetails value, $Res Function(AccidentDetails) _then) = _$AccidentDetailsCopyWithImpl;
@useResult
$Res call({
 LabeledValue? accidentType, int? estimatedVictimCount, bool? hasTrappedVictim, bool? hasFireHazard, bool? isRoadBlocked
});


$LabeledValueCopyWith<$Res>? get accidentType;

}
/// @nodoc
class _$AccidentDetailsCopyWithImpl<$Res>
    implements $AccidentDetailsCopyWith<$Res> {
  _$AccidentDetailsCopyWithImpl(this._self, this._then);

  final AccidentDetails _self;
  final $Res Function(AccidentDetails) _then;

/// Create a copy of ReportDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? accidentType = freezed,Object? estimatedVictimCount = freezed,Object? hasTrappedVictim = freezed,Object? hasFireHazard = freezed,Object? isRoadBlocked = freezed,}) {
  return _then(AccidentDetails(
accidentType: freezed == accidentType ? _self.accidentType : accidentType // ignore: cast_nullable_to_non_nullable
as LabeledValue?,estimatedVictimCount: freezed == estimatedVictimCount ? _self.estimatedVictimCount : estimatedVictimCount // ignore: cast_nullable_to_non_nullable
as int?,hasTrappedVictim: freezed == hasTrappedVictim ? _self.hasTrappedVictim : hasTrappedVictim // ignore: cast_nullable_to_non_nullable
as bool?,hasFireHazard: freezed == hasFireHazard ? _self.hasFireHazard : hasFireHazard // ignore: cast_nullable_to_non_nullable
as bool?,isRoadBlocked: freezed == isRoadBlocked ? _self.isRoadBlocked : isRoadBlocked // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of ReportDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get accidentType {
    if (_self.accidentType == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.accidentType!, (value) {
    return _then(_self.copyWith(accidentType: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class MedicalDetails implements ReportDetails {
  const MedicalDetails({this.medicalCategory, this.symptomOnsetAt, this.hasMedicalHistory, this.medicalHistoryNotes,  String? $type}): $type = $type ?? 'medis';
  factory MedicalDetails.fromJson(Map<String, dynamic> json) => _$MedicalDetailsFromJson(json);

 final  LabeledValue? medicalCategory;
 final  DateTime? symptomOnsetAt;
 final  bool? hasMedicalHistory;
 final  String? medicalHistoryNotes;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ReportDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicalDetailsCopyWith<MedicalDetails> get copyWith => _$MedicalDetailsCopyWithImpl<MedicalDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MedicalDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicalDetails&&(identical(other.medicalCategory, medicalCategory) || other.medicalCategory == medicalCategory)&&(identical(other.symptomOnsetAt, symptomOnsetAt) || other.symptomOnsetAt == symptomOnsetAt)&&(identical(other.hasMedicalHistory, hasMedicalHistory) || other.hasMedicalHistory == hasMedicalHistory)&&(identical(other.medicalHistoryNotes, medicalHistoryNotes) || other.medicalHistoryNotes == medicalHistoryNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,medicalCategory,symptomOnsetAt,hasMedicalHistory,medicalHistoryNotes);
}

@override
String toString() {
    return 'ReportDetails.medical(medicalCategory: $medicalCategory, symptomOnsetAt: $symptomOnsetAt, hasMedicalHistory: $hasMedicalHistory, medicalHistoryNotes: $medicalHistoryNotes)';
}


}

/// @nodoc
abstract mixin class $MedicalDetailsCopyWith<$Res> implements $ReportDetailsCopyWith<$Res> {
  factory $MedicalDetailsCopyWith(MedicalDetails value, $Res Function(MedicalDetails) _then) = _$MedicalDetailsCopyWithImpl;
@useResult
$Res call({
 LabeledValue? medicalCategory, DateTime? symptomOnsetAt, bool? hasMedicalHistory, String? medicalHistoryNotes
});


$LabeledValueCopyWith<$Res>? get medicalCategory;

}
/// @nodoc
class _$MedicalDetailsCopyWithImpl<$Res>
    implements $MedicalDetailsCopyWith<$Res> {
  _$MedicalDetailsCopyWithImpl(this._self, this._then);

  final MedicalDetails _self;
  final $Res Function(MedicalDetails) _then;

/// Create a copy of ReportDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? medicalCategory = freezed,Object? symptomOnsetAt = freezed,Object? hasMedicalHistory = freezed,Object? medicalHistoryNotes = freezed,}) {
  return _then(MedicalDetails(
medicalCategory: freezed == medicalCategory ? _self.medicalCategory : medicalCategory // ignore: cast_nullable_to_non_nullable
as LabeledValue?,symptomOnsetAt: freezed == symptomOnsetAt ? _self.symptomOnsetAt : symptomOnsetAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hasMedicalHistory: freezed == hasMedicalHistory ? _self.hasMedicalHistory : hasMedicalHistory // ignore: cast_nullable_to_non_nullable
as bool?,medicalHistoryNotes: freezed == medicalHistoryNotes ? _self.medicalHistoryNotes : medicalHistoryNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ReportDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get medicalCategory {
    if (_self.medicalCategory == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.medicalCategory!, (value) {
    return _then(_self.copyWith(medicalCategory: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class MaternityDetails implements ReportDetails {
  const MaternityDetails({this.gestationalAgeWeeks, this.contractionIntervalMinutes, this.isWaterBroken, this.hasBleeding, this.pregnancyNumber, this.destinationClinic,  String? $type}): $type = $type ?? 'ibu_hamil';
  factory MaternityDetails.fromJson(Map<String, dynamic> json) => _$MaternityDetailsFromJson(json);

 final  int? gestationalAgeWeeks;
 final  int? contractionIntervalMinutes;
 final  bool? isWaterBroken;
 final  bool? hasBleeding;
 final  int? pregnancyNumber;
 final  ReportDetailClinic? destinationClinic;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ReportDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaternityDetailsCopyWith<MaternityDetails> get copyWith => _$MaternityDetailsCopyWithImpl<MaternityDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaternityDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MaternityDetails&&(identical(other.gestationalAgeWeeks, gestationalAgeWeeks) || other.gestationalAgeWeeks == gestationalAgeWeeks)&&(identical(other.contractionIntervalMinutes, contractionIntervalMinutes) || other.contractionIntervalMinutes == contractionIntervalMinutes)&&(identical(other.isWaterBroken, isWaterBroken) || other.isWaterBroken == isWaterBroken)&&(identical(other.hasBleeding, hasBleeding) || other.hasBleeding == hasBleeding)&&(identical(other.pregnancyNumber, pregnancyNumber) || other.pregnancyNumber == pregnancyNumber)&&(identical(other.destinationClinic, destinationClinic) || other.destinationClinic == destinationClinic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,gestationalAgeWeeks,contractionIntervalMinutes,isWaterBroken,hasBleeding,pregnancyNumber,destinationClinic);
}

@override
String toString() {
    return 'ReportDetails.maternity(gestationalAgeWeeks: $gestationalAgeWeeks, contractionIntervalMinutes: $contractionIntervalMinutes, isWaterBroken: $isWaterBroken, hasBleeding: $hasBleeding, pregnancyNumber: $pregnancyNumber, destinationClinic: $destinationClinic)';
}


}

/// @nodoc
abstract mixin class $MaternityDetailsCopyWith<$Res> implements $ReportDetailsCopyWith<$Res> {
  factory $MaternityDetailsCopyWith(MaternityDetails value, $Res Function(MaternityDetails) _then) = _$MaternityDetailsCopyWithImpl;
@useResult
$Res call({
 int? gestationalAgeWeeks, int? contractionIntervalMinutes, bool? isWaterBroken, bool? hasBleeding, int? pregnancyNumber, ReportDetailClinic? destinationClinic
});


$ReportDetailClinicCopyWith<$Res>? get destinationClinic;

}
/// @nodoc
class _$MaternityDetailsCopyWithImpl<$Res>
    implements $MaternityDetailsCopyWith<$Res> {
  _$MaternityDetailsCopyWithImpl(this._self, this._then);

  final MaternityDetails _self;
  final $Res Function(MaternityDetails) _then;

/// Create a copy of ReportDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? gestationalAgeWeeks = freezed,Object? contractionIntervalMinutes = freezed,Object? isWaterBroken = freezed,Object? hasBleeding = freezed,Object? pregnancyNumber = freezed,Object? destinationClinic = freezed,}) {
  return _then(MaternityDetails(
gestationalAgeWeeks: freezed == gestationalAgeWeeks ? _self.gestationalAgeWeeks : gestationalAgeWeeks // ignore: cast_nullable_to_non_nullable
as int?,contractionIntervalMinutes: freezed == contractionIntervalMinutes ? _self.contractionIntervalMinutes : contractionIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int?,isWaterBroken: freezed == isWaterBroken ? _self.isWaterBroken : isWaterBroken // ignore: cast_nullable_to_non_nullable
as bool?,hasBleeding: freezed == hasBleeding ? _self.hasBleeding : hasBleeding // ignore: cast_nullable_to_non_nullable
as bool?,pregnancyNumber: freezed == pregnancyNumber ? _self.pregnancyNumber : pregnancyNumber // ignore: cast_nullable_to_non_nullable
as int?,destinationClinic: freezed == destinationClinic ? _self.destinationClinic : destinationClinic // ignore: cast_nullable_to_non_nullable
as ReportDetailClinic?,
  ));
}

/// Create a copy of ReportDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportDetailClinicCopyWith<$Res>? get destinationClinic {
    if (_self.destinationClinic == null) {
    return null;
  }

  return $ReportDetailClinicCopyWith<$Res>(_self.destinationClinic!, (value) {
    return _then(_self.copyWith(destinationClinic: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class FuneralDetails implements ReportDetails {
  const FuneralDetails({this.deceasedName, this.pickupPlaceType, this.scheduledPickupAt, this.hasDeathCertificate, this.familyContactName, this.familyContactPhone,  String? $type}): $type = $type ?? 'jenazah';
  factory FuneralDetails.fromJson(Map<String, dynamic> json) => _$FuneralDetailsFromJson(json);

 final  String? deceasedName;
 final  LabeledValue? pickupPlaceType;
 final  DateTime? scheduledPickupAt;
 final  bool? hasDeathCertificate;
 final  String? familyContactName;
 final  String? familyContactPhone;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ReportDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FuneralDetailsCopyWith<FuneralDetails> get copyWith => _$FuneralDetailsCopyWithImpl<FuneralDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FuneralDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FuneralDetails&&(identical(other.deceasedName, deceasedName) || other.deceasedName == deceasedName)&&(identical(other.pickupPlaceType, pickupPlaceType) || other.pickupPlaceType == pickupPlaceType)&&(identical(other.scheduledPickupAt, scheduledPickupAt) || other.scheduledPickupAt == scheduledPickupAt)&&(identical(other.hasDeathCertificate, hasDeathCertificate) || other.hasDeathCertificate == hasDeathCertificate)&&(identical(other.familyContactName, familyContactName) || other.familyContactName == familyContactName)&&(identical(other.familyContactPhone, familyContactPhone) || other.familyContactPhone == familyContactPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,deceasedName,pickupPlaceType,scheduledPickupAt,hasDeathCertificate,familyContactName,familyContactPhone);
}

@override
String toString() {
    return 'ReportDetails.funeral(deceasedName: $deceasedName, pickupPlaceType: $pickupPlaceType, scheduledPickupAt: $scheduledPickupAt, hasDeathCertificate: $hasDeathCertificate, familyContactName: $familyContactName, familyContactPhone: $familyContactPhone)';
}


}

/// @nodoc
abstract mixin class $FuneralDetailsCopyWith<$Res> implements $ReportDetailsCopyWith<$Res> {
  factory $FuneralDetailsCopyWith(FuneralDetails value, $Res Function(FuneralDetails) _then) = _$FuneralDetailsCopyWithImpl;
@useResult
$Res call({
 String? deceasedName, LabeledValue? pickupPlaceType, DateTime? scheduledPickupAt, bool? hasDeathCertificate, String? familyContactName, String? familyContactPhone
});


$LabeledValueCopyWith<$Res>? get pickupPlaceType;

}
/// @nodoc
class _$FuneralDetailsCopyWithImpl<$Res>
    implements $FuneralDetailsCopyWith<$Res> {
  _$FuneralDetailsCopyWithImpl(this._self, this._then);

  final FuneralDetails _self;
  final $Res Function(FuneralDetails) _then;

/// Create a copy of ReportDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? deceasedName = freezed,Object? pickupPlaceType = freezed,Object? scheduledPickupAt = freezed,Object? hasDeathCertificate = freezed,Object? familyContactName = freezed,Object? familyContactPhone = freezed,}) {
  return _then(FuneralDetails(
deceasedName: freezed == deceasedName ? _self.deceasedName : deceasedName // ignore: cast_nullable_to_non_nullable
as String?,pickupPlaceType: freezed == pickupPlaceType ? _self.pickupPlaceType : pickupPlaceType // ignore: cast_nullable_to_non_nullable
as LabeledValue?,scheduledPickupAt: freezed == scheduledPickupAt ? _self.scheduledPickupAt : scheduledPickupAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hasDeathCertificate: freezed == hasDeathCertificate ? _self.hasDeathCertificate : hasDeathCertificate // ignore: cast_nullable_to_non_nullable
as bool?,familyContactName: freezed == familyContactName ? _self.familyContactName : familyContactName // ignore: cast_nullable_to_non_nullable
as String?,familyContactPhone: freezed == familyContactPhone ? _self.familyContactPhone : familyContactPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ReportDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get pickupPlaceType {
    if (_self.pickupPlaceType == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.pickupPlaceType!, (value) {
    return _then(_self.copyWith(pickupPlaceType: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class UnknownDetails implements ReportDetails {
  const UnknownDetails({ String? $type}): $type = $type ?? 'unknown';
  factory UnknownDetails.fromJson(Map<String, dynamic> json) => _$UnknownDetailsFromJson(json);



@JsonKey(name: 'kind')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$UnknownDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownDetails);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ReportDetails.unknown()';
}


}





/// @nodoc
mixin _$ReportDetailClinic {

 int get id; String get name;
/// Create a copy of ReportDetailClinic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportDetailClinicCopyWith<ReportDetailClinic> get copyWith => _$ReportDetailClinicCopyWithImpl<ReportDetailClinic>(this as ReportDetailClinic, _$identity);

  /// Serializes this ReportDetailClinic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportDetailClinic;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportDetailClinic&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportDetailClinic;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as ReportDetailClinic;
  return 'ReportDetailClinic(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $ReportDetailClinicCopyWith<$Res>  {
  factory $ReportDetailClinicCopyWith(ReportDetailClinic value, $Res Function(ReportDetailClinic) _then) = _$ReportDetailClinicCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$ReportDetailClinicCopyWithImpl<$Res>
    implements $ReportDetailClinicCopyWith<$Res> {
  _$ReportDetailClinicCopyWithImpl(this._self, this._then);

  final ReportDetailClinic _self;
  final $Res Function(ReportDetailClinic) _then;

/// Create a copy of ReportDetailClinic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(ReportDetailClinic(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportDetailClinic].
extension ReportDetailClinicPatterns on ReportDetailClinic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportDetailClinic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportDetailClinic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportDetailClinic value)  $default,){
final _that = this;
switch (_that) {
case _ReportDetailClinic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportDetailClinic value)?  $default,){
final _that = this;
switch (_that) {
case _ReportDetailClinic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportDetailClinic() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name)  $default,) {final _that = this;
switch (_that) {
case _ReportDetailClinic():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _ReportDetailClinic() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportDetailClinic implements ReportDetailClinic {
  const _ReportDetailClinic({required this.id, required this.name});
  factory _ReportDetailClinic.fromJson(Map<String, dynamic> json) => _$ReportDetailClinicFromJson(json);

@override final  int id;
@override final  String name;

/// Create a copy of ReportDetailClinic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportDetailClinicCopyWith<_ReportDetailClinic> get copyWith => __$ReportDetailClinicCopyWithImpl<_ReportDetailClinic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportDetailClinicToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportDetailClinic&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'ReportDetailClinic(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ReportDetailClinicCopyWith<$Res> implements $ReportDetailClinicCopyWith<$Res> {
  factory _$ReportDetailClinicCopyWith(_ReportDetailClinic value, $Res Function(_ReportDetailClinic) _then) = __$ReportDetailClinicCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$ReportDetailClinicCopyWithImpl<$Res>
    implements _$ReportDetailClinicCopyWith<$Res> {
  __$ReportDetailClinicCopyWithImpl(this._self, this._then);

  final _ReportDetailClinic _self;
  final $Res Function(_ReportDetailClinic) _then;

/// Create a copy of ReportDetailClinic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_ReportDetailClinic(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Report {

 int get id; String get code; LabeledValue get status; ReportType? get reportType; String? get address; String? get shortAddress; double get latitude; double get longitude; ReportDestination? get destination; ReportDriver? get driver; ReportAmbulance? get ambulance; DateTime? get createdAt; DateTime? get takenAt; DateTime? get arrivedAt; DateTime? get completedAt; int? get responseTimeMinutes; int? get waitingMinutes; String? get description; ReportDetails? get details; List<ReportPatient> get patients; List<ReportAttachment> get attachments; List<ReportStatusLog> get timeline; bool get isTrackingAvailable;
/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportCopyWith<Report> get copyWith => _$ReportCopyWithImpl<Report>(this as Report, _$identity);

  /// Serializes this Report to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Report;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Report&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.reportType, _this.reportType) || other.reportType == _this.reportType)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.shortAddress, _this.shortAddress) || other.shortAddress == _this.shortAddress)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.destination, _this.destination) || other.destination == _this.destination)&&(identical(other.driver, _this.driver) || other.driver == _this.driver)&&(identical(other.ambulance, _this.ambulance) || other.ambulance == _this.ambulance)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.takenAt, _this.takenAt) || other.takenAt == _this.takenAt)&&(identical(other.arrivedAt, _this.arrivedAt) || other.arrivedAt == _this.arrivedAt)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.responseTimeMinutes, _this.responseTimeMinutes) || other.responseTimeMinutes == _this.responseTimeMinutes)&&(identical(other.waitingMinutes, _this.waitingMinutes) || other.waitingMinutes == _this.waitingMinutes)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.details, _this.details) || other.details == _this.details)&&const DeepCollectionEquality().equals(other.patients, _this.patients)&&const DeepCollectionEquality().equals(other.attachments, _this.attachments)&&const DeepCollectionEquality().equals(other.timeline, _this.timeline)&&(identical(other.isTrackingAvailable, _this.isTrackingAvailable) || other.isTrackingAvailable == _this.isTrackingAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Report;
  return Object.hashAll([runtimeType,_this.id,_this.code,_this.status,_this.reportType,_this.address,_this.shortAddress,_this.latitude,_this.longitude,_this.destination,_this.driver,_this.ambulance,_this.createdAt,_this.takenAt,_this.arrivedAt,_this.completedAt,_this.responseTimeMinutes,_this.waitingMinutes,_this.description,_this.details,const DeepCollectionEquality().hash(_this.patients),const DeepCollectionEquality().hash(_this.attachments),const DeepCollectionEquality().hash(_this.timeline),_this.isTrackingAvailable]);
}

@override
String toString() {
  final _this = this as Report;
  return 'Report(id: ${_this.id}, code: ${_this.code}, status: ${_this.status}, reportType: ${_this.reportType}, address: ${_this.address}, shortAddress: ${_this.shortAddress}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, destination: ${_this.destination}, driver: ${_this.driver}, ambulance: ${_this.ambulance}, createdAt: ${_this.createdAt}, takenAt: ${_this.takenAt}, arrivedAt: ${_this.arrivedAt}, completedAt: ${_this.completedAt}, responseTimeMinutes: ${_this.responseTimeMinutes}, waitingMinutes: ${_this.waitingMinutes}, description: ${_this.description}, details: ${_this.details}, patients: ${_this.patients}, attachments: ${_this.attachments}, timeline: ${_this.timeline}, isTrackingAvailable: ${_this.isTrackingAvailable})';
}


}

/// @nodoc
abstract mixin class $ReportCopyWith<$Res>  {
  factory $ReportCopyWith(Report value, $Res Function(Report) _then) = _$ReportCopyWithImpl;
@useResult
$Res call({
 int id, String code, LabeledValue status, ReportType? reportType, String? address, String? shortAddress, double latitude, double longitude, ReportDestination? destination, ReportDriver? driver, ReportAmbulance? ambulance, DateTime? createdAt, DateTime? takenAt, DateTime? arrivedAt, DateTime? completedAt, int? responseTimeMinutes, int? waitingMinutes, String? description, ReportDetails? details, List<ReportPatient> patients, List<ReportAttachment> attachments, List<ReportStatusLog> timeline, bool isTrackingAvailable
});


$LabeledValueCopyWith<$Res> get status;$ReportTypeCopyWith<$Res>? get reportType;$ReportDestinationCopyWith<$Res>? get destination;$ReportDriverCopyWith<$Res>? get driver;$ReportAmbulanceCopyWith<$Res>? get ambulance;$ReportDetailsCopyWith<$Res>? get details;

}
/// @nodoc
class _$ReportCopyWithImpl<$Res>
    implements $ReportCopyWith<$Res> {
  _$ReportCopyWithImpl(this._self, this._then);

  final Report _self;
  final $Res Function(Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? status = null,Object? reportType = freezed,Object? address = freezed,Object? shortAddress = freezed,Object? latitude = null,Object? longitude = null,Object? destination = freezed,Object? driver = freezed,Object? ambulance = freezed,Object? createdAt = freezed,Object? takenAt = freezed,Object? arrivedAt = freezed,Object? completedAt = freezed,Object? responseTimeMinutes = freezed,Object? waitingMinutes = freezed,Object? description = freezed,Object? details = freezed,Object? patients = null,Object? attachments = null,Object? timeline = null,Object? isTrackingAvailable = null,}) {
  return _then(Report(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LabeledValue,reportType: freezed == reportType ? _self.reportType : reportType // ignore: cast_nullable_to_non_nullable
as ReportType?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,shortAddress: freezed == shortAddress ? _self.shortAddress : shortAddress // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as ReportDestination?,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as ReportDriver?,ambulance: freezed == ambulance ? _self.ambulance : ambulance // ignore: cast_nullable_to_non_nullable
as ReportAmbulance?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,takenAt: freezed == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,arrivedAt: freezed == arrivedAt ? _self.arrivedAt : arrivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,responseTimeMinutes: freezed == responseTimeMinutes ? _self.responseTimeMinutes : responseTimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,waitingMinutes: freezed == waitingMinutes ? _self.waitingMinutes : waitingMinutes // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as ReportDetails?,patients: null == patients ? _self.patients : patients // ignore: cast_nullable_to_non_nullable
as List<ReportPatient>,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<ReportAttachment>,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<ReportStatusLog>,isTrackingAvailable: null == isTrackingAvailable ? _self.isTrackingAvailable : isTrackingAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res> get status {
  
  return $LabeledValueCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportTypeCopyWith<$Res>? get reportType {
    if (_self.reportType == null) {
    return null;
  }

  return $ReportTypeCopyWith<$Res>(_self.reportType!, (value) {
    return _then(_self.copyWith(reportType: value));
  });
}/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportDestinationCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $ReportDestinationCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportDriverCopyWith<$Res>? get driver {
    if (_self.driver == null) {
    return null;
  }

  return $ReportDriverCopyWith<$Res>(_self.driver!, (value) {
    return _then(_self.copyWith(driver: value));
  });
}/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportAmbulanceCopyWith<$Res>? get ambulance {
    if (_self.ambulance == null) {
    return null;
  }

  return $ReportAmbulanceCopyWith<$Res>(_self.ambulance!, (value) {
    return _then(_self.copyWith(ambulance: value));
  });
}/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportDetailsCopyWith<$Res>? get details {
    if (_self.details == null) {
    return null;
  }

  return $ReportDetailsCopyWith<$Res>(_self.details!, (value) {
    return _then(_self.copyWith(details: value));
  });
}
}


/// Adds pattern-matching-related methods to [Report].
extension ReportPatterns on Report {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Report value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Report value)  $default,){
final _that = this;
switch (_that) {
case _Report():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Report value)?  $default,){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  LabeledValue status,  ReportType? reportType,  String? address,  String? shortAddress,  double latitude,  double longitude,  ReportDestination? destination,  ReportDriver? driver,  ReportAmbulance? ambulance,  DateTime? createdAt,  DateTime? takenAt,  DateTime? arrivedAt,  DateTime? completedAt,  int? responseTimeMinutes,  int? waitingMinutes,  String? description,  ReportDetails? details,  List<ReportPatient> patients,  List<ReportAttachment> attachments,  List<ReportStatusLog> timeline,  bool isTrackingAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.code,_that.status,_that.reportType,_that.address,_that.shortAddress,_that.latitude,_that.longitude,_that.destination,_that.driver,_that.ambulance,_that.createdAt,_that.takenAt,_that.arrivedAt,_that.completedAt,_that.responseTimeMinutes,_that.waitingMinutes,_that.description,_that.details,_that.patients,_that.attachments,_that.timeline,_that.isTrackingAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  LabeledValue status,  ReportType? reportType,  String? address,  String? shortAddress,  double latitude,  double longitude,  ReportDestination? destination,  ReportDriver? driver,  ReportAmbulance? ambulance,  DateTime? createdAt,  DateTime? takenAt,  DateTime? arrivedAt,  DateTime? completedAt,  int? responseTimeMinutes,  int? waitingMinutes,  String? description,  ReportDetails? details,  List<ReportPatient> patients,  List<ReportAttachment> attachments,  List<ReportStatusLog> timeline,  bool isTrackingAvailable)  $default,) {final _that = this;
switch (_that) {
case _Report():
return $default(_that.id,_that.code,_that.status,_that.reportType,_that.address,_that.shortAddress,_that.latitude,_that.longitude,_that.destination,_that.driver,_that.ambulance,_that.createdAt,_that.takenAt,_that.arrivedAt,_that.completedAt,_that.responseTimeMinutes,_that.waitingMinutes,_that.description,_that.details,_that.patients,_that.attachments,_that.timeline,_that.isTrackingAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  LabeledValue status,  ReportType? reportType,  String? address,  String? shortAddress,  double latitude,  double longitude,  ReportDestination? destination,  ReportDriver? driver,  ReportAmbulance? ambulance,  DateTime? createdAt,  DateTime? takenAt,  DateTime? arrivedAt,  DateTime? completedAt,  int? responseTimeMinutes,  int? waitingMinutes,  String? description,  ReportDetails? details,  List<ReportPatient> patients,  List<ReportAttachment> attachments,  List<ReportStatusLog> timeline,  bool isTrackingAvailable)?  $default,) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.code,_that.status,_that.reportType,_that.address,_that.shortAddress,_that.latitude,_that.longitude,_that.destination,_that.driver,_that.ambulance,_that.createdAt,_that.takenAt,_that.arrivedAt,_that.completedAt,_that.responseTimeMinutes,_that.waitingMinutes,_that.description,_that.details,_that.patients,_that.attachments,_that.timeline,_that.isTrackingAvailable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Report extends Report {
  const _Report({required this.id, required this.code, required this.status, this.reportType, this.address, this.shortAddress, required this.latitude, required this.longitude, this.destination, this.driver, this.ambulance, this.createdAt, this.takenAt, this.arrivedAt, this.completedAt, this.responseTimeMinutes, this.waitingMinutes, this.description, this.details,  List<ReportPatient> patients = const [],  List<ReportAttachment> attachments = const [],  List<ReportStatusLog> timeline = const [], this.isTrackingAvailable = false}): _patients = patients,_attachments = attachments,_timeline = timeline,super._();
  factory _Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

@override final  int id;
@override final  String code;
@override final  LabeledValue status;
@override final  ReportType? reportType;
@override final  String? address;
@override final  String? shortAddress;
@override final  double latitude;
@override final  double longitude;
@override final  ReportDestination? destination;
@override final  ReportDriver? driver;
@override final  ReportAmbulance? ambulance;
@override final  DateTime? createdAt;
@override final  DateTime? takenAt;
@override final  DateTime? arrivedAt;
@override final  DateTime? completedAt;
@override final  int? responseTimeMinutes;
@override final  int? waitingMinutes;
@override final  String? description;
@override final  ReportDetails? details;
 final  List<ReportPatient> _patients;
@override@JsonKey() List<ReportPatient> get patients {
  if (_patients is EqualUnmodifiableListView) return _patients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_patients);
}

 final  List<ReportAttachment> _attachments;
@override@JsonKey() List<ReportAttachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

 final  List<ReportStatusLog> _timeline;
@override@JsonKey() List<ReportStatusLog> get timeline {
  if (_timeline is EqualUnmodifiableListView) return _timeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeline);
}

@override@JsonKey() final  bool isTrackingAvailable;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportCopyWith<_Report> get copyWith => __$ReportCopyWithImpl<_Report>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Report&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&(identical(other.reportType, reportType) || other.reportType == reportType)&&(identical(other.address, address) || other.address == address)&&(identical(other.shortAddress, shortAddress) || other.shortAddress == shortAddress)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.ambulance, ambulance) || other.ambulance == ambulance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.takenAt, takenAt) || other.takenAt == takenAt)&&(identical(other.arrivedAt, arrivedAt) || other.arrivedAt == arrivedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.responseTimeMinutes, responseTimeMinutes) || other.responseTimeMinutes == responseTimeMinutes)&&(identical(other.waitingMinutes, waitingMinutes) || other.waitingMinutes == waitingMinutes)&&(identical(other.description, description) || other.description == description)&&(identical(other.details, details) || other.details == details)&&const DeepCollectionEquality().equals(other.patients, _patients)&&const DeepCollectionEquality().equals(other.attachments, _attachments)&&const DeepCollectionEquality().equals(other.timeline, _timeline)&&(identical(other.isTrackingAvailable, isTrackingAvailable) || other.isTrackingAvailable == isTrackingAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,code,status,reportType,address,shortAddress,latitude,longitude,destination,driver,ambulance,createdAt,takenAt,arrivedAt,completedAt,responseTimeMinutes,waitingMinutes,description,details,const DeepCollectionEquality().hash(_patients),const DeepCollectionEquality().hash(_attachments),const DeepCollectionEquality().hash(_timeline),isTrackingAvailable]);
}

@override
String toString() {
    return 'Report(id: $id, code: $code, status: $status, reportType: $reportType, address: $address, shortAddress: $shortAddress, latitude: $latitude, longitude: $longitude, destination: $destination, driver: $driver, ambulance: $ambulance, createdAt: $createdAt, takenAt: $takenAt, arrivedAt: $arrivedAt, completedAt: $completedAt, responseTimeMinutes: $responseTimeMinutes, waitingMinutes: $waitingMinutes, description: $description, details: $details, patients: $patients, attachments: $attachments, timeline: $timeline, isTrackingAvailable: $isTrackingAvailable)';
}


}

/// @nodoc
abstract mixin class _$ReportCopyWith<$Res> implements $ReportCopyWith<$Res> {
  factory _$ReportCopyWith(_Report value, $Res Function(_Report) _then) = __$ReportCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, LabeledValue status, ReportType? reportType, String? address, String? shortAddress, double latitude, double longitude, ReportDestination? destination, ReportDriver? driver, ReportAmbulance? ambulance, DateTime? createdAt, DateTime? takenAt, DateTime? arrivedAt, DateTime? completedAt, int? responseTimeMinutes, int? waitingMinutes, String? description, ReportDetails? details, List<ReportPatient> patients, List<ReportAttachment> attachments, List<ReportStatusLog> timeline, bool isTrackingAvailable
});


@override $LabeledValueCopyWith<$Res> get status;@override $ReportTypeCopyWith<$Res>? get reportType;@override $ReportDestinationCopyWith<$Res>? get destination;@override $ReportDriverCopyWith<$Res>? get driver;@override $ReportAmbulanceCopyWith<$Res>? get ambulance;@override $ReportDetailsCopyWith<$Res>? get details;

}
/// @nodoc
class __$ReportCopyWithImpl<$Res>
    implements _$ReportCopyWith<$Res> {
  __$ReportCopyWithImpl(this._self, this._then);

  final _Report _self;
  final $Res Function(_Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? status = null,Object? reportType = freezed,Object? address = freezed,Object? shortAddress = freezed,Object? latitude = null,Object? longitude = null,Object? destination = freezed,Object? driver = freezed,Object? ambulance = freezed,Object? createdAt = freezed,Object? takenAt = freezed,Object? arrivedAt = freezed,Object? completedAt = freezed,Object? responseTimeMinutes = freezed,Object? waitingMinutes = freezed,Object? description = freezed,Object? details = freezed,Object? patients = null,Object? attachments = null,Object? timeline = null,Object? isTrackingAvailable = null,}) {
  return _then(_Report(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LabeledValue,reportType: freezed == reportType ? _self.reportType : reportType // ignore: cast_nullable_to_non_nullable
as ReportType?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,shortAddress: freezed == shortAddress ? _self.shortAddress : shortAddress // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as ReportDestination?,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as ReportDriver?,ambulance: freezed == ambulance ? _self.ambulance : ambulance // ignore: cast_nullable_to_non_nullable
as ReportAmbulance?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,takenAt: freezed == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,arrivedAt: freezed == arrivedAt ? _self.arrivedAt : arrivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,responseTimeMinutes: freezed == responseTimeMinutes ? _self.responseTimeMinutes : responseTimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,waitingMinutes: freezed == waitingMinutes ? _self.waitingMinutes : waitingMinutes // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as ReportDetails?,patients: null == patients ? _self._patients : patients // ignore: cast_nullable_to_non_nullable
as List<ReportPatient>,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<ReportAttachment>,timeline: null == timeline ? _self._timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<ReportStatusLog>,isTrackingAvailable: null == isTrackingAvailable ? _self.isTrackingAvailable : isTrackingAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res> get status {
  
  return $LabeledValueCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportTypeCopyWith<$Res>? get reportType {
    if (_self.reportType == null) {
    return null;
  }

  return $ReportTypeCopyWith<$Res>(_self.reportType!, (value) {
    return _then(_self.copyWith(reportType: value));
  });
}/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportDestinationCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $ReportDestinationCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportDriverCopyWith<$Res>? get driver {
    if (_self.driver == null) {
    return null;
  }

  return $ReportDriverCopyWith<$Res>(_self.driver!, (value) {
    return _then(_self.copyWith(driver: value));
  });
}/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportAmbulanceCopyWith<$Res>? get ambulance {
    if (_self.ambulance == null) {
    return null;
  }

  return $ReportAmbulanceCopyWith<$Res>(_self.ambulance!, (value) {
    return _then(_self.copyWith(ambulance: value));
  });
}/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportDetailsCopyWith<$Res>? get details {
    if (_self.details == null) {
    return null;
  }

  return $ReportDetailsCopyWith<$Res>(_self.details!, (value) {
    return _then(_self.copyWith(details: value));
  });
}
}

// dart format on

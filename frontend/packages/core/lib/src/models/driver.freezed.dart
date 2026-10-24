// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverProfile {

 int? get clinicId; Clinic? get clinic; String? get employeeNumber; String? get licenseNumber; LabeledValue? get licenseClass; DateTime? get licenseExpiresAt; String? get licenseExpiryState; String? get photoUrl; bool get isOnDuty;
/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverProfileCopyWith<DriverProfile> get copyWith => _$DriverProfileCopyWithImpl<DriverProfile>(this as DriverProfile, _$identity);

  /// Serializes this DriverProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DriverProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverProfile&&(identical(other.clinicId, _this.clinicId) || other.clinicId == _this.clinicId)&&(identical(other.clinic, _this.clinic) || other.clinic == _this.clinic)&&(identical(other.employeeNumber, _this.employeeNumber) || other.employeeNumber == _this.employeeNumber)&&(identical(other.licenseNumber, _this.licenseNumber) || other.licenseNumber == _this.licenseNumber)&&(identical(other.licenseClass, _this.licenseClass) || other.licenseClass == _this.licenseClass)&&(identical(other.licenseExpiresAt, _this.licenseExpiresAt) || other.licenseExpiresAt == _this.licenseExpiresAt)&&(identical(other.licenseExpiryState, _this.licenseExpiryState) || other.licenseExpiryState == _this.licenseExpiryState)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&(identical(other.isOnDuty, _this.isOnDuty) || other.isOnDuty == _this.isOnDuty));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DriverProfile;
  return Object.hash(runtimeType,_this.clinicId,_this.clinic,_this.employeeNumber,_this.licenseNumber,_this.licenseClass,_this.licenseExpiresAt,_this.licenseExpiryState,_this.photoUrl,_this.isOnDuty);
}

@override
String toString() {
  final _this = this as DriverProfile;
  return 'DriverProfile(clinicId: ${_this.clinicId}, clinic: ${_this.clinic}, employeeNumber: ${_this.employeeNumber}, licenseNumber: ${_this.licenseNumber}, licenseClass: ${_this.licenseClass}, licenseExpiresAt: ${_this.licenseExpiresAt}, licenseExpiryState: ${_this.licenseExpiryState}, photoUrl: ${_this.photoUrl}, isOnDuty: ${_this.isOnDuty})';
}


}

/// @nodoc
abstract mixin class $DriverProfileCopyWith<$Res>  {
  factory $DriverProfileCopyWith(DriverProfile value, $Res Function(DriverProfile) _then) = _$DriverProfileCopyWithImpl;
@useResult
$Res call({
 int? clinicId, Clinic? clinic, String? employeeNumber, String? licenseNumber, LabeledValue? licenseClass, DateTime? licenseExpiresAt, String? licenseExpiryState, String? photoUrl, bool isOnDuty
});


$ClinicCopyWith<$Res>? get clinic;$LabeledValueCopyWith<$Res>? get licenseClass;

}
/// @nodoc
class _$DriverProfileCopyWithImpl<$Res>
    implements $DriverProfileCopyWith<$Res> {
  _$DriverProfileCopyWithImpl(this._self, this._then);

  final DriverProfile _self;
  final $Res Function(DriverProfile) _then;

/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clinicId = freezed,Object? clinic = freezed,Object? employeeNumber = freezed,Object? licenseNumber = freezed,Object? licenseClass = freezed,Object? licenseExpiresAt = freezed,Object? licenseExpiryState = freezed,Object? photoUrl = freezed,Object? isOnDuty = null,}) {
  return _then(DriverProfile(
clinicId: freezed == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as int?,clinic: freezed == clinic ? _self.clinic : clinic // ignore: cast_nullable_to_non_nullable
as Clinic?,employeeNumber: freezed == employeeNumber ? _self.employeeNumber : employeeNumber // ignore: cast_nullable_to_non_nullable
as String?,licenseNumber: freezed == licenseNumber ? _self.licenseNumber : licenseNumber // ignore: cast_nullable_to_non_nullable
as String?,licenseClass: freezed == licenseClass ? _self.licenseClass : licenseClass // ignore: cast_nullable_to_non_nullable
as LabeledValue?,licenseExpiresAt: freezed == licenseExpiresAt ? _self.licenseExpiresAt : licenseExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,licenseExpiryState: freezed == licenseExpiryState ? _self.licenseExpiryState : licenseExpiryState // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,isOnDuty: null == isOnDuty ? _self.isOnDuty : isOnDuty // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicCopyWith<$Res>? get clinic {
    if (_self.clinic == null) {
    return null;
  }

  return $ClinicCopyWith<$Res>(_self.clinic!, (value) {
    return _then(_self.copyWith(clinic: value));
  });
}/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get licenseClass {
    if (_self.licenseClass == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.licenseClass!, (value) {
    return _then(_self.copyWith(licenseClass: value));
  });
}
}


/// Adds pattern-matching-related methods to [DriverProfile].
extension DriverProfilePatterns on DriverProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverProfile value)  $default,){
final _that = this;
switch (_that) {
case _DriverProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverProfile value)?  $default,){
final _that = this;
switch (_that) {
case _DriverProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? clinicId,  Clinic? clinic,  String? employeeNumber,  String? licenseNumber,  LabeledValue? licenseClass,  DateTime? licenseExpiresAt,  String? licenseExpiryState,  String? photoUrl,  bool isOnDuty)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverProfile() when $default != null:
return $default(_that.clinicId,_that.clinic,_that.employeeNumber,_that.licenseNumber,_that.licenseClass,_that.licenseExpiresAt,_that.licenseExpiryState,_that.photoUrl,_that.isOnDuty);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? clinicId,  Clinic? clinic,  String? employeeNumber,  String? licenseNumber,  LabeledValue? licenseClass,  DateTime? licenseExpiresAt,  String? licenseExpiryState,  String? photoUrl,  bool isOnDuty)  $default,) {final _that = this;
switch (_that) {
case _DriverProfile():
return $default(_that.clinicId,_that.clinic,_that.employeeNumber,_that.licenseNumber,_that.licenseClass,_that.licenseExpiresAt,_that.licenseExpiryState,_that.photoUrl,_that.isOnDuty);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? clinicId,  Clinic? clinic,  String? employeeNumber,  String? licenseNumber,  LabeledValue? licenseClass,  DateTime? licenseExpiresAt,  String? licenseExpiryState,  String? photoUrl,  bool isOnDuty)?  $default,) {final _that = this;
switch (_that) {
case _DriverProfile() when $default != null:
return $default(_that.clinicId,_that.clinic,_that.employeeNumber,_that.licenseNumber,_that.licenseClass,_that.licenseExpiresAt,_that.licenseExpiryState,_that.photoUrl,_that.isOnDuty);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverProfile implements DriverProfile {
  const _DriverProfile({this.clinicId, this.clinic, this.employeeNumber, this.licenseNumber, this.licenseClass, this.licenseExpiresAt, this.licenseExpiryState, this.photoUrl, this.isOnDuty = false});
  factory _DriverProfile.fromJson(Map<String, dynamic> json) => _$DriverProfileFromJson(json);

@override final  int? clinicId;
@override final  Clinic? clinic;
@override final  String? employeeNumber;
@override final  String? licenseNumber;
@override final  LabeledValue? licenseClass;
@override final  DateTime? licenseExpiresAt;
@override final  String? licenseExpiryState;
@override final  String? photoUrl;
@override@JsonKey() final  bool isOnDuty;

/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverProfileCopyWith<_DriverProfile> get copyWith => __$DriverProfileCopyWithImpl<_DriverProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverProfile&&(identical(other.clinicId, clinicId) || other.clinicId == clinicId)&&(identical(other.clinic, clinic) || other.clinic == clinic)&&(identical(other.employeeNumber, employeeNumber) || other.employeeNumber == employeeNumber)&&(identical(other.licenseNumber, licenseNumber) || other.licenseNumber == licenseNumber)&&(identical(other.licenseClass, licenseClass) || other.licenseClass == licenseClass)&&(identical(other.licenseExpiresAt, licenseExpiresAt) || other.licenseExpiresAt == licenseExpiresAt)&&(identical(other.licenseExpiryState, licenseExpiryState) || other.licenseExpiryState == licenseExpiryState)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.isOnDuty, isOnDuty) || other.isOnDuty == isOnDuty));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,clinicId,clinic,employeeNumber,licenseNumber,licenseClass,licenseExpiresAt,licenseExpiryState,photoUrl,isOnDuty);
}

@override
String toString() {
    return 'DriverProfile(clinicId: $clinicId, clinic: $clinic, employeeNumber: $employeeNumber, licenseNumber: $licenseNumber, licenseClass: $licenseClass, licenseExpiresAt: $licenseExpiresAt, licenseExpiryState: $licenseExpiryState, photoUrl: $photoUrl, isOnDuty: $isOnDuty)';
}


}

/// @nodoc
abstract mixin class _$DriverProfileCopyWith<$Res> implements $DriverProfileCopyWith<$Res> {
  factory _$DriverProfileCopyWith(_DriverProfile value, $Res Function(_DriverProfile) _then) = __$DriverProfileCopyWithImpl;
@override @useResult
$Res call({
 int? clinicId, Clinic? clinic, String? employeeNumber, String? licenseNumber, LabeledValue? licenseClass, DateTime? licenseExpiresAt, String? licenseExpiryState, String? photoUrl, bool isOnDuty
});


@override $ClinicCopyWith<$Res>? get clinic;@override $LabeledValueCopyWith<$Res>? get licenseClass;

}
/// @nodoc
class __$DriverProfileCopyWithImpl<$Res>
    implements _$DriverProfileCopyWith<$Res> {
  __$DriverProfileCopyWithImpl(this._self, this._then);

  final _DriverProfile _self;
  final $Res Function(_DriverProfile) _then;

/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clinicId = freezed,Object? clinic = freezed,Object? employeeNumber = freezed,Object? licenseNumber = freezed,Object? licenseClass = freezed,Object? licenseExpiresAt = freezed,Object? licenseExpiryState = freezed,Object? photoUrl = freezed,Object? isOnDuty = null,}) {
  return _then(_DriverProfile(
clinicId: freezed == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as int?,clinic: freezed == clinic ? _self.clinic : clinic // ignore: cast_nullable_to_non_nullable
as Clinic?,employeeNumber: freezed == employeeNumber ? _self.employeeNumber : employeeNumber // ignore: cast_nullable_to_non_nullable
as String?,licenseNumber: freezed == licenseNumber ? _self.licenseNumber : licenseNumber // ignore: cast_nullable_to_non_nullable
as String?,licenseClass: freezed == licenseClass ? _self.licenseClass : licenseClass // ignore: cast_nullable_to_non_nullable
as LabeledValue?,licenseExpiresAt: freezed == licenseExpiresAt ? _self.licenseExpiresAt : licenseExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,licenseExpiryState: freezed == licenseExpiryState ? _self.licenseExpiryState : licenseExpiryState // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,isOnDuty: null == isOnDuty ? _self.isOnDuty : isOnDuty // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicCopyWith<$Res>? get clinic {
    if (_self.clinic == null) {
    return null;
  }

  return $ClinicCopyWith<$Res>(_self.clinic!, (value) {
    return _then(_self.copyWith(clinic: value));
  });
}/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get licenseClass {
    if (_self.licenseClass == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.licenseClass!, (value) {
    return _then(_self.copyWith(licenseClass: value));
  });
}
}


/// @nodoc
mixin _$DriverCertification {

 int get id; String get name; String? get certificateNumber; String? get issuer; DateTime? get issuedAt; DateTime? get expiresAt; String? get expiryState; String? get fileUrl;
/// Create a copy of DriverCertification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverCertificationCopyWith<DriverCertification> get copyWith => _$DriverCertificationCopyWithImpl<DriverCertification>(this as DriverCertification, _$identity);

  /// Serializes this DriverCertification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DriverCertification;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverCertification&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.certificateNumber, _this.certificateNumber) || other.certificateNumber == _this.certificateNumber)&&(identical(other.issuer, _this.issuer) || other.issuer == _this.issuer)&&(identical(other.issuedAt, _this.issuedAt) || other.issuedAt == _this.issuedAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.expiryState, _this.expiryState) || other.expiryState == _this.expiryState)&&(identical(other.fileUrl, _this.fileUrl) || other.fileUrl == _this.fileUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DriverCertification;
  return Object.hash(runtimeType,_this.id,_this.name,_this.certificateNumber,_this.issuer,_this.issuedAt,_this.expiresAt,_this.expiryState,_this.fileUrl);
}

@override
String toString() {
  final _this = this as DriverCertification;
  return 'DriverCertification(id: ${_this.id}, name: ${_this.name}, certificateNumber: ${_this.certificateNumber}, issuer: ${_this.issuer}, issuedAt: ${_this.issuedAt}, expiresAt: ${_this.expiresAt}, expiryState: ${_this.expiryState}, fileUrl: ${_this.fileUrl})';
}


}

/// @nodoc
abstract mixin class $DriverCertificationCopyWith<$Res>  {
  factory $DriverCertificationCopyWith(DriverCertification value, $Res Function(DriverCertification) _then) = _$DriverCertificationCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? certificateNumber, String? issuer, DateTime? issuedAt, DateTime? expiresAt, String? expiryState, String? fileUrl
});




}
/// @nodoc
class _$DriverCertificationCopyWithImpl<$Res>
    implements $DriverCertificationCopyWith<$Res> {
  _$DriverCertificationCopyWithImpl(this._self, this._then);

  final DriverCertification _self;
  final $Res Function(DriverCertification) _then;

/// Create a copy of DriverCertification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? certificateNumber = freezed,Object? issuer = freezed,Object? issuedAt = freezed,Object? expiresAt = freezed,Object? expiryState = freezed,Object? fileUrl = freezed,}) {
  return _then(DriverCertification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,certificateNumber: freezed == certificateNumber ? _self.certificateNumber : certificateNumber // ignore: cast_nullable_to_non_nullable
as String?,issuer: freezed == issuer ? _self.issuer : issuer // ignore: cast_nullable_to_non_nullable
as String?,issuedAt: freezed == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryState: freezed == expiryState ? _self.expiryState : expiryState // ignore: cast_nullable_to_non_nullable
as String?,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverCertification].
extension DriverCertificationPatterns on DriverCertification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverCertification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverCertification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverCertification value)  $default,){
final _that = this;
switch (_that) {
case _DriverCertification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverCertification value)?  $default,){
final _that = this;
switch (_that) {
case _DriverCertification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? certificateNumber,  String? issuer,  DateTime? issuedAt,  DateTime? expiresAt,  String? expiryState,  String? fileUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverCertification() when $default != null:
return $default(_that.id,_that.name,_that.certificateNumber,_that.issuer,_that.issuedAt,_that.expiresAt,_that.expiryState,_that.fileUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? certificateNumber,  String? issuer,  DateTime? issuedAt,  DateTime? expiresAt,  String? expiryState,  String? fileUrl)  $default,) {final _that = this;
switch (_that) {
case _DriverCertification():
return $default(_that.id,_that.name,_that.certificateNumber,_that.issuer,_that.issuedAt,_that.expiresAt,_that.expiryState,_that.fileUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? certificateNumber,  String? issuer,  DateTime? issuedAt,  DateTime? expiresAt,  String? expiryState,  String? fileUrl)?  $default,) {final _that = this;
switch (_that) {
case _DriverCertification() when $default != null:
return $default(_that.id,_that.name,_that.certificateNumber,_that.issuer,_that.issuedAt,_that.expiresAt,_that.expiryState,_that.fileUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverCertification extends DriverCertification {
  const _DriverCertification({required this.id, required this.name, this.certificateNumber, this.issuer, this.issuedAt, this.expiresAt, this.expiryState, this.fileUrl}): super._();
  factory _DriverCertification.fromJson(Map<String, dynamic> json) => _$DriverCertificationFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? certificateNumber;
@override final  String? issuer;
@override final  DateTime? issuedAt;
@override final  DateTime? expiresAt;
@override final  String? expiryState;
@override final  String? fileUrl;

/// Create a copy of DriverCertification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverCertificationCopyWith<_DriverCertification> get copyWith => __$DriverCertificationCopyWithImpl<_DriverCertification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverCertificationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverCertification&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.certificateNumber, certificateNumber) || other.certificateNumber == certificateNumber)&&(identical(other.issuer, issuer) || other.issuer == issuer)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.expiryState, expiryState) || other.expiryState == expiryState)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,certificateNumber,issuer,issuedAt,expiresAt,expiryState,fileUrl);
}

@override
String toString() {
    return 'DriverCertification(id: $id, name: $name, certificateNumber: $certificateNumber, issuer: $issuer, issuedAt: $issuedAt, expiresAt: $expiresAt, expiryState: $expiryState, fileUrl: $fileUrl)';
}


}

/// @nodoc
abstract mixin class _$DriverCertificationCopyWith<$Res> implements $DriverCertificationCopyWith<$Res> {
  factory _$DriverCertificationCopyWith(_DriverCertification value, $Res Function(_DriverCertification) _then) = __$DriverCertificationCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? certificateNumber, String? issuer, DateTime? issuedAt, DateTime? expiresAt, String? expiryState, String? fileUrl
});




}
/// @nodoc
class __$DriverCertificationCopyWithImpl<$Res>
    implements _$DriverCertificationCopyWith<$Res> {
  __$DriverCertificationCopyWithImpl(this._self, this._then);

  final _DriverCertification _self;
  final $Res Function(_DriverCertification) _then;

/// Create a copy of DriverCertification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? certificateNumber = freezed,Object? issuer = freezed,Object? issuedAt = freezed,Object? expiresAt = freezed,Object? expiryState = freezed,Object? fileUrl = freezed,}) {
  return _then(_DriverCertification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,certificateNumber: freezed == certificateNumber ? _self.certificateNumber : certificateNumber // ignore: cast_nullable_to_non_nullable
as String?,issuer: freezed == issuer ? _self.issuer : issuer // ignore: cast_nullable_to_non_nullable
as String?,issuedAt: freezed == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryState: freezed == expiryState ? _self.expiryState : expiryState // ignore: cast_nullable_to_non_nullable
as String?,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AmbulanceType {

 int get id; String get code; String get name; String? get description; String? get mapIcon;
/// Create a copy of AmbulanceType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AmbulanceTypeCopyWith<AmbulanceType> get copyWith => _$AmbulanceTypeCopyWithImpl<AmbulanceType>(this as AmbulanceType, _$identity);

  /// Serializes this AmbulanceType to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AmbulanceType;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AmbulanceType&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.mapIcon, _this.mapIcon) || other.mapIcon == _this.mapIcon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AmbulanceType;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name,_this.description,_this.mapIcon);
}

@override
String toString() {
  final _this = this as AmbulanceType;
  return 'AmbulanceType(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, description: ${_this.description}, mapIcon: ${_this.mapIcon})';
}


}

/// @nodoc
abstract mixin class $AmbulanceTypeCopyWith<$Res>  {
  factory $AmbulanceTypeCopyWith(AmbulanceType value, $Res Function(AmbulanceType) _then) = _$AmbulanceTypeCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name, String? description, String? mapIcon
});




}
/// @nodoc
class _$AmbulanceTypeCopyWithImpl<$Res>
    implements $AmbulanceTypeCopyWith<$Res> {
  _$AmbulanceTypeCopyWithImpl(this._self, this._then);

  final AmbulanceType _self;
  final $Res Function(AmbulanceType) _then;

/// Create a copy of AmbulanceType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? description = freezed,Object? mapIcon = freezed,}) {
  return _then(AmbulanceType(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,mapIcon: freezed == mapIcon ? _self.mapIcon : mapIcon // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AmbulanceType].
extension AmbulanceTypePatterns on AmbulanceType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AmbulanceType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AmbulanceType() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AmbulanceType value)  $default,){
final _that = this;
switch (_that) {
case _AmbulanceType():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AmbulanceType value)?  $default,){
final _that = this;
switch (_that) {
case _AmbulanceType() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name,  String? description,  String? mapIcon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AmbulanceType() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.description,_that.mapIcon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name,  String? description,  String? mapIcon)  $default,) {final _that = this;
switch (_that) {
case _AmbulanceType():
return $default(_that.id,_that.code,_that.name,_that.description,_that.mapIcon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name,  String? description,  String? mapIcon)?  $default,) {final _that = this;
switch (_that) {
case _AmbulanceType() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.description,_that.mapIcon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AmbulanceType implements AmbulanceType {
  const _AmbulanceType({required this.id, required this.code, required this.name, this.description, this.mapIcon});
  factory _AmbulanceType.fromJson(Map<String, dynamic> json) => _$AmbulanceTypeFromJson(json);

@override final  int id;
@override final  String code;
@override final  String name;
@override final  String? description;
@override final  String? mapIcon;

/// Create a copy of AmbulanceType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AmbulanceTypeCopyWith<_AmbulanceType> get copyWith => __$AmbulanceTypeCopyWithImpl<_AmbulanceType>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AmbulanceTypeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AmbulanceType&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.mapIcon, mapIcon) || other.mapIcon == mapIcon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name,description,mapIcon);
}

@override
String toString() {
    return 'AmbulanceType(id: $id, code: $code, name: $name, description: $description, mapIcon: $mapIcon)';
}


}

/// @nodoc
abstract mixin class _$AmbulanceTypeCopyWith<$Res> implements $AmbulanceTypeCopyWith<$Res> {
  factory _$AmbulanceTypeCopyWith(_AmbulanceType value, $Res Function(_AmbulanceType) _then) = __$AmbulanceTypeCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name, String? description, String? mapIcon
});




}
/// @nodoc
class __$AmbulanceTypeCopyWithImpl<$Res>
    implements _$AmbulanceTypeCopyWith<$Res> {
  __$AmbulanceTypeCopyWithImpl(this._self, this._then);

  final _AmbulanceType _self;
  final $Res Function(_AmbulanceType) _then;

/// Create a copy of AmbulanceType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? description = freezed,Object? mapIcon = freezed,}) {
  return _then(_AmbulanceType(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,mapIcon: freezed == mapIcon ? _self.mapIcon : mapIcon // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Ambulance {

 int get id; String get plateNumber; String? get vehicleName; int? get year; LabeledValue? get status; String? get notes; int? get clinicId; AmbulanceType? get ambulanceType;
/// Create a copy of Ambulance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AmbulanceCopyWith<Ambulance> get copyWith => _$AmbulanceCopyWithImpl<Ambulance>(this as Ambulance, _$identity);

  /// Serializes this Ambulance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Ambulance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ambulance&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.plateNumber, _this.plateNumber) || other.plateNumber == _this.plateNumber)&&(identical(other.vehicleName, _this.vehicleName) || other.vehicleName == _this.vehicleName)&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.clinicId, _this.clinicId) || other.clinicId == _this.clinicId)&&(identical(other.ambulanceType, _this.ambulanceType) || other.ambulanceType == _this.ambulanceType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Ambulance;
  return Object.hash(runtimeType,_this.id,_this.plateNumber,_this.vehicleName,_this.year,_this.status,_this.notes,_this.clinicId,_this.ambulanceType);
}

@override
String toString() {
  final _this = this as Ambulance;
  return 'Ambulance(id: ${_this.id}, plateNumber: ${_this.plateNumber}, vehicleName: ${_this.vehicleName}, year: ${_this.year}, status: ${_this.status}, notes: ${_this.notes}, clinicId: ${_this.clinicId}, ambulanceType: ${_this.ambulanceType})';
}


}

/// @nodoc
abstract mixin class $AmbulanceCopyWith<$Res>  {
  factory $AmbulanceCopyWith(Ambulance value, $Res Function(Ambulance) _then) = _$AmbulanceCopyWithImpl;
@useResult
$Res call({
 int id, String plateNumber, String? vehicleName, int? year, LabeledValue? status, String? notes, int? clinicId, AmbulanceType? ambulanceType
});


$LabeledValueCopyWith<$Res>? get status;$AmbulanceTypeCopyWith<$Res>? get ambulanceType;

}
/// @nodoc
class _$AmbulanceCopyWithImpl<$Res>
    implements $AmbulanceCopyWith<$Res> {
  _$AmbulanceCopyWithImpl(this._self, this._then);

  final Ambulance _self;
  final $Res Function(Ambulance) _then;

/// Create a copy of Ambulance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? plateNumber = null,Object? vehicleName = freezed,Object? year = freezed,Object? status = freezed,Object? notes = freezed,Object? clinicId = freezed,Object? ambulanceType = freezed,}) {
  return _then(Ambulance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,plateNumber: null == plateNumber ? _self.plateNumber : plateNumber // ignore: cast_nullable_to_non_nullable
as String,vehicleName: freezed == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LabeledValue?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,clinicId: freezed == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as int?,ambulanceType: freezed == ambulanceType ? _self.ambulanceType : ambulanceType // ignore: cast_nullable_to_non_nullable
as AmbulanceType?,
  ));
}
/// Create a copy of Ambulance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of Ambulance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AmbulanceTypeCopyWith<$Res>? get ambulanceType {
    if (_self.ambulanceType == null) {
    return null;
  }

  return $AmbulanceTypeCopyWith<$Res>(_self.ambulanceType!, (value) {
    return _then(_self.copyWith(ambulanceType: value));
  });
}
}


/// Adds pattern-matching-related methods to [Ambulance].
extension AmbulancePatterns on Ambulance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ambulance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ambulance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ambulance value)  $default,){
final _that = this;
switch (_that) {
case _Ambulance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ambulance value)?  $default,){
final _that = this;
switch (_that) {
case _Ambulance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String plateNumber,  String? vehicleName,  int? year,  LabeledValue? status,  String? notes,  int? clinicId,  AmbulanceType? ambulanceType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ambulance() when $default != null:
return $default(_that.id,_that.plateNumber,_that.vehicleName,_that.year,_that.status,_that.notes,_that.clinicId,_that.ambulanceType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String plateNumber,  String? vehicleName,  int? year,  LabeledValue? status,  String? notes,  int? clinicId,  AmbulanceType? ambulanceType)  $default,) {final _that = this;
switch (_that) {
case _Ambulance():
return $default(_that.id,_that.plateNumber,_that.vehicleName,_that.year,_that.status,_that.notes,_that.clinicId,_that.ambulanceType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String plateNumber,  String? vehicleName,  int? year,  LabeledValue? status,  String? notes,  int? clinicId,  AmbulanceType? ambulanceType)?  $default,) {final _that = this;
switch (_that) {
case _Ambulance() when $default != null:
return $default(_that.id,_that.plateNumber,_that.vehicleName,_that.year,_that.status,_that.notes,_that.clinicId,_that.ambulanceType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Ambulance implements Ambulance {
  const _Ambulance({required this.id, required this.plateNumber, this.vehicleName, this.year, this.status, this.notes, this.clinicId, this.ambulanceType});
  factory _Ambulance.fromJson(Map<String, dynamic> json) => _$AmbulanceFromJson(json);

@override final  int id;
@override final  String plateNumber;
@override final  String? vehicleName;
@override final  int? year;
@override final  LabeledValue? status;
@override final  String? notes;
@override final  int? clinicId;
@override final  AmbulanceType? ambulanceType;

/// Create a copy of Ambulance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AmbulanceCopyWith<_Ambulance> get copyWith => __$AmbulanceCopyWithImpl<_Ambulance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AmbulanceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ambulance&&(identical(other.id, id) || other.id == id)&&(identical(other.plateNumber, plateNumber) || other.plateNumber == plateNumber)&&(identical(other.vehicleName, vehicleName) || other.vehicleName == vehicleName)&&(identical(other.year, year) || other.year == year)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.clinicId, clinicId) || other.clinicId == clinicId)&&(identical(other.ambulanceType, ambulanceType) || other.ambulanceType == ambulanceType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,plateNumber,vehicleName,year,status,notes,clinicId,ambulanceType);
}

@override
String toString() {
    return 'Ambulance(id: $id, plateNumber: $plateNumber, vehicleName: $vehicleName, year: $year, status: $status, notes: $notes, clinicId: $clinicId, ambulanceType: $ambulanceType)';
}


}

/// @nodoc
abstract mixin class _$AmbulanceCopyWith<$Res> implements $AmbulanceCopyWith<$Res> {
  factory _$AmbulanceCopyWith(_Ambulance value, $Res Function(_Ambulance) _then) = __$AmbulanceCopyWithImpl;
@override @useResult
$Res call({
 int id, String plateNumber, String? vehicleName, int? year, LabeledValue? status, String? notes, int? clinicId, AmbulanceType? ambulanceType
});


@override $LabeledValueCopyWith<$Res>? get status;@override $AmbulanceTypeCopyWith<$Res>? get ambulanceType;

}
/// @nodoc
class __$AmbulanceCopyWithImpl<$Res>
    implements _$AmbulanceCopyWith<$Res> {
  __$AmbulanceCopyWithImpl(this._self, this._then);

  final _Ambulance _self;
  final $Res Function(_Ambulance) _then;

/// Create a copy of Ambulance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? plateNumber = null,Object? vehicleName = freezed,Object? year = freezed,Object? status = freezed,Object? notes = freezed,Object? clinicId = freezed,Object? ambulanceType = freezed,}) {
  return _then(_Ambulance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,plateNumber: null == plateNumber ? _self.plateNumber : plateNumber // ignore: cast_nullable_to_non_nullable
as String,vehicleName: freezed == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LabeledValue?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,clinicId: freezed == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as int?,ambulanceType: freezed == ambulanceType ? _self.ambulanceType : ambulanceType // ignore: cast_nullable_to_non_nullable
as AmbulanceType?,
  ));
}

/// Create a copy of Ambulance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of Ambulance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AmbulanceTypeCopyWith<$Res>? get ambulanceType {
    if (_self.ambulanceType == null) {
    return null;
  }

  return $AmbulanceTypeCopyWith<$Res>(_self.ambulanceType!, (value) {
    return _then(_self.copyWith(ambulanceType: value));
  });
}
}


/// @nodoc
mixin _$Shift {

 int get id; int? get driverId; DateTime? get startedAt; DateTime? get endedAt; LabeledValue? get endReason; bool get isOpen; Ambulance? get ambulance;
/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShiftCopyWith<Shift> get copyWith => _$ShiftCopyWithImpl<Shift>(this as Shift, _$identity);

  /// Serializes this Shift to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Shift;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Shift&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.endReason, _this.endReason) || other.endReason == _this.endReason)&&(identical(other.isOpen, _this.isOpen) || other.isOpen == _this.isOpen)&&(identical(other.ambulance, _this.ambulance) || other.ambulance == _this.ambulance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Shift;
  return Object.hash(runtimeType,_this.id,_this.driverId,_this.startedAt,_this.endedAt,_this.endReason,_this.isOpen,_this.ambulance);
}

@override
String toString() {
  final _this = this as Shift;
  return 'Shift(id: ${_this.id}, driverId: ${_this.driverId}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, endReason: ${_this.endReason}, isOpen: ${_this.isOpen}, ambulance: ${_this.ambulance})';
}


}

/// @nodoc
abstract mixin class $ShiftCopyWith<$Res>  {
  factory $ShiftCopyWith(Shift value, $Res Function(Shift) _then) = _$ShiftCopyWithImpl;
@useResult
$Res call({
 int id, int? driverId, DateTime? startedAt, DateTime? endedAt, LabeledValue? endReason, bool isOpen, Ambulance? ambulance
});


$LabeledValueCopyWith<$Res>? get endReason;$AmbulanceCopyWith<$Res>? get ambulance;

}
/// @nodoc
class _$ShiftCopyWithImpl<$Res>
    implements $ShiftCopyWith<$Res> {
  _$ShiftCopyWithImpl(this._self, this._then);

  final Shift _self;
  final $Res Function(Shift) _then;

/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? driverId = freezed,Object? startedAt = freezed,Object? endedAt = freezed,Object? endReason = freezed,Object? isOpen = null,Object? ambulance = freezed,}) {
  return _then(Shift(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as int?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endReason: freezed == endReason ? _self.endReason : endReason // ignore: cast_nullable_to_non_nullable
as LabeledValue?,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,ambulance: freezed == ambulance ? _self.ambulance : ambulance // ignore: cast_nullable_to_non_nullable
as Ambulance?,
  ));
}
/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get endReason {
    if (_self.endReason == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.endReason!, (value) {
    return _then(_self.copyWith(endReason: value));
  });
}/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AmbulanceCopyWith<$Res>? get ambulance {
    if (_self.ambulance == null) {
    return null;
  }

  return $AmbulanceCopyWith<$Res>(_self.ambulance!, (value) {
    return _then(_self.copyWith(ambulance: value));
  });
}
}


/// Adds pattern-matching-related methods to [Shift].
extension ShiftPatterns on Shift {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Shift value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Shift() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Shift value)  $default,){
final _that = this;
switch (_that) {
case _Shift():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Shift value)?  $default,){
final _that = this;
switch (_that) {
case _Shift() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? driverId,  DateTime? startedAt,  DateTime? endedAt,  LabeledValue? endReason,  bool isOpen,  Ambulance? ambulance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Shift() when $default != null:
return $default(_that.id,_that.driverId,_that.startedAt,_that.endedAt,_that.endReason,_that.isOpen,_that.ambulance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? driverId,  DateTime? startedAt,  DateTime? endedAt,  LabeledValue? endReason,  bool isOpen,  Ambulance? ambulance)  $default,) {final _that = this;
switch (_that) {
case _Shift():
return $default(_that.id,_that.driverId,_that.startedAt,_that.endedAt,_that.endReason,_that.isOpen,_that.ambulance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? driverId,  DateTime? startedAt,  DateTime? endedAt,  LabeledValue? endReason,  bool isOpen,  Ambulance? ambulance)?  $default,) {final _that = this;
switch (_that) {
case _Shift() when $default != null:
return $default(_that.id,_that.driverId,_that.startedAt,_that.endedAt,_that.endReason,_that.isOpen,_that.ambulance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Shift implements Shift {
  const _Shift({required this.id, this.driverId, this.startedAt, this.endedAt, this.endReason, this.isOpen = false, this.ambulance});
  factory _Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);

@override final  int id;
@override final  int? driverId;
@override final  DateTime? startedAt;
@override final  DateTime? endedAt;
@override final  LabeledValue? endReason;
@override@JsonKey() final  bool isOpen;
@override final  Ambulance? ambulance;

/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShiftCopyWith<_Shift> get copyWith => __$ShiftCopyWithImpl<_Shift>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShiftToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Shift&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.endReason, endReason) || other.endReason == endReason)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.ambulance, ambulance) || other.ambulance == ambulance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,driverId,startedAt,endedAt,endReason,isOpen,ambulance);
}

@override
String toString() {
    return 'Shift(id: $id, driverId: $driverId, startedAt: $startedAt, endedAt: $endedAt, endReason: $endReason, isOpen: $isOpen, ambulance: $ambulance)';
}


}

/// @nodoc
abstract mixin class _$ShiftCopyWith<$Res> implements $ShiftCopyWith<$Res> {
  factory _$ShiftCopyWith(_Shift value, $Res Function(_Shift) _then) = __$ShiftCopyWithImpl;
@override @useResult
$Res call({
 int id, int? driverId, DateTime? startedAt, DateTime? endedAt, LabeledValue? endReason, bool isOpen, Ambulance? ambulance
});


@override $LabeledValueCopyWith<$Res>? get endReason;@override $AmbulanceCopyWith<$Res>? get ambulance;

}
/// @nodoc
class __$ShiftCopyWithImpl<$Res>
    implements _$ShiftCopyWith<$Res> {
  __$ShiftCopyWithImpl(this._self, this._then);

  final _Shift _self;
  final $Res Function(_Shift) _then;

/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? driverId = freezed,Object? startedAt = freezed,Object? endedAt = freezed,Object? endReason = freezed,Object? isOpen = null,Object? ambulance = freezed,}) {
  return _then(_Shift(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as int?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endReason: freezed == endReason ? _self.endReason : endReason // ignore: cast_nullable_to_non_nullable
as LabeledValue?,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,ambulance: freezed == ambulance ? _self.ambulance : ambulance // ignore: cast_nullable_to_non_nullable
as Ambulance?,
  ));
}

/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get endReason {
    if (_self.endReason == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.endReason!, (value) {
    return _then(_self.copyWith(endReason: value));
  });
}/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AmbulanceCopyWith<$Res>? get ambulance {
    if (_self.ambulance == null) {
    return null;
  }

  return $AmbulanceCopyWith<$Res>(_self.ambulance!, (value) {
    return _then(_self.copyWith(ambulance: value));
  });
}
}


/// @nodoc
mixin _$DriverAccount {

 int get id; String get name; String? get initials; String? get phone; String get email; DriverProfile? get driverProfile; Shift? get openShift; bool get isVerified; List<DriverCertification> get certifications;
/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverAccountCopyWith<DriverAccount> get copyWith => _$DriverAccountCopyWithImpl<DriverAccount>(this as DriverAccount, _$identity);

  /// Serializes this DriverAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DriverAccount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverAccount&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.initials, _this.initials) || other.initials == _this.initials)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.driverProfile, _this.driverProfile) || other.driverProfile == _this.driverProfile)&&(identical(other.openShift, _this.openShift) || other.openShift == _this.openShift)&&(identical(other.isVerified, _this.isVerified) || other.isVerified == _this.isVerified)&&const DeepCollectionEquality().equals(other.certifications, _this.certifications));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DriverAccount;
  return Object.hash(runtimeType,_this.id,_this.name,_this.initials,_this.phone,_this.email,_this.driverProfile,_this.openShift,_this.isVerified,const DeepCollectionEquality().hash(_this.certifications));
}

@override
String toString() {
  final _this = this as DriverAccount;
  return 'DriverAccount(id: ${_this.id}, name: ${_this.name}, initials: ${_this.initials}, phone: ${_this.phone}, email: ${_this.email}, driverProfile: ${_this.driverProfile}, openShift: ${_this.openShift}, isVerified: ${_this.isVerified}, certifications: ${_this.certifications})';
}


}

/// @nodoc
abstract mixin class $DriverAccountCopyWith<$Res>  {
  factory $DriverAccountCopyWith(DriverAccount value, $Res Function(DriverAccount) _then) = _$DriverAccountCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? initials, String? phone, String email, DriverProfile? driverProfile, Shift? openShift, bool isVerified, List<DriverCertification> certifications
});


$DriverProfileCopyWith<$Res>? get driverProfile;$ShiftCopyWith<$Res>? get openShift;

}
/// @nodoc
class _$DriverAccountCopyWithImpl<$Res>
    implements $DriverAccountCopyWith<$Res> {
  _$DriverAccountCopyWithImpl(this._self, this._then);

  final DriverAccount _self;
  final $Res Function(DriverAccount) _then;

/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? initials = freezed,Object? phone = freezed,Object? email = null,Object? driverProfile = freezed,Object? openShift = freezed,Object? isVerified = null,Object? certifications = null,}) {
  return _then(DriverAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,initials: freezed == initials ? _self.initials : initials // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,driverProfile: freezed == driverProfile ? _self.driverProfile : driverProfile // ignore: cast_nullable_to_non_nullable
as DriverProfile?,openShift: freezed == openShift ? _self.openShift : openShift // ignore: cast_nullable_to_non_nullable
as Shift?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,certifications: null == certifications ? _self.certifications : certifications // ignore: cast_nullable_to_non_nullable
as List<DriverCertification>,
  ));
}
/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverProfileCopyWith<$Res>? get driverProfile {
    if (_self.driverProfile == null) {
    return null;
  }

  return $DriverProfileCopyWith<$Res>(_self.driverProfile!, (value) {
    return _then(_self.copyWith(driverProfile: value));
  });
}/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShiftCopyWith<$Res>? get openShift {
    if (_self.openShift == null) {
    return null;
  }

  return $ShiftCopyWith<$Res>(_self.openShift!, (value) {
    return _then(_self.copyWith(openShift: value));
  });
}
}


/// Adds pattern-matching-related methods to [DriverAccount].
extension DriverAccountPatterns on DriverAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverAccount value)  $default,){
final _that = this;
switch (_that) {
case _DriverAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverAccount value)?  $default,){
final _that = this;
switch (_that) {
case _DriverAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? initials,  String? phone,  String email,  DriverProfile? driverProfile,  Shift? openShift,  bool isVerified,  List<DriverCertification> certifications)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverAccount() when $default != null:
return $default(_that.id,_that.name,_that.initials,_that.phone,_that.email,_that.driverProfile,_that.openShift,_that.isVerified,_that.certifications);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? initials,  String? phone,  String email,  DriverProfile? driverProfile,  Shift? openShift,  bool isVerified,  List<DriverCertification> certifications)  $default,) {final _that = this;
switch (_that) {
case _DriverAccount():
return $default(_that.id,_that.name,_that.initials,_that.phone,_that.email,_that.driverProfile,_that.openShift,_that.isVerified,_that.certifications);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? initials,  String? phone,  String email,  DriverProfile? driverProfile,  Shift? openShift,  bool isVerified,  List<DriverCertification> certifications)?  $default,) {final _that = this;
switch (_that) {
case _DriverAccount() when $default != null:
return $default(_that.id,_that.name,_that.initials,_that.phone,_that.email,_that.driverProfile,_that.openShift,_that.isVerified,_that.certifications);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverAccount extends DriverAccount {
  const _DriverAccount({required this.id, required this.name, this.initials, this.phone, required this.email, this.driverProfile, this.openShift, this.isVerified = false,  List<DriverCertification> certifications = const []}): _certifications = certifications,super._();
  factory _DriverAccount.fromJson(Map<String, dynamic> json) => _$DriverAccountFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? initials;
@override final  String? phone;
@override final  String email;
@override final  DriverProfile? driverProfile;
@override final  Shift? openShift;
@override@JsonKey() final  bool isVerified;
 final  List<DriverCertification> _certifications;
@override@JsonKey() List<DriverCertification> get certifications {
  if (_certifications is EqualUnmodifiableListView) return _certifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_certifications);
}


/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverAccountCopyWith<_DriverAccount> get copyWith => __$DriverAccountCopyWithImpl<_DriverAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverAccountToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.initials, initials) || other.initials == initials)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.driverProfile, driverProfile) || other.driverProfile == driverProfile)&&(identical(other.openShift, openShift) || other.openShift == openShift)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&const DeepCollectionEquality().equals(other.certifications, _certifications));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,initials,phone,email,driverProfile,openShift,isVerified,const DeepCollectionEquality().hash(_certifications));
}

@override
String toString() {
    return 'DriverAccount(id: $id, name: $name, initials: $initials, phone: $phone, email: $email, driverProfile: $driverProfile, openShift: $openShift, isVerified: $isVerified, certifications: $certifications)';
}


}

/// @nodoc
abstract mixin class _$DriverAccountCopyWith<$Res> implements $DriverAccountCopyWith<$Res> {
  factory _$DriverAccountCopyWith(_DriverAccount value, $Res Function(_DriverAccount) _then) = __$DriverAccountCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? initials, String? phone, String email, DriverProfile? driverProfile, Shift? openShift, bool isVerified, List<DriverCertification> certifications
});


@override $DriverProfileCopyWith<$Res>? get driverProfile;@override $ShiftCopyWith<$Res>? get openShift;

}
/// @nodoc
class __$DriverAccountCopyWithImpl<$Res>
    implements _$DriverAccountCopyWith<$Res> {
  __$DriverAccountCopyWithImpl(this._self, this._then);

  final _DriverAccount _self;
  final $Res Function(_DriverAccount) _then;

/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? initials = freezed,Object? phone = freezed,Object? email = null,Object? driverProfile = freezed,Object? openShift = freezed,Object? isVerified = null,Object? certifications = null,}) {
  return _then(_DriverAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,initials: freezed == initials ? _self.initials : initials // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,driverProfile: freezed == driverProfile ? _self.driverProfile : driverProfile // ignore: cast_nullable_to_non_nullable
as DriverProfile?,openShift: freezed == openShift ? _self.openShift : openShift // ignore: cast_nullable_to_non_nullable
as Shift?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,certifications: null == certifications ? _self._certifications : certifications // ignore: cast_nullable_to_non_nullable
as List<DriverCertification>,
  ));
}

/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverProfileCopyWith<$Res>? get driverProfile {
    if (_self.driverProfile == null) {
    return null;
  }

  return $DriverProfileCopyWith<$Res>(_self.driverProfile!, (value) {
    return _then(_self.copyWith(driverProfile: value));
  });
}/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShiftCopyWith<$Res>? get openShift {
    if (_self.openShift == null) {
    return null;
  }

  return $ShiftCopyWith<$Res>(_self.openShift!, (value) {
    return _then(_self.copyWith(openShift: value));
  });
}
}


/// @nodoc
mixin _$Dispatch {

 int get id; int get reportId; double get distanceKm; DateTime? get sentAt; DateTime? get openedAt; DateTime? get respondedAt; LabeledValue? get response; Report? get report;
/// Create a copy of Dispatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DispatchCopyWith<Dispatch> get copyWith => _$DispatchCopyWithImpl<Dispatch>(this as Dispatch, _$identity);

  /// Serializes this Dispatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Dispatch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Dispatch&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.reportId, _this.reportId) || other.reportId == _this.reportId)&&(identical(other.distanceKm, _this.distanceKm) || other.distanceKm == _this.distanceKm)&&(identical(other.sentAt, _this.sentAt) || other.sentAt == _this.sentAt)&&(identical(other.openedAt, _this.openedAt) || other.openedAt == _this.openedAt)&&(identical(other.respondedAt, _this.respondedAt) || other.respondedAt == _this.respondedAt)&&(identical(other.response, _this.response) || other.response == _this.response)&&(identical(other.report, _this.report) || other.report == _this.report));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Dispatch;
  return Object.hash(runtimeType,_this.id,_this.reportId,_this.distanceKm,_this.sentAt,_this.openedAt,_this.respondedAt,_this.response,_this.report);
}

@override
String toString() {
  final _this = this as Dispatch;
  return 'Dispatch(id: ${_this.id}, reportId: ${_this.reportId}, distanceKm: ${_this.distanceKm}, sentAt: ${_this.sentAt}, openedAt: ${_this.openedAt}, respondedAt: ${_this.respondedAt}, response: ${_this.response}, report: ${_this.report})';
}


}

/// @nodoc
abstract mixin class $DispatchCopyWith<$Res>  {
  factory $DispatchCopyWith(Dispatch value, $Res Function(Dispatch) _then) = _$DispatchCopyWithImpl;
@useResult
$Res call({
 int id, int reportId, double distanceKm, DateTime? sentAt, DateTime? openedAt, DateTime? respondedAt, LabeledValue? response, Report? report
});


$LabeledValueCopyWith<$Res>? get response;$ReportCopyWith<$Res>? get report;

}
/// @nodoc
class _$DispatchCopyWithImpl<$Res>
    implements $DispatchCopyWith<$Res> {
  _$DispatchCopyWithImpl(this._self, this._then);

  final Dispatch _self;
  final $Res Function(Dispatch) _then;

/// Create a copy of Dispatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reportId = null,Object? distanceKm = null,Object? sentAt = freezed,Object? openedAt = freezed,Object? respondedAt = freezed,Object? response = freezed,Object? report = freezed,}) {
  return _then(Dispatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as int,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,openedAt: freezed == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,response: freezed == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as LabeledValue?,report: freezed == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as Report?,
  ));
}
/// Create a copy of Dispatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get response {
    if (_self.response == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.response!, (value) {
    return _then(_self.copyWith(response: value));
  });
}/// Create a copy of Dispatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportCopyWith<$Res>? get report {
    if (_self.report == null) {
    return null;
  }

  return $ReportCopyWith<$Res>(_self.report!, (value) {
    return _then(_self.copyWith(report: value));
  });
}
}


/// Adds pattern-matching-related methods to [Dispatch].
extension DispatchPatterns on Dispatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Dispatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Dispatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Dispatch value)  $default,){
final _that = this;
switch (_that) {
case _Dispatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Dispatch value)?  $default,){
final _that = this;
switch (_that) {
case _Dispatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int reportId,  double distanceKm,  DateTime? sentAt,  DateTime? openedAt,  DateTime? respondedAt,  LabeledValue? response,  Report? report)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Dispatch() when $default != null:
return $default(_that.id,_that.reportId,_that.distanceKm,_that.sentAt,_that.openedAt,_that.respondedAt,_that.response,_that.report);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int reportId,  double distanceKm,  DateTime? sentAt,  DateTime? openedAt,  DateTime? respondedAt,  LabeledValue? response,  Report? report)  $default,) {final _that = this;
switch (_that) {
case _Dispatch():
return $default(_that.id,_that.reportId,_that.distanceKm,_that.sentAt,_that.openedAt,_that.respondedAt,_that.response,_that.report);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int reportId,  double distanceKm,  DateTime? sentAt,  DateTime? openedAt,  DateTime? respondedAt,  LabeledValue? response,  Report? report)?  $default,) {final _that = this;
switch (_that) {
case _Dispatch() when $default != null:
return $default(_that.id,_that.reportId,_that.distanceKm,_that.sentAt,_that.openedAt,_that.respondedAt,_that.response,_that.report);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Dispatch extends Dispatch {
  const _Dispatch({required this.id, required this.reportId, this.distanceKm = 0, this.sentAt, this.openedAt, this.respondedAt, this.response, this.report}): super._();
  factory _Dispatch.fromJson(Map<String, dynamic> json) => _$DispatchFromJson(json);

@override final  int id;
@override final  int reportId;
@override@JsonKey() final  double distanceKm;
@override final  DateTime? sentAt;
@override final  DateTime? openedAt;
@override final  DateTime? respondedAt;
@override final  LabeledValue? response;
@override final  Report? report;

/// Create a copy of Dispatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DispatchCopyWith<_Dispatch> get copyWith => __$DispatchCopyWithImpl<_Dispatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DispatchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Dispatch&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt)&&(identical(other.response, response) || other.response == response)&&(identical(other.report, report) || other.report == report));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,reportId,distanceKm,sentAt,openedAt,respondedAt,response,report);
}

@override
String toString() {
    return 'Dispatch(id: $id, reportId: $reportId, distanceKm: $distanceKm, sentAt: $sentAt, openedAt: $openedAt, respondedAt: $respondedAt, response: $response, report: $report)';
}


}

/// @nodoc
abstract mixin class _$DispatchCopyWith<$Res> implements $DispatchCopyWith<$Res> {
  factory _$DispatchCopyWith(_Dispatch value, $Res Function(_Dispatch) _then) = __$DispatchCopyWithImpl;
@override @useResult
$Res call({
 int id, int reportId, double distanceKm, DateTime? sentAt, DateTime? openedAt, DateTime? respondedAt, LabeledValue? response, Report? report
});


@override $LabeledValueCopyWith<$Res>? get response;@override $ReportCopyWith<$Res>? get report;

}
/// @nodoc
class __$DispatchCopyWithImpl<$Res>
    implements _$DispatchCopyWith<$Res> {
  __$DispatchCopyWithImpl(this._self, this._then);

  final _Dispatch _self;
  final $Res Function(_Dispatch) _then;

/// Create a copy of Dispatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reportId = null,Object? distanceKm = null,Object? sentAt = freezed,Object? openedAt = freezed,Object? respondedAt = freezed,Object? response = freezed,Object? report = freezed,}) {
  return _then(_Dispatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as int,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,openedAt: freezed == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,response: freezed == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as LabeledValue?,report: freezed == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as Report?,
  ));
}

/// Create a copy of Dispatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabeledValueCopyWith<$Res>? get response {
    if (_self.response == null) {
    return null;
  }

  return $LabeledValueCopyWith<$Res>(_self.response!, (value) {
    return _then(_self.copyWith(response: value));
  });
}/// Create a copy of Dispatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportCopyWith<$Res>? get report {
    if (_self.report == null) {
    return null;
  }

  return $ReportCopyWith<$Res>(_self.report!, (value) {
    return _then(_self.copyWith(report: value));
  });
}
}

// dart format on

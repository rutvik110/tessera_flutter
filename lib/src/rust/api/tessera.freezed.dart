// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tessera.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TesseraError {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TesseraError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TesseraError()';
}


}

/// @nodoc
class $TesseraErrorCopyWith<$Res>  {
$TesseraErrorCopyWith(TesseraError _, $Res Function(TesseraError) __);
}


/// Adds pattern-matching-related methods to [TesseraError].
extension TesseraErrorPatterns on TesseraError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TesseraError_BundleInvalid value)?  bundleInvalid,TResult Function( TesseraError_ChecksumMismatch value)?  checksumMismatch,TResult Function( TesseraError_UnsupportedVersion value)?  unsupportedVersion,TResult Function( TesseraError_InputTooLarge value)?  inputTooLarge,TResult Function( TesseraError_UnsupportedFormat value)?  unsupportedFormat,TResult Function( TesseraError_Inference value)?  inference,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TesseraError_BundleInvalid() when bundleInvalid != null:
return bundleInvalid(_that);case TesseraError_ChecksumMismatch() when checksumMismatch != null:
return checksumMismatch(_that);case TesseraError_UnsupportedVersion() when unsupportedVersion != null:
return unsupportedVersion(_that);case TesseraError_InputTooLarge() when inputTooLarge != null:
return inputTooLarge(_that);case TesseraError_UnsupportedFormat() when unsupportedFormat != null:
return unsupportedFormat(_that);case TesseraError_Inference() when inference != null:
return inference(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TesseraError_BundleInvalid value)  bundleInvalid,required TResult Function( TesseraError_ChecksumMismatch value)  checksumMismatch,required TResult Function( TesseraError_UnsupportedVersion value)  unsupportedVersion,required TResult Function( TesseraError_InputTooLarge value)  inputTooLarge,required TResult Function( TesseraError_UnsupportedFormat value)  unsupportedFormat,required TResult Function( TesseraError_Inference value)  inference,}){
final _that = this;
switch (_that) {
case TesseraError_BundleInvalid():
return bundleInvalid(_that);case TesseraError_ChecksumMismatch():
return checksumMismatch(_that);case TesseraError_UnsupportedVersion():
return unsupportedVersion(_that);case TesseraError_InputTooLarge():
return inputTooLarge(_that);case TesseraError_UnsupportedFormat():
return unsupportedFormat(_that);case TesseraError_Inference():
return inference(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TesseraError_BundleInvalid value)?  bundleInvalid,TResult? Function( TesseraError_ChecksumMismatch value)?  checksumMismatch,TResult? Function( TesseraError_UnsupportedVersion value)?  unsupportedVersion,TResult? Function( TesseraError_InputTooLarge value)?  inputTooLarge,TResult? Function( TesseraError_UnsupportedFormat value)?  unsupportedFormat,TResult? Function( TesseraError_Inference value)?  inference,}){
final _that = this;
switch (_that) {
case TesseraError_BundleInvalid() when bundleInvalid != null:
return bundleInvalid(_that);case TesseraError_ChecksumMismatch() when checksumMismatch != null:
return checksumMismatch(_that);case TesseraError_UnsupportedVersion() when unsupportedVersion != null:
return unsupportedVersion(_that);case TesseraError_InputTooLarge() when inputTooLarge != null:
return inputTooLarge(_that);case TesseraError_UnsupportedFormat() when unsupportedFormat != null:
return unsupportedFormat(_that);case TesseraError_Inference() when inference != null:
return inference(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  bundleInvalid,TResult Function()?  checksumMismatch,TResult Function()?  unsupportedVersion,TResult Function()?  inputTooLarge,TResult Function()?  unsupportedFormat,TResult Function( String stage)?  inference,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TesseraError_BundleInvalid() when bundleInvalid != null:
return bundleInvalid();case TesseraError_ChecksumMismatch() when checksumMismatch != null:
return checksumMismatch();case TesseraError_UnsupportedVersion() when unsupportedVersion != null:
return unsupportedVersion();case TesseraError_InputTooLarge() when inputTooLarge != null:
return inputTooLarge();case TesseraError_UnsupportedFormat() when unsupportedFormat != null:
return unsupportedFormat();case TesseraError_Inference() when inference != null:
return inference(_that.stage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  bundleInvalid,required TResult Function()  checksumMismatch,required TResult Function()  unsupportedVersion,required TResult Function()  inputTooLarge,required TResult Function()  unsupportedFormat,required TResult Function( String stage)  inference,}) {final _that = this;
switch (_that) {
case TesseraError_BundleInvalid():
return bundleInvalid();case TesseraError_ChecksumMismatch():
return checksumMismatch();case TesseraError_UnsupportedVersion():
return unsupportedVersion();case TesseraError_InputTooLarge():
return inputTooLarge();case TesseraError_UnsupportedFormat():
return unsupportedFormat();case TesseraError_Inference():
return inference(_that.stage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  bundleInvalid,TResult? Function()?  checksumMismatch,TResult? Function()?  unsupportedVersion,TResult? Function()?  inputTooLarge,TResult? Function()?  unsupportedFormat,TResult? Function( String stage)?  inference,}) {final _that = this;
switch (_that) {
case TesseraError_BundleInvalid() when bundleInvalid != null:
return bundleInvalid();case TesseraError_ChecksumMismatch() when checksumMismatch != null:
return checksumMismatch();case TesseraError_UnsupportedVersion() when unsupportedVersion != null:
return unsupportedVersion();case TesseraError_InputTooLarge() when inputTooLarge != null:
return inputTooLarge();case TesseraError_UnsupportedFormat() when unsupportedFormat != null:
return unsupportedFormat();case TesseraError_Inference() when inference != null:
return inference(_that.stage);case _:
  return null;

}
}

}

/// @nodoc


class TesseraError_BundleInvalid extends TesseraError {
  const TesseraError_BundleInvalid(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TesseraError_BundleInvalid);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TesseraError.bundleInvalid()';
}


}




/// @nodoc


class TesseraError_ChecksumMismatch extends TesseraError {
  const TesseraError_ChecksumMismatch(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TesseraError_ChecksumMismatch);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TesseraError.checksumMismatch()';
}


}




/// @nodoc


class TesseraError_UnsupportedVersion extends TesseraError {
  const TesseraError_UnsupportedVersion(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TesseraError_UnsupportedVersion);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TesseraError.unsupportedVersion()';
}


}




/// @nodoc


class TesseraError_InputTooLarge extends TesseraError {
  const TesseraError_InputTooLarge(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TesseraError_InputTooLarge);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TesseraError.inputTooLarge()';
}


}




/// @nodoc


class TesseraError_UnsupportedFormat extends TesseraError {
  const TesseraError_UnsupportedFormat(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TesseraError_UnsupportedFormat);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TesseraError.unsupportedFormat()';
}


}




/// @nodoc


class TesseraError_Inference extends TesseraError {
  const TesseraError_Inference({required this.stage}): super._();
  

 final  String stage;

/// Create a copy of TesseraError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TesseraError_InferenceCopyWith<TesseraError_Inference> get copyWith => _$TesseraError_InferenceCopyWithImpl<TesseraError_Inference>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TesseraError_Inference&&(identical(other.stage, stage) || other.stage == stage));
}


@override
int get hashCode => Object.hash(runtimeType,stage);

@override
String toString() {
  return 'TesseraError.inference(stage: $stage)';
}


}

/// @nodoc
abstract mixin class $TesseraError_InferenceCopyWith<$Res> implements $TesseraErrorCopyWith<$Res> {
  factory $TesseraError_InferenceCopyWith(TesseraError_Inference value, $Res Function(TesseraError_Inference) _then) = _$TesseraError_InferenceCopyWithImpl;
@useResult
$Res call({
 String stage
});




}
/// @nodoc
class _$TesseraError_InferenceCopyWithImpl<$Res>
    implements $TesseraError_InferenceCopyWith<$Res> {
  _$TesseraError_InferenceCopyWithImpl(this._self, this._then);

  final TesseraError_Inference _self;
  final $Res Function(TesseraError_Inference) _then;

/// Create a copy of TesseraError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stage = null,}) {
  return _then(TesseraError_Inference(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

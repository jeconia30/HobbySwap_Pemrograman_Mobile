// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Review {

 String get id; String get bookingId; String get dariUserId; String get keUserId; String get itemId; PeranUlasan get peran; int get bintang; String get teks; List<String> get tag; DateTime get tanggal;
/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewCopyWith<Review> get copyWith => _$ReviewCopyWithImpl<Review>(this as Review, _$identity);

  /// Serializes this Review to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Review;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Review&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.bookingId, _this.bookingId) || other.bookingId == _this.bookingId)&&(identical(other.dariUserId, _this.dariUserId) || other.dariUserId == _this.dariUserId)&&(identical(other.keUserId, _this.keUserId) || other.keUserId == _this.keUserId)&&(identical(other.itemId, _this.itemId) || other.itemId == _this.itemId)&&(identical(other.peran, _this.peran) || other.peran == _this.peran)&&(identical(other.bintang, _this.bintang) || other.bintang == _this.bintang)&&(identical(other.teks, _this.teks) || other.teks == _this.teks)&&const DeepCollectionEquality().equals(other.tag, _this.tag)&&(identical(other.tanggal, _this.tanggal) || other.tanggal == _this.tanggal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Review;
  return Object.hash(runtimeType,_this.id,_this.bookingId,_this.dariUserId,_this.keUserId,_this.itemId,_this.peran,_this.bintang,_this.teks,const DeepCollectionEquality().hash(_this.tag),_this.tanggal);
}

@override
String toString() {
  final _this = this as Review;
  return 'Review(id: ${_this.id}, bookingId: ${_this.bookingId}, dariUserId: ${_this.dariUserId}, keUserId: ${_this.keUserId}, itemId: ${_this.itemId}, peran: ${_this.peran}, bintang: ${_this.bintang}, teks: ${_this.teks}, tag: ${_this.tag}, tanggal: ${_this.tanggal})';
}


}

/// @nodoc
abstract mixin class $ReviewCopyWith<$Res>  {
  factory $ReviewCopyWith(Review value, $Res Function(Review) _then) = _$ReviewCopyWithImpl;
@useResult
$Res call({
 String id, String bookingId, String dariUserId, String keUserId, String itemId, PeranUlasan peran, int bintang, String teks, List<String> tag, DateTime tanggal
});




}
/// @nodoc
class _$ReviewCopyWithImpl<$Res>
    implements $ReviewCopyWith<$Res> {
  _$ReviewCopyWithImpl(this._self, this._then);

  final Review _self;
  final $Res Function(Review) _then;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookingId = null,Object? dariUserId = null,Object? keUserId = null,Object? itemId = null,Object? peran = null,Object? bintang = null,Object? teks = null,Object? tag = null,Object? tanggal = null,}) {
  return _then(Review(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,dariUserId: null == dariUserId ? _self.dariUserId : dariUserId // ignore: cast_nullable_to_non_nullable
as String,keUserId: null == keUserId ? _self.keUserId : keUserId // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,peran: null == peran ? _self.peran : peran // ignore: cast_nullable_to_non_nullable
as PeranUlasan,bintang: null == bintang ? _self.bintang : bintang // ignore: cast_nullable_to_non_nullable
as int,teks: null == teks ? _self.teks : teks // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as List<String>,tanggal: null == tanggal ? _self.tanggal : tanggal // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Review].
extension ReviewPatterns on Review {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Review value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Review() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Review value)  $default,){
final _that = this;
switch (_that) {
case _Review():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Review value)?  $default,){
final _that = this;
switch (_that) {
case _Review() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String bookingId,  String dariUserId,  String keUserId,  String itemId,  PeranUlasan peran,  int bintang,  String teks,  List<String> tag,  DateTime tanggal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Review() when $default != null:
return $default(_that.id,_that.bookingId,_that.dariUserId,_that.keUserId,_that.itemId,_that.peran,_that.bintang,_that.teks,_that.tag,_that.tanggal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String bookingId,  String dariUserId,  String keUserId,  String itemId,  PeranUlasan peran,  int bintang,  String teks,  List<String> tag,  DateTime tanggal)  $default,) {final _that = this;
switch (_that) {
case _Review():
return $default(_that.id,_that.bookingId,_that.dariUserId,_that.keUserId,_that.itemId,_that.peran,_that.bintang,_that.teks,_that.tag,_that.tanggal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String bookingId,  String dariUserId,  String keUserId,  String itemId,  PeranUlasan peran,  int bintang,  String teks,  List<String> tag,  DateTime tanggal)?  $default,) {final _that = this;
switch (_that) {
case _Review() when $default != null:
return $default(_that.id,_that.bookingId,_that.dariUserId,_that.keUserId,_that.itemId,_that.peran,_that.bintang,_that.teks,_that.tag,_that.tanggal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Review implements Review {
  const _Review({required this.id, required this.bookingId, required this.dariUserId, required this.keUserId, required this.itemId, required this.peran, required this.bintang, this.teks = '',  List<String> tag = const <String>[], required this.tanggal}): _tag = tag;
  factory _Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

@override final  String id;
@override final  String bookingId;
@override final  String dariUserId;
@override final  String keUserId;
@override final  String itemId;
@override final  PeranUlasan peran;
@override final  int bintang;
@override@JsonKey() final  String teks;
 final  List<String> _tag;
@override@JsonKey() List<String> get tag {
  if (_tag is EqualUnmodifiableListView) return _tag;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tag);
}

@override final  DateTime tanggal;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewCopyWith<_Review> get copyWith => __$ReviewCopyWithImpl<_Review>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Review&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.dariUserId, dariUserId) || other.dariUserId == dariUserId)&&(identical(other.keUserId, keUserId) || other.keUserId == keUserId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.peran, peran) || other.peran == peran)&&(identical(other.bintang, bintang) || other.bintang == bintang)&&(identical(other.teks, teks) || other.teks == teks)&&const DeepCollectionEquality().equals(other.tag, _tag)&&(identical(other.tanggal, tanggal) || other.tanggal == tanggal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,bookingId,dariUserId,keUserId,itemId,peran,bintang,teks,const DeepCollectionEquality().hash(_tag),tanggal);
}

@override
String toString() {
    return 'Review(id: $id, bookingId: $bookingId, dariUserId: $dariUserId, keUserId: $keUserId, itemId: $itemId, peran: $peran, bintang: $bintang, teks: $teks, tag: $tag, tanggal: $tanggal)';
}


}

/// @nodoc
abstract mixin class _$ReviewCopyWith<$Res> implements $ReviewCopyWith<$Res> {
  factory _$ReviewCopyWith(_Review value, $Res Function(_Review) _then) = __$ReviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String bookingId, String dariUserId, String keUserId, String itemId, PeranUlasan peran, int bintang, String teks, List<String> tag, DateTime tanggal
});




}
/// @nodoc
class __$ReviewCopyWithImpl<$Res>
    implements _$ReviewCopyWith<$Res> {
  __$ReviewCopyWithImpl(this._self, this._then);

  final _Review _self;
  final $Res Function(_Review) _then;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookingId = null,Object? dariUserId = null,Object? keUserId = null,Object? itemId = null,Object? peran = null,Object? bintang = null,Object? teks = null,Object? tag = null,Object? tanggal = null,}) {
  return _then(_Review(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,dariUserId: null == dariUserId ? _self.dariUserId : dariUserId // ignore: cast_nullable_to_non_nullable
as String,keUserId: null == keUserId ? _self.keUserId : keUserId // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,peran: null == peran ? _self.peran : peran // ignore: cast_nullable_to_non_nullable
as PeranUlasan,bintang: null == bintang ? _self.bintang : bintang // ignore: cast_nullable_to_non_nullable
as int,teks: null == teks ? _self.teks : teks // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self._tag : tag // ignore: cast_nullable_to_non_nullable
as List<String>,tanggal: null == tanggal ? _self.tanggal : tanggal // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

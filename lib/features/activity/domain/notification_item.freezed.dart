// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationItem {

 String get id; String get userId; TipeNotifikasi get tipe; String get judul; String get isi; DateTime get tanggal; bool get sudahDibaca;/// Rute tujuan saat notifikasi ditekan.
 String? get tautan;
/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationItemCopyWith<NotificationItem> get copyWith => _$NotificationItemCopyWithImpl<NotificationItem>(this as NotificationItem, _$identity);

  /// Serializes this NotificationItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotificationItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.tipe, _this.tipe) || other.tipe == _this.tipe)&&(identical(other.judul, _this.judul) || other.judul == _this.judul)&&(identical(other.isi, _this.isi) || other.isi == _this.isi)&&(identical(other.tanggal, _this.tanggal) || other.tanggal == _this.tanggal)&&(identical(other.sudahDibaca, _this.sudahDibaca) || other.sudahDibaca == _this.sudahDibaca)&&(identical(other.tautan, _this.tautan) || other.tautan == _this.tautan));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationItem;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.tipe,_this.judul,_this.isi,_this.tanggal,_this.sudahDibaca,_this.tautan);
}

@override
String toString() {
  final _this = this as NotificationItem;
  return 'NotificationItem(id: ${_this.id}, userId: ${_this.userId}, tipe: ${_this.tipe}, judul: ${_this.judul}, isi: ${_this.isi}, tanggal: ${_this.tanggal}, sudahDibaca: ${_this.sudahDibaca}, tautan: ${_this.tautan})';
}


}

/// @nodoc
abstract mixin class $NotificationItemCopyWith<$Res>  {
  factory $NotificationItemCopyWith(NotificationItem value, $Res Function(NotificationItem) _then) = _$NotificationItemCopyWithImpl;
@useResult
$Res call({
 String id, String userId, TipeNotifikasi tipe, String judul, String isi, DateTime tanggal, bool sudahDibaca, String? tautan
});




}
/// @nodoc
class _$NotificationItemCopyWithImpl<$Res>
    implements $NotificationItemCopyWith<$Res> {
  _$NotificationItemCopyWithImpl(this._self, this._then);

  final NotificationItem _self;
  final $Res Function(NotificationItem) _then;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? tipe = null,Object? judul = null,Object? isi = null,Object? tanggal = null,Object? sudahDibaca = null,Object? tautan = freezed,}) {
  return _then(NotificationItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,tipe: null == tipe ? _self.tipe : tipe // ignore: cast_nullable_to_non_nullable
as TipeNotifikasi,judul: null == judul ? _self.judul : judul // ignore: cast_nullable_to_non_nullable
as String,isi: null == isi ? _self.isi : isi // ignore: cast_nullable_to_non_nullable
as String,tanggal: null == tanggal ? _self.tanggal : tanggal // ignore: cast_nullable_to_non_nullable
as DateTime,sudahDibaca: null == sudahDibaca ? _self.sudahDibaca : sudahDibaca // ignore: cast_nullable_to_non_nullable
as bool,tautan: freezed == tautan ? _self.tautan : tautan // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationItem].
extension NotificationItemPatterns on NotificationItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationItem value)  $default,){
final _that = this;
switch (_that) {
case _NotificationItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationItem value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  TipeNotifikasi tipe,  String judul,  String isi,  DateTime tanggal,  bool sudahDibaca,  String? tautan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
return $default(_that.id,_that.userId,_that.tipe,_that.judul,_that.isi,_that.tanggal,_that.sudahDibaca,_that.tautan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  TipeNotifikasi tipe,  String judul,  String isi,  DateTime tanggal,  bool sudahDibaca,  String? tautan)  $default,) {final _that = this;
switch (_that) {
case _NotificationItem():
return $default(_that.id,_that.userId,_that.tipe,_that.judul,_that.isi,_that.tanggal,_that.sudahDibaca,_that.tautan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  TipeNotifikasi tipe,  String judul,  String isi,  DateTime tanggal,  bool sudahDibaca,  String? tautan)?  $default,) {final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
return $default(_that.id,_that.userId,_that.tipe,_that.judul,_that.isi,_that.tanggal,_that.sudahDibaca,_that.tautan);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationItem implements NotificationItem {
  const _NotificationItem({required this.id, required this.userId, required this.tipe, required this.judul, required this.isi, required this.tanggal, this.sudahDibaca = false, this.tautan});
  factory _NotificationItem.fromJson(Map<String, dynamic> json) => _$NotificationItemFromJson(json);

@override final  String id;
@override final  String userId;
@override final  TipeNotifikasi tipe;
@override final  String judul;
@override final  String isi;
@override final  DateTime tanggal;
@override@JsonKey() final  bool sudahDibaca;
/// Rute tujuan saat notifikasi ditekan.
@override final  String? tautan;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationItemCopyWith<_NotificationItem> get copyWith => __$NotificationItemCopyWithImpl<_NotificationItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.tipe, tipe) || other.tipe == tipe)&&(identical(other.judul, judul) || other.judul == judul)&&(identical(other.isi, isi) || other.isi == isi)&&(identical(other.tanggal, tanggal) || other.tanggal == tanggal)&&(identical(other.sudahDibaca, sudahDibaca) || other.sudahDibaca == sudahDibaca)&&(identical(other.tautan, tautan) || other.tautan == tautan));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,tipe,judul,isi,tanggal,sudahDibaca,tautan);
}

@override
String toString() {
    return 'NotificationItem(id: $id, userId: $userId, tipe: $tipe, judul: $judul, isi: $isi, tanggal: $tanggal, sudahDibaca: $sudahDibaca, tautan: $tautan)';
}


}

/// @nodoc
abstract mixin class _$NotificationItemCopyWith<$Res> implements $NotificationItemCopyWith<$Res> {
  factory _$NotificationItemCopyWith(_NotificationItem value, $Res Function(_NotificationItem) _then) = __$NotificationItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, TipeNotifikasi tipe, String judul, String isi, DateTime tanggal, bool sudahDibaca, String? tautan
});




}
/// @nodoc
class __$NotificationItemCopyWithImpl<$Res>
    implements _$NotificationItemCopyWith<$Res> {
  __$NotificationItemCopyWithImpl(this._self, this._then);

  final _NotificationItem _self;
  final $Res Function(_NotificationItem) _then;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? tipe = null,Object? judul = null,Object? isi = null,Object? tanggal = null,Object? sudahDibaca = null,Object? tautan = freezed,}) {
  return _then(_NotificationItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,tipe: null == tipe ? _self.tipe : tipe // ignore: cast_nullable_to_non_nullable
as TipeNotifikasi,judul: null == judul ? _self.judul : judul // ignore: cast_nullable_to_non_nullable
as String,isi: null == isi ? _self.isi : isi // ignore: cast_nullable_to_non_nullable
as String,tanggal: null == tanggal ? _self.tanggal : tanggal // ignore: cast_nullable_to_non_nullable
as DateTime,sudahDibaca: null == sudahDibaca ? _self.sudahDibaca : sudahDibaca // ignore: cast_nullable_to_non_nullable
as bool,tautan: freezed == tautan ? _self.tautan : tautan // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

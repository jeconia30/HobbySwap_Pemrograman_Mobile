// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ItemFilter {

 String get query; Kategori? get kategori; ItemSort get sort;/// `null` = tanpa batas harga.
 int? get hargaMaks; bool get hanyaTersedia;/// Hanya barang yang menerima barter (M11).
 bool get hanyaBarter;
/// Create a copy of ItemFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemFilterCopyWith<ItemFilter> get copyWith => _$ItemFilterCopyWithImpl<ItemFilter>(this as ItemFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ItemFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemFilter&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.kategori, _this.kategori) || other.kategori == _this.kategori)&&(identical(other.sort, _this.sort) || other.sort == _this.sort)&&(identical(other.hargaMaks, _this.hargaMaks) || other.hargaMaks == _this.hargaMaks)&&(identical(other.hanyaTersedia, _this.hanyaTersedia) || other.hanyaTersedia == _this.hanyaTersedia)&&(identical(other.hanyaBarter, _this.hanyaBarter) || other.hanyaBarter == _this.hanyaBarter));
}


@override
int get hashCode {
  final _this = this as ItemFilter;
  return Object.hash(runtimeType,_this.query,_this.kategori,_this.sort,_this.hargaMaks,_this.hanyaTersedia,_this.hanyaBarter);
}

@override
String toString() {
  final _this = this as ItemFilter;
  return 'ItemFilter(query: ${_this.query}, kategori: ${_this.kategori}, sort: ${_this.sort}, hargaMaks: ${_this.hargaMaks}, hanyaTersedia: ${_this.hanyaTersedia}, hanyaBarter: ${_this.hanyaBarter})';
}


}

/// @nodoc
abstract mixin class $ItemFilterCopyWith<$Res>  {
  factory $ItemFilterCopyWith(ItemFilter value, $Res Function(ItemFilter) _then) = _$ItemFilterCopyWithImpl;
@useResult
$Res call({
 String query, Kategori? kategori, ItemSort sort, int? hargaMaks, bool hanyaTersedia, bool hanyaBarter
});




}
/// @nodoc
class _$ItemFilterCopyWithImpl<$Res>
    implements $ItemFilterCopyWith<$Res> {
  _$ItemFilterCopyWithImpl(this._self, this._then);

  final ItemFilter _self;
  final $Res Function(ItemFilter) _then;

/// Create a copy of ItemFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? kategori = freezed,Object? sort = null,Object? hargaMaks = freezed,Object? hanyaTersedia = null,Object? hanyaBarter = null,}) {
  return _then(ItemFilter(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,kategori: freezed == kategori ? _self.kategori : kategori // ignore: cast_nullable_to_non_nullable
as Kategori?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as ItemSort,hargaMaks: freezed == hargaMaks ? _self.hargaMaks : hargaMaks // ignore: cast_nullable_to_non_nullable
as int?,hanyaTersedia: null == hanyaTersedia ? _self.hanyaTersedia : hanyaTersedia // ignore: cast_nullable_to_non_nullable
as bool,hanyaBarter: null == hanyaBarter ? _self.hanyaBarter : hanyaBarter // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemFilter].
extension ItemFilterPatterns on ItemFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemFilter value)  $default,){
final _that = this;
switch (_that) {
case _ItemFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ItemFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  Kategori? kategori,  ItemSort sort,  int? hargaMaks,  bool hanyaTersedia,  bool hanyaBarter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemFilter() when $default != null:
return $default(_that.query,_that.kategori,_that.sort,_that.hargaMaks,_that.hanyaTersedia,_that.hanyaBarter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  Kategori? kategori,  ItemSort sort,  int? hargaMaks,  bool hanyaTersedia,  bool hanyaBarter)  $default,) {final _that = this;
switch (_that) {
case _ItemFilter():
return $default(_that.query,_that.kategori,_that.sort,_that.hargaMaks,_that.hanyaTersedia,_that.hanyaBarter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  Kategori? kategori,  ItemSort sort,  int? hargaMaks,  bool hanyaTersedia,  bool hanyaBarter)?  $default,) {final _that = this;
switch (_that) {
case _ItemFilter() when $default != null:
return $default(_that.query,_that.kategori,_that.sort,_that.hargaMaks,_that.hanyaTersedia,_that.hanyaBarter);case _:
  return null;

}
}

}

/// @nodoc


class _ItemFilter extends ItemFilter {
  const _ItemFilter({this.query = '', this.kategori, this.sort = ItemSort.terpopuler, this.hargaMaks, this.hanyaTersedia = false, this.hanyaBarter = false}): super._();
  

@override@JsonKey() final  String query;
@override final  Kategori? kategori;
@override@JsonKey() final  ItemSort sort;
/// `null` = tanpa batas harga.
@override final  int? hargaMaks;
@override@JsonKey() final  bool hanyaTersedia;
/// Hanya barang yang menerima barter (M11).
@override@JsonKey() final  bool hanyaBarter;

/// Create a copy of ItemFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemFilterCopyWith<_ItemFilter> get copyWith => __$ItemFilterCopyWithImpl<_ItemFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemFilter&&(identical(other.query, query) || other.query == query)&&(identical(other.kategori, kategori) || other.kategori == kategori)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.hargaMaks, hargaMaks) || other.hargaMaks == hargaMaks)&&(identical(other.hanyaTersedia, hanyaTersedia) || other.hanyaTersedia == hanyaTersedia)&&(identical(other.hanyaBarter, hanyaBarter) || other.hanyaBarter == hanyaBarter));
}


@override
int get hashCode {
    return Object.hash(runtimeType,query,kategori,sort,hargaMaks,hanyaTersedia,hanyaBarter);
}

@override
String toString() {
    return 'ItemFilter(query: $query, kategori: $kategori, sort: $sort, hargaMaks: $hargaMaks, hanyaTersedia: $hanyaTersedia, hanyaBarter: $hanyaBarter)';
}


}

/// @nodoc
abstract mixin class _$ItemFilterCopyWith<$Res> implements $ItemFilterCopyWith<$Res> {
  factory _$ItemFilterCopyWith(_ItemFilter value, $Res Function(_ItemFilter) _then) = __$ItemFilterCopyWithImpl;
@override @useResult
$Res call({
 String query, Kategori? kategori, ItemSort sort, int? hargaMaks, bool hanyaTersedia, bool hanyaBarter
});




}
/// @nodoc
class __$ItemFilterCopyWithImpl<$Res>
    implements _$ItemFilterCopyWith<$Res> {
  __$ItemFilterCopyWithImpl(this._self, this._then);

  final _ItemFilter _self;
  final $Res Function(_ItemFilter) _then;

/// Create a copy of ItemFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? kategori = freezed,Object? sort = null,Object? hargaMaks = freezed,Object? hanyaTersedia = null,Object? hanyaBarter = null,}) {
  return _then(_ItemFilter(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,kategori: freezed == kategori ? _self.kategori : kategori // ignore: cast_nullable_to_non_nullable
as Kategori?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as ItemSort,hargaMaks: freezed == hargaMaks ? _self.hargaMaks : hargaMaks // ignore: cast_nullable_to_non_nullable
as int?,hanyaTersedia: null == hanyaTersedia ? _self.hanyaTersedia : hanyaTersedia // ignore: cast_nullable_to_non_nullable
as bool,hanyaBarter: null == hanyaBarter ? _self.hanyaBarter : hanyaBarter // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

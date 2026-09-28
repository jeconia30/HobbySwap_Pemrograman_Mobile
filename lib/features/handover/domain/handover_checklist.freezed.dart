// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'handover_checklist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KondisiItem {

 String get label; bool get dicek; String? get foto;
/// Create a copy of KondisiItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KondisiItemCopyWith<KondisiItem> get copyWith => _$KondisiItemCopyWithImpl<KondisiItem>(this as KondisiItem, _$identity);

  /// Serializes this KondisiItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as KondisiItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KondisiItem&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.dicek, _this.dicek) || other.dicek == _this.dicek)&&(identical(other.foto, _this.foto) || other.foto == _this.foto));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as KondisiItem;
  return Object.hash(runtimeType,_this.label,_this.dicek,_this.foto);
}

@override
String toString() {
  final _this = this as KondisiItem;
  return 'KondisiItem(label: ${_this.label}, dicek: ${_this.dicek}, foto: ${_this.foto})';
}


}

/// @nodoc
abstract mixin class $KondisiItemCopyWith<$Res>  {
  factory $KondisiItemCopyWith(KondisiItem value, $Res Function(KondisiItem) _then) = _$KondisiItemCopyWithImpl;
@useResult
$Res call({
 String label, bool dicek, String? foto
});




}
/// @nodoc
class _$KondisiItemCopyWithImpl<$Res>
    implements $KondisiItemCopyWith<$Res> {
  _$KondisiItemCopyWithImpl(this._self, this._then);

  final KondisiItem _self;
  final $Res Function(KondisiItem) _then;

/// Create a copy of KondisiItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? dicek = null,Object? foto = freezed,}) {
  return _then(KondisiItem(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,dicek: null == dicek ? _self.dicek : dicek // ignore: cast_nullable_to_non_nullable
as bool,foto: freezed == foto ? _self.foto : foto // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [KondisiItem].
extension KondisiItemPatterns on KondisiItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KondisiItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KondisiItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KondisiItem value)  $default,){
final _that = this;
switch (_that) {
case _KondisiItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KondisiItem value)?  $default,){
final _that = this;
switch (_that) {
case _KondisiItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  bool dicek,  String? foto)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KondisiItem() when $default != null:
return $default(_that.label,_that.dicek,_that.foto);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  bool dicek,  String? foto)  $default,) {final _that = this;
switch (_that) {
case _KondisiItem():
return $default(_that.label,_that.dicek,_that.foto);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  bool dicek,  String? foto)?  $default,) {final _that = this;
switch (_that) {
case _KondisiItem() when $default != null:
return $default(_that.label,_that.dicek,_that.foto);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KondisiItem implements KondisiItem {
  const _KondisiItem({required this.label, this.dicek = false, this.foto});
  factory _KondisiItem.fromJson(Map<String, dynamic> json) => _$KondisiItemFromJson(json);

@override final  String label;
@override@JsonKey() final  bool dicek;
@override final  String? foto;

/// Create a copy of KondisiItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KondisiItemCopyWith<_KondisiItem> get copyWith => __$KondisiItemCopyWithImpl<_KondisiItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KondisiItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KondisiItem&&(identical(other.label, label) || other.label == label)&&(identical(other.dicek, dicek) || other.dicek == dicek)&&(identical(other.foto, foto) || other.foto == foto));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,dicek,foto);
}

@override
String toString() {
    return 'KondisiItem(label: $label, dicek: $dicek, foto: $foto)';
}


}

/// @nodoc
abstract mixin class _$KondisiItemCopyWith<$Res> implements $KondisiItemCopyWith<$Res> {
  factory _$KondisiItemCopyWith(_KondisiItem value, $Res Function(_KondisiItem) _then) = __$KondisiItemCopyWithImpl;
@override @useResult
$Res call({
 String label, bool dicek, String? foto
});




}
/// @nodoc
class __$KondisiItemCopyWithImpl<$Res>
    implements _$KondisiItemCopyWith<$Res> {
  __$KondisiItemCopyWithImpl(this._self, this._then);

  final _KondisiItem _self;
  final $Res Function(_KondisiItem) _then;

/// Create a copy of KondisiItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? dicek = null,Object? foto = freezed,}) {
  return _then(_KondisiItem(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,dicek: null == dicek ? _self.dicek : dicek // ignore: cast_nullable_to_non_nullable
as bool,foto: freezed == foto ? _self.foto : foto // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$HandoverChecklist {

 String get bookingId; TahapChecklist get tahap; List<KondisiItem> get daftarKondisi; bool get disetujuiPemilik; bool get disetujuiPenyewa; String? get catatan; DateTime? get disetujuiPemilikPada; DateTime? get disetujuiPenyewaPada;
/// Create a copy of HandoverChecklist
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HandoverChecklistCopyWith<HandoverChecklist> get copyWith => _$HandoverChecklistCopyWithImpl<HandoverChecklist>(this as HandoverChecklist, _$identity);

  /// Serializes this HandoverChecklist to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HandoverChecklist;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandoverChecklist&&(identical(other.bookingId, _this.bookingId) || other.bookingId == _this.bookingId)&&(identical(other.tahap, _this.tahap) || other.tahap == _this.tahap)&&const DeepCollectionEquality().equals(other.daftarKondisi, _this.daftarKondisi)&&(identical(other.disetujuiPemilik, _this.disetujuiPemilik) || other.disetujuiPemilik == _this.disetujuiPemilik)&&(identical(other.disetujuiPenyewa, _this.disetujuiPenyewa) || other.disetujuiPenyewa == _this.disetujuiPenyewa)&&(identical(other.catatan, _this.catatan) || other.catatan == _this.catatan)&&(identical(other.disetujuiPemilikPada, _this.disetujuiPemilikPada) || other.disetujuiPemilikPada == _this.disetujuiPemilikPada)&&(identical(other.disetujuiPenyewaPada, _this.disetujuiPenyewaPada) || other.disetujuiPenyewaPada == _this.disetujuiPenyewaPada));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HandoverChecklist;
  return Object.hash(runtimeType,_this.bookingId,_this.tahap,const DeepCollectionEquality().hash(_this.daftarKondisi),_this.disetujuiPemilik,_this.disetujuiPenyewa,_this.catatan,_this.disetujuiPemilikPada,_this.disetujuiPenyewaPada);
}

@override
String toString() {
  final _this = this as HandoverChecklist;
  return 'HandoverChecklist(bookingId: ${_this.bookingId}, tahap: ${_this.tahap}, daftarKondisi: ${_this.daftarKondisi}, disetujuiPemilik: ${_this.disetujuiPemilik}, disetujuiPenyewa: ${_this.disetujuiPenyewa}, catatan: ${_this.catatan}, disetujuiPemilikPada: ${_this.disetujuiPemilikPada}, disetujuiPenyewaPada: ${_this.disetujuiPenyewaPada})';
}


}

/// @nodoc
abstract mixin class $HandoverChecklistCopyWith<$Res>  {
  factory $HandoverChecklistCopyWith(HandoverChecklist value, $Res Function(HandoverChecklist) _then) = _$HandoverChecklistCopyWithImpl;
@useResult
$Res call({
 String bookingId, TahapChecklist tahap, List<KondisiItem> daftarKondisi, bool disetujuiPemilik, bool disetujuiPenyewa, String? catatan, DateTime? disetujuiPemilikPada, DateTime? disetujuiPenyewaPada
});




}
/// @nodoc
class _$HandoverChecklistCopyWithImpl<$Res>
    implements $HandoverChecklistCopyWith<$Res> {
  _$HandoverChecklistCopyWithImpl(this._self, this._then);

  final HandoverChecklist _self;
  final $Res Function(HandoverChecklist) _then;

/// Create a copy of HandoverChecklist
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingId = null,Object? tahap = null,Object? daftarKondisi = null,Object? disetujuiPemilik = null,Object? disetujuiPenyewa = null,Object? catatan = freezed,Object? disetujuiPemilikPada = freezed,Object? disetujuiPenyewaPada = freezed,}) {
  return _then(HandoverChecklist(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,tahap: null == tahap ? _self.tahap : tahap // ignore: cast_nullable_to_non_nullable
as TahapChecklist,daftarKondisi: null == daftarKondisi ? _self.daftarKondisi : daftarKondisi // ignore: cast_nullable_to_non_nullable
as List<KondisiItem>,disetujuiPemilik: null == disetujuiPemilik ? _self.disetujuiPemilik : disetujuiPemilik // ignore: cast_nullable_to_non_nullable
as bool,disetujuiPenyewa: null == disetujuiPenyewa ? _self.disetujuiPenyewa : disetujuiPenyewa // ignore: cast_nullable_to_non_nullable
as bool,catatan: freezed == catatan ? _self.catatan : catatan // ignore: cast_nullable_to_non_nullable
as String?,disetujuiPemilikPada: freezed == disetujuiPemilikPada ? _self.disetujuiPemilikPada : disetujuiPemilikPada // ignore: cast_nullable_to_non_nullable
as DateTime?,disetujuiPenyewaPada: freezed == disetujuiPenyewaPada ? _self.disetujuiPenyewaPada : disetujuiPenyewaPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HandoverChecklist].
extension HandoverChecklistPatterns on HandoverChecklist {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HandoverChecklist value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HandoverChecklist() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HandoverChecklist value)  $default,){
final _that = this;
switch (_that) {
case _HandoverChecklist():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HandoverChecklist value)?  $default,){
final _that = this;
switch (_that) {
case _HandoverChecklist() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bookingId,  TahapChecklist tahap,  List<KondisiItem> daftarKondisi,  bool disetujuiPemilik,  bool disetujuiPenyewa,  String? catatan,  DateTime? disetujuiPemilikPada,  DateTime? disetujuiPenyewaPada)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HandoverChecklist() when $default != null:
return $default(_that.bookingId,_that.tahap,_that.daftarKondisi,_that.disetujuiPemilik,_that.disetujuiPenyewa,_that.catatan,_that.disetujuiPemilikPada,_that.disetujuiPenyewaPada);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bookingId,  TahapChecklist tahap,  List<KondisiItem> daftarKondisi,  bool disetujuiPemilik,  bool disetujuiPenyewa,  String? catatan,  DateTime? disetujuiPemilikPada,  DateTime? disetujuiPenyewaPada)  $default,) {final _that = this;
switch (_that) {
case _HandoverChecklist():
return $default(_that.bookingId,_that.tahap,_that.daftarKondisi,_that.disetujuiPemilik,_that.disetujuiPenyewa,_that.catatan,_that.disetujuiPemilikPada,_that.disetujuiPenyewaPada);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bookingId,  TahapChecklist tahap,  List<KondisiItem> daftarKondisi,  bool disetujuiPemilik,  bool disetujuiPenyewa,  String? catatan,  DateTime? disetujuiPemilikPada,  DateTime? disetujuiPenyewaPada)?  $default,) {final _that = this;
switch (_that) {
case _HandoverChecklist() when $default != null:
return $default(_that.bookingId,_that.tahap,_that.daftarKondisi,_that.disetujuiPemilik,_that.disetujuiPenyewa,_that.catatan,_that.disetujuiPemilikPada,_that.disetujuiPenyewaPada);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HandoverChecklist extends HandoverChecklist {
  const _HandoverChecklist({required this.bookingId, required this.tahap,  List<KondisiItem> daftarKondisi = const <KondisiItem>[], this.disetujuiPemilik = false, this.disetujuiPenyewa = false, this.catatan, this.disetujuiPemilikPada, this.disetujuiPenyewaPada}): _daftarKondisi = daftarKondisi,super._();
  factory _HandoverChecklist.fromJson(Map<String, dynamic> json) => _$HandoverChecklistFromJson(json);

@override final  String bookingId;
@override final  TahapChecklist tahap;
 final  List<KondisiItem> _daftarKondisi;
@override@JsonKey() List<KondisiItem> get daftarKondisi {
  if (_daftarKondisi is EqualUnmodifiableListView) return _daftarKondisi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daftarKondisi);
}

@override@JsonKey() final  bool disetujuiPemilik;
@override@JsonKey() final  bool disetujuiPenyewa;
@override final  String? catatan;
@override final  DateTime? disetujuiPemilikPada;
@override final  DateTime? disetujuiPenyewaPada;

/// Create a copy of HandoverChecklist
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandoverChecklistCopyWith<_HandoverChecklist> get copyWith => __$HandoverChecklistCopyWithImpl<_HandoverChecklist>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HandoverChecklistToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandoverChecklist&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.tahap, tahap) || other.tahap == tahap)&&const DeepCollectionEquality().equals(other.daftarKondisi, _daftarKondisi)&&(identical(other.disetujuiPemilik, disetujuiPemilik) || other.disetujuiPemilik == disetujuiPemilik)&&(identical(other.disetujuiPenyewa, disetujuiPenyewa) || other.disetujuiPenyewa == disetujuiPenyewa)&&(identical(other.catatan, catatan) || other.catatan == catatan)&&(identical(other.disetujuiPemilikPada, disetujuiPemilikPada) || other.disetujuiPemilikPada == disetujuiPemilikPada)&&(identical(other.disetujuiPenyewaPada, disetujuiPenyewaPada) || other.disetujuiPenyewaPada == disetujuiPenyewaPada));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,bookingId,tahap,const DeepCollectionEquality().hash(_daftarKondisi),disetujuiPemilik,disetujuiPenyewa,catatan,disetujuiPemilikPada,disetujuiPenyewaPada);
}

@override
String toString() {
    return 'HandoverChecklist(bookingId: $bookingId, tahap: $tahap, daftarKondisi: $daftarKondisi, disetujuiPemilik: $disetujuiPemilik, disetujuiPenyewa: $disetujuiPenyewa, catatan: $catatan, disetujuiPemilikPada: $disetujuiPemilikPada, disetujuiPenyewaPada: $disetujuiPenyewaPada)';
}


}

/// @nodoc
abstract mixin class _$HandoverChecklistCopyWith<$Res> implements $HandoverChecklistCopyWith<$Res> {
  factory _$HandoverChecklistCopyWith(_HandoverChecklist value, $Res Function(_HandoverChecklist) _then) = __$HandoverChecklistCopyWithImpl;
@override @useResult
$Res call({
 String bookingId, TahapChecklist tahap, List<KondisiItem> daftarKondisi, bool disetujuiPemilik, bool disetujuiPenyewa, String? catatan, DateTime? disetujuiPemilikPada, DateTime? disetujuiPenyewaPada
});




}
/// @nodoc
class __$HandoverChecklistCopyWithImpl<$Res>
    implements _$HandoverChecklistCopyWith<$Res> {
  __$HandoverChecklistCopyWithImpl(this._self, this._then);

  final _HandoverChecklist _self;
  final $Res Function(_HandoverChecklist) _then;

/// Create a copy of HandoverChecklist
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? tahap = null,Object? daftarKondisi = null,Object? disetujuiPemilik = null,Object? disetujuiPenyewa = null,Object? catatan = freezed,Object? disetujuiPemilikPada = freezed,Object? disetujuiPenyewaPada = freezed,}) {
  return _then(_HandoverChecklist(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,tahap: null == tahap ? _self.tahap : tahap // ignore: cast_nullable_to_non_nullable
as TahapChecklist,daftarKondisi: null == daftarKondisi ? _self._daftarKondisi : daftarKondisi // ignore: cast_nullable_to_non_nullable
as List<KondisiItem>,disetujuiPemilik: null == disetujuiPemilik ? _self.disetujuiPemilik : disetujuiPemilik // ignore: cast_nullable_to_non_nullable
as bool,disetujuiPenyewa: null == disetujuiPenyewa ? _self.disetujuiPenyewa : disetujuiPenyewa // ignore: cast_nullable_to_non_nullable
as bool,catatan: freezed == catatan ? _self.catatan : catatan // ignore: cast_nullable_to_non_nullable
as String?,disetujuiPemilikPada: freezed == disetujuiPemilikPada ? _self.disetujuiPemilikPada : disetujuiPemilikPada // ignore: cast_nullable_to_non_nullable
as DateTime?,disetujuiPenyewaPada: freezed == disetujuiPenyewaPada ? _self.disetujuiPenyewaPada : disetujuiPenyewaPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

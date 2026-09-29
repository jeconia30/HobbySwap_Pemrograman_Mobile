// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RentangTanggal {

 DateTime get mulai; DateTime get selesai;
/// Create a copy of RentangTanggal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RentangTanggalCopyWith<RentangTanggal> get copyWith => _$RentangTanggalCopyWithImpl<RentangTanggal>(this as RentangTanggal, _$identity);

  /// Serializes this RentangTanggal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RentangTanggal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RentangTanggal&&(identical(other.mulai, _this.mulai) || other.mulai == _this.mulai)&&(identical(other.selesai, _this.selesai) || other.selesai == _this.selesai));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RentangTanggal;
  return Object.hash(runtimeType,_this.mulai,_this.selesai);
}

@override
String toString() {
  final _this = this as RentangTanggal;
  return 'RentangTanggal(mulai: ${_this.mulai}, selesai: ${_this.selesai})';
}


}

/// @nodoc
abstract mixin class $RentangTanggalCopyWith<$Res>  {
  factory $RentangTanggalCopyWith(RentangTanggal value, $Res Function(RentangTanggal) _then) = _$RentangTanggalCopyWithImpl;
@useResult
$Res call({
 DateTime mulai, DateTime selesai
});




}
/// @nodoc
class _$RentangTanggalCopyWithImpl<$Res>
    implements $RentangTanggalCopyWith<$Res> {
  _$RentangTanggalCopyWithImpl(this._self, this._then);

  final RentangTanggal _self;
  final $Res Function(RentangTanggal) _then;

/// Create a copy of RentangTanggal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mulai = null,Object? selesai = null,}) {
  return _then(RentangTanggal(
mulai: null == mulai ? _self.mulai : mulai // ignore: cast_nullable_to_non_nullable
as DateTime,selesai: null == selesai ? _self.selesai : selesai // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RentangTanggal].
extension RentangTanggalPatterns on RentangTanggal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RentangTanggal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RentangTanggal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RentangTanggal value)  $default,){
final _that = this;
switch (_that) {
case _RentangTanggal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RentangTanggal value)?  $default,){
final _that = this;
switch (_that) {
case _RentangTanggal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime mulai,  DateTime selesai)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RentangTanggal() when $default != null:
return $default(_that.mulai,_that.selesai);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime mulai,  DateTime selesai)  $default,) {final _that = this;
switch (_that) {
case _RentangTanggal():
return $default(_that.mulai,_that.selesai);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime mulai,  DateTime selesai)?  $default,) {final _that = this;
switch (_that) {
case _RentangTanggal() when $default != null:
return $default(_that.mulai,_that.selesai);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RentangTanggal implements RentangTanggal {
  const _RentangTanggal({required this.mulai, required this.selesai});
  factory _RentangTanggal.fromJson(Map<String, dynamic> json) => _$RentangTanggalFromJson(json);

@override final  DateTime mulai;
@override final  DateTime selesai;

/// Create a copy of RentangTanggal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RentangTanggalCopyWith<_RentangTanggal> get copyWith => __$RentangTanggalCopyWithImpl<_RentangTanggal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RentangTanggalToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RentangTanggal&&(identical(other.mulai, mulai) || other.mulai == mulai)&&(identical(other.selesai, selesai) || other.selesai == selesai));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,mulai,selesai);
}

@override
String toString() {
    return 'RentangTanggal(mulai: $mulai, selesai: $selesai)';
}


}

/// @nodoc
abstract mixin class _$RentangTanggalCopyWith<$Res> implements $RentangTanggalCopyWith<$Res> {
  factory _$RentangTanggalCopyWith(_RentangTanggal value, $Res Function(_RentangTanggal) _then) = __$RentangTanggalCopyWithImpl;
@override @useResult
$Res call({
 DateTime mulai, DateTime selesai
});




}
/// @nodoc
class __$RentangTanggalCopyWithImpl<$Res>
    implements _$RentangTanggalCopyWith<$Res> {
  __$RentangTanggalCopyWithImpl(this._self, this._then);

  final _RentangTanggal _self;
  final $Res Function(_RentangTanggal) _then;

/// Create a copy of RentangTanggal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mulai = null,Object? selesai = null,}) {
  return _then(_RentangTanggal(
mulai: null == mulai ? _self.mulai : mulai // ignore: cast_nullable_to_non_nullable
as DateTime,selesai: null == selesai ? _self.selesai : selesai // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Item {

 String get id; String get ownerId; String get judul; String get deskripsi; Kategori get kategori; int get hargaPerHari; List<String> get daftarFoto; String get lokasiKampus; List<RentangTanggal> get rentangTidakTersedia; int get jumlahDisewa;/// Diatur pemilik; `false` = tidak tampil di Beranda & tidak bisa disewa.
 bool get aktif;/// Denda keterlambatan per hari (Rp); 0 = tanpa denda (M10).
 int get dendaPerHari;/// Pemilik menerima tawaran barter (tukar pinjam sementara, M11).
 bool get bisaBarter;/// Kategori barang yang dicari pemilik untuk barter.
 List<Kategori> get minatBarter;
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemCopyWith<Item> get copyWith => _$ItemCopyWithImpl<Item>(this as Item, _$identity);

  /// Serializes this Item to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Item;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Item&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.ownerId, _this.ownerId) || other.ownerId == _this.ownerId)&&(identical(other.judul, _this.judul) || other.judul == _this.judul)&&(identical(other.deskripsi, _this.deskripsi) || other.deskripsi == _this.deskripsi)&&(identical(other.kategori, _this.kategori) || other.kategori == _this.kategori)&&(identical(other.hargaPerHari, _this.hargaPerHari) || other.hargaPerHari == _this.hargaPerHari)&&const DeepCollectionEquality().equals(other.daftarFoto, _this.daftarFoto)&&(identical(other.lokasiKampus, _this.lokasiKampus) || other.lokasiKampus == _this.lokasiKampus)&&const DeepCollectionEquality().equals(other.rentangTidakTersedia, _this.rentangTidakTersedia)&&(identical(other.jumlahDisewa, _this.jumlahDisewa) || other.jumlahDisewa == _this.jumlahDisewa)&&(identical(other.aktif, _this.aktif) || other.aktif == _this.aktif)&&(identical(other.dendaPerHari, _this.dendaPerHari) || other.dendaPerHari == _this.dendaPerHari)&&(identical(other.bisaBarter, _this.bisaBarter) || other.bisaBarter == _this.bisaBarter)&&const DeepCollectionEquality().equals(other.minatBarter, _this.minatBarter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Item;
  return Object.hash(runtimeType,_this.id,_this.ownerId,_this.judul,_this.deskripsi,_this.kategori,_this.hargaPerHari,const DeepCollectionEquality().hash(_this.daftarFoto),_this.lokasiKampus,const DeepCollectionEquality().hash(_this.rentangTidakTersedia),_this.jumlahDisewa,_this.aktif,_this.dendaPerHari,_this.bisaBarter,const DeepCollectionEquality().hash(_this.minatBarter));
}

@override
String toString() {
  final _this = this as Item;
  return 'Item(id: ${_this.id}, ownerId: ${_this.ownerId}, judul: ${_this.judul}, deskripsi: ${_this.deskripsi}, kategori: ${_this.kategori}, hargaPerHari: ${_this.hargaPerHari}, daftarFoto: ${_this.daftarFoto}, lokasiKampus: ${_this.lokasiKampus}, rentangTidakTersedia: ${_this.rentangTidakTersedia}, jumlahDisewa: ${_this.jumlahDisewa}, aktif: ${_this.aktif}, dendaPerHari: ${_this.dendaPerHari}, bisaBarter: ${_this.bisaBarter}, minatBarter: ${_this.minatBarter})';
}


}

/// @nodoc
abstract mixin class $ItemCopyWith<$Res>  {
  factory $ItemCopyWith(Item value, $Res Function(Item) _then) = _$ItemCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String judul, String deskripsi, Kategori kategori, int hargaPerHari, List<String> daftarFoto, String lokasiKampus, List<RentangTanggal> rentangTidakTersedia, int jumlahDisewa, bool aktif, int dendaPerHari, bool bisaBarter, List<Kategori> minatBarter
});




}
/// @nodoc
class _$ItemCopyWithImpl<$Res>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._self, this._then);

  final Item _self;
  final $Res Function(Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? judul = null,Object? deskripsi = null,Object? kategori = null,Object? hargaPerHari = null,Object? daftarFoto = null,Object? lokasiKampus = null,Object? rentangTidakTersedia = null,Object? jumlahDisewa = null,Object? aktif = null,Object? dendaPerHari = null,Object? bisaBarter = null,Object? minatBarter = null,}) {
  return _then(Item(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,judul: null == judul ? _self.judul : judul // ignore: cast_nullable_to_non_nullable
as String,deskripsi: null == deskripsi ? _self.deskripsi : deskripsi // ignore: cast_nullable_to_non_nullable
as String,kategori: null == kategori ? _self.kategori : kategori // ignore: cast_nullable_to_non_nullable
as Kategori,hargaPerHari: null == hargaPerHari ? _self.hargaPerHari : hargaPerHari // ignore: cast_nullable_to_non_nullable
as int,daftarFoto: null == daftarFoto ? _self.daftarFoto : daftarFoto // ignore: cast_nullable_to_non_nullable
as List<String>,lokasiKampus: null == lokasiKampus ? _self.lokasiKampus : lokasiKampus // ignore: cast_nullable_to_non_nullable
as String,rentangTidakTersedia: null == rentangTidakTersedia ? _self.rentangTidakTersedia : rentangTidakTersedia // ignore: cast_nullable_to_non_nullable
as List<RentangTanggal>,jumlahDisewa: null == jumlahDisewa ? _self.jumlahDisewa : jumlahDisewa // ignore: cast_nullable_to_non_nullable
as int,aktif: null == aktif ? _self.aktif : aktif // ignore: cast_nullable_to_non_nullable
as bool,dendaPerHari: null == dendaPerHari ? _self.dendaPerHari : dendaPerHari // ignore: cast_nullable_to_non_nullable
as int,bisaBarter: null == bisaBarter ? _self.bisaBarter : bisaBarter // ignore: cast_nullable_to_non_nullable
as bool,minatBarter: null == minatBarter ? _self.minatBarter : minatBarter // ignore: cast_nullable_to_non_nullable
as List<Kategori>,
  ));
}

}


/// Adds pattern-matching-related methods to [Item].
extension ItemPatterns on Item {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Item value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Item value)  $default,){
final _that = this;
switch (_that) {
case _Item():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Item value)?  $default,){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String judul,  String deskripsi,  Kategori kategori,  int hargaPerHari,  List<String> daftarFoto,  String lokasiKampus,  List<RentangTanggal> rentangTidakTersedia,  int jumlahDisewa,  bool aktif,  int dendaPerHari,  bool bisaBarter,  List<Kategori> minatBarter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.ownerId,_that.judul,_that.deskripsi,_that.kategori,_that.hargaPerHari,_that.daftarFoto,_that.lokasiKampus,_that.rentangTidakTersedia,_that.jumlahDisewa,_that.aktif,_that.dendaPerHari,_that.bisaBarter,_that.minatBarter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String judul,  String deskripsi,  Kategori kategori,  int hargaPerHari,  List<String> daftarFoto,  String lokasiKampus,  List<RentangTanggal> rentangTidakTersedia,  int jumlahDisewa,  bool aktif,  int dendaPerHari,  bool bisaBarter,  List<Kategori> minatBarter)  $default,) {final _that = this;
switch (_that) {
case _Item():
return $default(_that.id,_that.ownerId,_that.judul,_that.deskripsi,_that.kategori,_that.hargaPerHari,_that.daftarFoto,_that.lokasiKampus,_that.rentangTidakTersedia,_that.jumlahDisewa,_that.aktif,_that.dendaPerHari,_that.bisaBarter,_that.minatBarter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String judul,  String deskripsi,  Kategori kategori,  int hargaPerHari,  List<String> daftarFoto,  String lokasiKampus,  List<RentangTanggal> rentangTidakTersedia,  int jumlahDisewa,  bool aktif,  int dendaPerHari,  bool bisaBarter,  List<Kategori> minatBarter)?  $default,) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.ownerId,_that.judul,_that.deskripsi,_that.kategori,_that.hargaPerHari,_that.daftarFoto,_that.lokasiKampus,_that.rentangTidakTersedia,_that.jumlahDisewa,_that.aktif,_that.dendaPerHari,_that.bisaBarter,_that.minatBarter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Item implements Item {
  const _Item({required this.id, required this.ownerId, required this.judul, required this.deskripsi, required this.kategori, required this.hargaPerHari,  List<String> daftarFoto = const <String>[], required this.lokasiKampus,  List<RentangTanggal> rentangTidakTersedia = const <RentangTanggal>[], this.jumlahDisewa = 0, this.aktif = true, this.dendaPerHari = 0, this.bisaBarter = false,  List<Kategori> minatBarter = const <Kategori>[]}): _daftarFoto = daftarFoto,_rentangTidakTersedia = rentangTidakTersedia,_minatBarter = minatBarter;
  factory _Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

@override final  String id;
@override final  String ownerId;
@override final  String judul;
@override final  String deskripsi;
@override final  Kategori kategori;
@override final  int hargaPerHari;
 final  List<String> _daftarFoto;
@override@JsonKey() List<String> get daftarFoto {
  if (_daftarFoto is EqualUnmodifiableListView) return _daftarFoto;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daftarFoto);
}

@override final  String lokasiKampus;
 final  List<RentangTanggal> _rentangTidakTersedia;
@override@JsonKey() List<RentangTanggal> get rentangTidakTersedia {
  if (_rentangTidakTersedia is EqualUnmodifiableListView) return _rentangTidakTersedia;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rentangTidakTersedia);
}

@override@JsonKey() final  int jumlahDisewa;
/// Diatur pemilik; `false` = tidak tampil di Beranda & tidak bisa disewa.
@override@JsonKey() final  bool aktif;
/// Denda keterlambatan per hari (Rp); 0 = tanpa denda (M10).
@override@JsonKey() final  int dendaPerHari;
/// Pemilik menerima tawaran barter (tukar pinjam sementara, M11).
@override@JsonKey() final  bool bisaBarter;
/// Kategori barang yang dicari pemilik untuk barter.
 final  List<Kategori> _minatBarter;
/// Kategori barang yang dicari pemilik untuk barter.
@override@JsonKey() List<Kategori> get minatBarter {
  if (_minatBarter is EqualUnmodifiableListView) return _minatBarter;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_minatBarter);
}


/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemCopyWith<_Item> get copyWith => __$ItemCopyWithImpl<_Item>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Item&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.judul, judul) || other.judul == judul)&&(identical(other.deskripsi, deskripsi) || other.deskripsi == deskripsi)&&(identical(other.kategori, kategori) || other.kategori == kategori)&&(identical(other.hargaPerHari, hargaPerHari) || other.hargaPerHari == hargaPerHari)&&const DeepCollectionEquality().equals(other.daftarFoto, _daftarFoto)&&(identical(other.lokasiKampus, lokasiKampus) || other.lokasiKampus == lokasiKampus)&&const DeepCollectionEquality().equals(other.rentangTidakTersedia, _rentangTidakTersedia)&&(identical(other.jumlahDisewa, jumlahDisewa) || other.jumlahDisewa == jumlahDisewa)&&(identical(other.aktif, aktif) || other.aktif == aktif)&&(identical(other.dendaPerHari, dendaPerHari) || other.dendaPerHari == dendaPerHari)&&(identical(other.bisaBarter, bisaBarter) || other.bisaBarter == bisaBarter)&&const DeepCollectionEquality().equals(other.minatBarter, _minatBarter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,ownerId,judul,deskripsi,kategori,hargaPerHari,const DeepCollectionEquality().hash(_daftarFoto),lokasiKampus,const DeepCollectionEquality().hash(_rentangTidakTersedia),jumlahDisewa,aktif,dendaPerHari,bisaBarter,const DeepCollectionEquality().hash(_minatBarter));
}

@override
String toString() {
    return 'Item(id: $id, ownerId: $ownerId, judul: $judul, deskripsi: $deskripsi, kategori: $kategori, hargaPerHari: $hargaPerHari, daftarFoto: $daftarFoto, lokasiKampus: $lokasiKampus, rentangTidakTersedia: $rentangTidakTersedia, jumlahDisewa: $jumlahDisewa, aktif: $aktif, dendaPerHari: $dendaPerHari, bisaBarter: $bisaBarter, minatBarter: $minatBarter)';
}


}

/// @nodoc
abstract mixin class _$ItemCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$ItemCopyWith(_Item value, $Res Function(_Item) _then) = __$ItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String judul, String deskripsi, Kategori kategori, int hargaPerHari, List<String> daftarFoto, String lokasiKampus, List<RentangTanggal> rentangTidakTersedia, int jumlahDisewa, bool aktif, int dendaPerHari, bool bisaBarter, List<Kategori> minatBarter
});




}
/// @nodoc
class __$ItemCopyWithImpl<$Res>
    implements _$ItemCopyWith<$Res> {
  __$ItemCopyWithImpl(this._self, this._then);

  final _Item _self;
  final $Res Function(_Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? judul = null,Object? deskripsi = null,Object? kategori = null,Object? hargaPerHari = null,Object? daftarFoto = null,Object? lokasiKampus = null,Object? rentangTidakTersedia = null,Object? jumlahDisewa = null,Object? aktif = null,Object? dendaPerHari = null,Object? bisaBarter = null,Object? minatBarter = null,}) {
  return _then(_Item(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,judul: null == judul ? _self.judul : judul // ignore: cast_nullable_to_non_nullable
as String,deskripsi: null == deskripsi ? _self.deskripsi : deskripsi // ignore: cast_nullable_to_non_nullable
as String,kategori: null == kategori ? _self.kategori : kategori // ignore: cast_nullable_to_non_nullable
as Kategori,hargaPerHari: null == hargaPerHari ? _self.hargaPerHari : hargaPerHari // ignore: cast_nullable_to_non_nullable
as int,daftarFoto: null == daftarFoto ? _self._daftarFoto : daftarFoto // ignore: cast_nullable_to_non_nullable
as List<String>,lokasiKampus: null == lokasiKampus ? _self.lokasiKampus : lokasiKampus // ignore: cast_nullable_to_non_nullable
as String,rentangTidakTersedia: null == rentangTidakTersedia ? _self._rentangTidakTersedia : rentangTidakTersedia // ignore: cast_nullable_to_non_nullable
as List<RentangTanggal>,jumlahDisewa: null == jumlahDisewa ? _self.jumlahDisewa : jumlahDisewa // ignore: cast_nullable_to_non_nullable
as int,aktif: null == aktif ? _self.aktif : aktif // ignore: cast_nullable_to_non_nullable
as bool,dendaPerHari: null == dendaPerHari ? _self.dendaPerHari : dendaPerHari // ignore: cast_nullable_to_non_nullable
as int,bisaBarter: null == bisaBarter ? _self.bisaBarter : bisaBarter // ignore: cast_nullable_to_non_nullable
as bool,minatBarter: null == minatBarter ? _self._minatBarter : minatBarter // ignore: cast_nullable_to_non_nullable
as List<Kategori>,
  ));
}


}

// dart format on

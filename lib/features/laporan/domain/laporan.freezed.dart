// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'laporan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RiwayatLaporan {

 DateTime get waktu; String get judul; String? get isi; String? get olehUserId;
/// Create a copy of RiwayatLaporan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RiwayatLaporanCopyWith<RiwayatLaporan> get copyWith => _$RiwayatLaporanCopyWithImpl<RiwayatLaporan>(this as RiwayatLaporan, _$identity);

  /// Serializes this RiwayatLaporan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RiwayatLaporan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RiwayatLaporan&&(identical(other.waktu, _this.waktu) || other.waktu == _this.waktu)&&(identical(other.judul, _this.judul) || other.judul == _this.judul)&&(identical(other.isi, _this.isi) || other.isi == _this.isi)&&(identical(other.olehUserId, _this.olehUserId) || other.olehUserId == _this.olehUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RiwayatLaporan;
  return Object.hash(runtimeType,_this.waktu,_this.judul,_this.isi,_this.olehUserId);
}

@override
String toString() {
  final _this = this as RiwayatLaporan;
  return 'RiwayatLaporan(waktu: ${_this.waktu}, judul: ${_this.judul}, isi: ${_this.isi}, olehUserId: ${_this.olehUserId})';
}


}

/// @nodoc
abstract mixin class $RiwayatLaporanCopyWith<$Res>  {
  factory $RiwayatLaporanCopyWith(RiwayatLaporan value, $Res Function(RiwayatLaporan) _then) = _$RiwayatLaporanCopyWithImpl;
@useResult
$Res call({
 DateTime waktu, String judul, String? isi, String? olehUserId
});




}
/// @nodoc
class _$RiwayatLaporanCopyWithImpl<$Res>
    implements $RiwayatLaporanCopyWith<$Res> {
  _$RiwayatLaporanCopyWithImpl(this._self, this._then);

  final RiwayatLaporan _self;
  final $Res Function(RiwayatLaporan) _then;

/// Create a copy of RiwayatLaporan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? waktu = null,Object? judul = null,Object? isi = freezed,Object? olehUserId = freezed,}) {
  return _then(RiwayatLaporan(
waktu: null == waktu ? _self.waktu : waktu // ignore: cast_nullable_to_non_nullable
as DateTime,judul: null == judul ? _self.judul : judul // ignore: cast_nullable_to_non_nullable
as String,isi: freezed == isi ? _self.isi : isi // ignore: cast_nullable_to_non_nullable
as String?,olehUserId: freezed == olehUserId ? _self.olehUserId : olehUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RiwayatLaporan].
extension RiwayatLaporanPatterns on RiwayatLaporan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RiwayatLaporan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RiwayatLaporan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RiwayatLaporan value)  $default,){
final _that = this;
switch (_that) {
case _RiwayatLaporan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RiwayatLaporan value)?  $default,){
final _that = this;
switch (_that) {
case _RiwayatLaporan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime waktu,  String judul,  String? isi,  String? olehUserId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RiwayatLaporan() when $default != null:
return $default(_that.waktu,_that.judul,_that.isi,_that.olehUserId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime waktu,  String judul,  String? isi,  String? olehUserId)  $default,) {final _that = this;
switch (_that) {
case _RiwayatLaporan():
return $default(_that.waktu,_that.judul,_that.isi,_that.olehUserId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime waktu,  String judul,  String? isi,  String? olehUserId)?  $default,) {final _that = this;
switch (_that) {
case _RiwayatLaporan() when $default != null:
return $default(_that.waktu,_that.judul,_that.isi,_that.olehUserId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RiwayatLaporan implements RiwayatLaporan {
  const _RiwayatLaporan({required this.waktu, required this.judul, this.isi, this.olehUserId});
  factory _RiwayatLaporan.fromJson(Map<String, dynamic> json) => _$RiwayatLaporanFromJson(json);

@override final  DateTime waktu;
@override final  String judul;
@override final  String? isi;
@override final  String? olehUserId;

/// Create a copy of RiwayatLaporan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RiwayatLaporanCopyWith<_RiwayatLaporan> get copyWith => __$RiwayatLaporanCopyWithImpl<_RiwayatLaporan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RiwayatLaporanToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RiwayatLaporan&&(identical(other.waktu, waktu) || other.waktu == waktu)&&(identical(other.judul, judul) || other.judul == judul)&&(identical(other.isi, isi) || other.isi == isi)&&(identical(other.olehUserId, olehUserId) || other.olehUserId == olehUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,waktu,judul,isi,olehUserId);
}

@override
String toString() {
    return 'RiwayatLaporan(waktu: $waktu, judul: $judul, isi: $isi, olehUserId: $olehUserId)';
}


}

/// @nodoc
abstract mixin class _$RiwayatLaporanCopyWith<$Res> implements $RiwayatLaporanCopyWith<$Res> {
  factory _$RiwayatLaporanCopyWith(_RiwayatLaporan value, $Res Function(_RiwayatLaporan) _then) = __$RiwayatLaporanCopyWithImpl;
@override @useResult
$Res call({
 DateTime waktu, String judul, String? isi, String? olehUserId
});




}
/// @nodoc
class __$RiwayatLaporanCopyWithImpl<$Res>
    implements _$RiwayatLaporanCopyWith<$Res> {
  __$RiwayatLaporanCopyWithImpl(this._self, this._then);

  final _RiwayatLaporan _self;
  final $Res Function(_RiwayatLaporan) _then;

/// Create a copy of RiwayatLaporan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? waktu = null,Object? judul = null,Object? isi = freezed,Object? olehUserId = freezed,}) {
  return _then(_RiwayatLaporan(
waktu: null == waktu ? _self.waktu : waktu // ignore: cast_nullable_to_non_nullable
as DateTime,judul: null == judul ? _self.judul : judul // ignore: cast_nullable_to_non_nullable
as String,isi: freezed == isi ? _self.isi : isi // ignore: cast_nullable_to_non_nullable
as String?,olehUserId: freezed == olehUserId ? _self.olehUserId : olehUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Laporan {

 String get id; String? get bookingId; String get pelaporId; String get terlaporId; JenisLaporan get jenis;/// Label item checklist yang bermasalah (laporan kerusakan).
 List<String> get itemChecklistBermasalah; String get deskripsi;/// Foto bukti (simulasi) dari checklist pengembalian.
 List<String> get fotoBukti; UsulanPenyelesaian? get usulan;/// Nominal ganti rugi (Rp) bila [usulan] = ganti rugi.
 int? get nominal; StatusLaporan get status; List<RiwayatLaporan> get riwayat; DateTime get dibuatPada;
/// Create a copy of Laporan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LaporanCopyWith<Laporan> get copyWith => _$LaporanCopyWithImpl<Laporan>(this as Laporan, _$identity);

  /// Serializes this Laporan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Laporan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Laporan&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.bookingId, _this.bookingId) || other.bookingId == _this.bookingId)&&(identical(other.pelaporId, _this.pelaporId) || other.pelaporId == _this.pelaporId)&&(identical(other.terlaporId, _this.terlaporId) || other.terlaporId == _this.terlaporId)&&(identical(other.jenis, _this.jenis) || other.jenis == _this.jenis)&&const DeepCollectionEquality().equals(other.itemChecklistBermasalah, _this.itemChecklistBermasalah)&&(identical(other.deskripsi, _this.deskripsi) || other.deskripsi == _this.deskripsi)&&const DeepCollectionEquality().equals(other.fotoBukti, _this.fotoBukti)&&(identical(other.usulan, _this.usulan) || other.usulan == _this.usulan)&&(identical(other.nominal, _this.nominal) || other.nominal == _this.nominal)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.riwayat, _this.riwayat)&&(identical(other.dibuatPada, _this.dibuatPada) || other.dibuatPada == _this.dibuatPada));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Laporan;
  return Object.hash(runtimeType,_this.id,_this.bookingId,_this.pelaporId,_this.terlaporId,_this.jenis,const DeepCollectionEquality().hash(_this.itemChecklistBermasalah),_this.deskripsi,const DeepCollectionEquality().hash(_this.fotoBukti),_this.usulan,_this.nominal,_this.status,const DeepCollectionEquality().hash(_this.riwayat),_this.dibuatPada);
}

@override
String toString() {
  final _this = this as Laporan;
  return 'Laporan(id: ${_this.id}, bookingId: ${_this.bookingId}, pelaporId: ${_this.pelaporId}, terlaporId: ${_this.terlaporId}, jenis: ${_this.jenis}, itemChecklistBermasalah: ${_this.itemChecklistBermasalah}, deskripsi: ${_this.deskripsi}, fotoBukti: ${_this.fotoBukti}, usulan: ${_this.usulan}, nominal: ${_this.nominal}, status: ${_this.status}, riwayat: ${_this.riwayat}, dibuatPada: ${_this.dibuatPada})';
}


}

/// @nodoc
abstract mixin class $LaporanCopyWith<$Res>  {
  factory $LaporanCopyWith(Laporan value, $Res Function(Laporan) _then) = _$LaporanCopyWithImpl;
@useResult
$Res call({
 String id, String? bookingId, String pelaporId, String terlaporId, JenisLaporan jenis, List<String> itemChecklistBermasalah, String deskripsi, List<String> fotoBukti, UsulanPenyelesaian? usulan, int? nominal, StatusLaporan status, List<RiwayatLaporan> riwayat, DateTime dibuatPada
});




}
/// @nodoc
class _$LaporanCopyWithImpl<$Res>
    implements $LaporanCopyWith<$Res> {
  _$LaporanCopyWithImpl(this._self, this._then);

  final Laporan _self;
  final $Res Function(Laporan) _then;

/// Create a copy of Laporan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookingId = freezed,Object? pelaporId = null,Object? terlaporId = null,Object? jenis = null,Object? itemChecklistBermasalah = null,Object? deskripsi = null,Object? fotoBukti = null,Object? usulan = freezed,Object? nominal = freezed,Object? status = null,Object? riwayat = null,Object? dibuatPada = null,}) {
  return _then(Laporan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,pelaporId: null == pelaporId ? _self.pelaporId : pelaporId // ignore: cast_nullable_to_non_nullable
as String,terlaporId: null == terlaporId ? _self.terlaporId : terlaporId // ignore: cast_nullable_to_non_nullable
as String,jenis: null == jenis ? _self.jenis : jenis // ignore: cast_nullable_to_non_nullable
as JenisLaporan,itemChecklistBermasalah: null == itemChecklistBermasalah ? _self.itemChecklistBermasalah : itemChecklistBermasalah // ignore: cast_nullable_to_non_nullable
as List<String>,deskripsi: null == deskripsi ? _self.deskripsi : deskripsi // ignore: cast_nullable_to_non_nullable
as String,fotoBukti: null == fotoBukti ? _self.fotoBukti : fotoBukti // ignore: cast_nullable_to_non_nullable
as List<String>,usulan: freezed == usulan ? _self.usulan : usulan // ignore: cast_nullable_to_non_nullable
as UsulanPenyelesaian?,nominal: freezed == nominal ? _self.nominal : nominal // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StatusLaporan,riwayat: null == riwayat ? _self.riwayat : riwayat // ignore: cast_nullable_to_non_nullable
as List<RiwayatLaporan>,dibuatPada: null == dibuatPada ? _self.dibuatPada : dibuatPada // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Laporan].
extension LaporanPatterns on Laporan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Laporan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Laporan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Laporan value)  $default,){
final _that = this;
switch (_that) {
case _Laporan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Laporan value)?  $default,){
final _that = this;
switch (_that) {
case _Laporan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? bookingId,  String pelaporId,  String terlaporId,  JenisLaporan jenis,  List<String> itemChecklistBermasalah,  String deskripsi,  List<String> fotoBukti,  UsulanPenyelesaian? usulan,  int? nominal,  StatusLaporan status,  List<RiwayatLaporan> riwayat,  DateTime dibuatPada)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Laporan() when $default != null:
return $default(_that.id,_that.bookingId,_that.pelaporId,_that.terlaporId,_that.jenis,_that.itemChecklistBermasalah,_that.deskripsi,_that.fotoBukti,_that.usulan,_that.nominal,_that.status,_that.riwayat,_that.dibuatPada);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? bookingId,  String pelaporId,  String terlaporId,  JenisLaporan jenis,  List<String> itemChecklistBermasalah,  String deskripsi,  List<String> fotoBukti,  UsulanPenyelesaian? usulan,  int? nominal,  StatusLaporan status,  List<RiwayatLaporan> riwayat,  DateTime dibuatPada)  $default,) {final _that = this;
switch (_that) {
case _Laporan():
return $default(_that.id,_that.bookingId,_that.pelaporId,_that.terlaporId,_that.jenis,_that.itemChecklistBermasalah,_that.deskripsi,_that.fotoBukti,_that.usulan,_that.nominal,_that.status,_that.riwayat,_that.dibuatPada);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? bookingId,  String pelaporId,  String terlaporId,  JenisLaporan jenis,  List<String> itemChecklistBermasalah,  String deskripsi,  List<String> fotoBukti,  UsulanPenyelesaian? usulan,  int? nominal,  StatusLaporan status,  List<RiwayatLaporan> riwayat,  DateTime dibuatPada)?  $default,) {final _that = this;
switch (_that) {
case _Laporan() when $default != null:
return $default(_that.id,_that.bookingId,_that.pelaporId,_that.terlaporId,_that.jenis,_that.itemChecklistBermasalah,_that.deskripsi,_that.fotoBukti,_that.usulan,_that.nominal,_that.status,_that.riwayat,_that.dibuatPada);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Laporan implements Laporan {
  const _Laporan({required this.id, this.bookingId, required this.pelaporId, required this.terlaporId, required this.jenis,  List<String> itemChecklistBermasalah = const <String>[], required this.deskripsi,  List<String> fotoBukti = const <String>[], this.usulan, this.nominal, this.status = StatusLaporan.menungguTanggapan,  List<RiwayatLaporan> riwayat = const <RiwayatLaporan>[], required this.dibuatPada}): _itemChecklistBermasalah = itemChecklistBermasalah,_fotoBukti = fotoBukti,_riwayat = riwayat;
  factory _Laporan.fromJson(Map<String, dynamic> json) => _$LaporanFromJson(json);

@override final  String id;
@override final  String? bookingId;
@override final  String pelaporId;
@override final  String terlaporId;
@override final  JenisLaporan jenis;
/// Label item checklist yang bermasalah (laporan kerusakan).
 final  List<String> _itemChecklistBermasalah;
/// Label item checklist yang bermasalah (laporan kerusakan).
@override@JsonKey() List<String> get itemChecklistBermasalah {
  if (_itemChecklistBermasalah is EqualUnmodifiableListView) return _itemChecklistBermasalah;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itemChecklistBermasalah);
}

@override final  String deskripsi;
/// Foto bukti (simulasi) dari checklist pengembalian.
 final  List<String> _fotoBukti;
/// Foto bukti (simulasi) dari checklist pengembalian.
@override@JsonKey() List<String> get fotoBukti {
  if (_fotoBukti is EqualUnmodifiableListView) return _fotoBukti;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fotoBukti);
}

@override final  UsulanPenyelesaian? usulan;
/// Nominal ganti rugi (Rp) bila [usulan] = ganti rugi.
@override final  int? nominal;
@override@JsonKey() final  StatusLaporan status;
 final  List<RiwayatLaporan> _riwayat;
@override@JsonKey() List<RiwayatLaporan> get riwayat {
  if (_riwayat is EqualUnmodifiableListView) return _riwayat;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_riwayat);
}

@override final  DateTime dibuatPada;

/// Create a copy of Laporan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LaporanCopyWith<_Laporan> get copyWith => __$LaporanCopyWithImpl<_Laporan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LaporanToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Laporan&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.pelaporId, pelaporId) || other.pelaporId == pelaporId)&&(identical(other.terlaporId, terlaporId) || other.terlaporId == terlaporId)&&(identical(other.jenis, jenis) || other.jenis == jenis)&&const DeepCollectionEquality().equals(other.itemChecklistBermasalah, _itemChecklistBermasalah)&&(identical(other.deskripsi, deskripsi) || other.deskripsi == deskripsi)&&const DeepCollectionEquality().equals(other.fotoBukti, _fotoBukti)&&(identical(other.usulan, usulan) || other.usulan == usulan)&&(identical(other.nominal, nominal) || other.nominal == nominal)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.riwayat, _riwayat)&&(identical(other.dibuatPada, dibuatPada) || other.dibuatPada == dibuatPada));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,bookingId,pelaporId,terlaporId,jenis,const DeepCollectionEquality().hash(_itemChecklistBermasalah),deskripsi,const DeepCollectionEquality().hash(_fotoBukti),usulan,nominal,status,const DeepCollectionEquality().hash(_riwayat),dibuatPada);
}

@override
String toString() {
    return 'Laporan(id: $id, bookingId: $bookingId, pelaporId: $pelaporId, terlaporId: $terlaporId, jenis: $jenis, itemChecklistBermasalah: $itemChecklistBermasalah, deskripsi: $deskripsi, fotoBukti: $fotoBukti, usulan: $usulan, nominal: $nominal, status: $status, riwayat: $riwayat, dibuatPada: $dibuatPada)';
}


}

/// @nodoc
abstract mixin class _$LaporanCopyWith<$Res> implements $LaporanCopyWith<$Res> {
  factory _$LaporanCopyWith(_Laporan value, $Res Function(_Laporan) _then) = __$LaporanCopyWithImpl;
@override @useResult
$Res call({
 String id, String? bookingId, String pelaporId, String terlaporId, JenisLaporan jenis, List<String> itemChecklistBermasalah, String deskripsi, List<String> fotoBukti, UsulanPenyelesaian? usulan, int? nominal, StatusLaporan status, List<RiwayatLaporan> riwayat, DateTime dibuatPada
});




}
/// @nodoc
class __$LaporanCopyWithImpl<$Res>
    implements _$LaporanCopyWith<$Res> {
  __$LaporanCopyWithImpl(this._self, this._then);

  final _Laporan _self;
  final $Res Function(_Laporan) _then;

/// Create a copy of Laporan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookingId = freezed,Object? pelaporId = null,Object? terlaporId = null,Object? jenis = null,Object? itemChecklistBermasalah = null,Object? deskripsi = null,Object? fotoBukti = null,Object? usulan = freezed,Object? nominal = freezed,Object? status = null,Object? riwayat = null,Object? dibuatPada = null,}) {
  return _then(_Laporan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,pelaporId: null == pelaporId ? _self.pelaporId : pelaporId // ignore: cast_nullable_to_non_nullable
as String,terlaporId: null == terlaporId ? _self.terlaporId : terlaporId // ignore: cast_nullable_to_non_nullable
as String,jenis: null == jenis ? _self.jenis : jenis // ignore: cast_nullable_to_non_nullable
as JenisLaporan,itemChecklistBermasalah: null == itemChecklistBermasalah ? _self._itemChecklistBermasalah : itemChecklistBermasalah // ignore: cast_nullable_to_non_nullable
as List<String>,deskripsi: null == deskripsi ? _self.deskripsi : deskripsi // ignore: cast_nullable_to_non_nullable
as String,fotoBukti: null == fotoBukti ? _self._fotoBukti : fotoBukti // ignore: cast_nullable_to_non_nullable
as List<String>,usulan: freezed == usulan ? _self.usulan : usulan // ignore: cast_nullable_to_non_nullable
as UsulanPenyelesaian?,nominal: freezed == nominal ? _self.nominal : nominal // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StatusLaporan,riwayat: null == riwayat ? _self._riwayat : riwayat // ignore: cast_nullable_to_non_nullable
as List<RiwayatLaporan>,dibuatPada: null == dibuatPada ? _self.dibuatPada : dibuatPada // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

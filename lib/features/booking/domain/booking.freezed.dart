// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Booking {

 String get id; String get itemId; String get penyewaId; DateTime get tanggalMulai; DateTime get tanggalKembali; int get totalHarga; StatusBooking get status; String? get pesan; DateTime get dibuatPada;/// Diisi pemilik saat menolak (atau sistem saat auto-tolak).
 String? get alasanTolak;/// Dibayar langsung ke pemilik saat serah terima (COD), dicatat pemilik
/// di checklist awal (M10).
 StatusBayar get statusBayar; MetodeBayar? get metodeBayar; DateTime? get dibayarPada;/// Denda keterlambatan yang diterima pemilik di checklist akhir (Rp).
 int get dendaTerlambat;/// Id user yang membatalkan (penyewa atau pemilik).
 String? get dibatalkanOleh; String? get alasanBatal;/// M11: barter = kedua pihak saling meminjamkan barang pada tanggal yang
/// sama; [totalHarga] 0 dan tanpa pembayaran.
 JenisTransaksi get jenis;/// Barang milik pengaju ([penyewaId]) yang ditawarkan untuk barter.
 String? get itemTawaranId;/// Pemilik meminta barang lain (counter); menunggu tanggapan pengaju.
 bool get perluTanggapanPengaju;/// Denda telat barang tawaran (barter) yang diterima pengaju (Rp).
 int get dendaTawaran;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Booking;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.itemId, _this.itemId) || other.itemId == _this.itemId)&&(identical(other.penyewaId, _this.penyewaId) || other.penyewaId == _this.penyewaId)&&(identical(other.tanggalMulai, _this.tanggalMulai) || other.tanggalMulai == _this.tanggalMulai)&&(identical(other.tanggalKembali, _this.tanggalKembali) || other.tanggalKembali == _this.tanggalKembali)&&(identical(other.totalHarga, _this.totalHarga) || other.totalHarga == _this.totalHarga)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.pesan, _this.pesan) || other.pesan == _this.pesan)&&(identical(other.dibuatPada, _this.dibuatPada) || other.dibuatPada == _this.dibuatPada)&&(identical(other.alasanTolak, _this.alasanTolak) || other.alasanTolak == _this.alasanTolak)&&(identical(other.statusBayar, _this.statusBayar) || other.statusBayar == _this.statusBayar)&&(identical(other.metodeBayar, _this.metodeBayar) || other.metodeBayar == _this.metodeBayar)&&(identical(other.dibayarPada, _this.dibayarPada) || other.dibayarPada == _this.dibayarPada)&&(identical(other.dendaTerlambat, _this.dendaTerlambat) || other.dendaTerlambat == _this.dendaTerlambat)&&(identical(other.dibatalkanOleh, _this.dibatalkanOleh) || other.dibatalkanOleh == _this.dibatalkanOleh)&&(identical(other.alasanBatal, _this.alasanBatal) || other.alasanBatal == _this.alasanBatal)&&(identical(other.jenis, _this.jenis) || other.jenis == _this.jenis)&&(identical(other.itemTawaranId, _this.itemTawaranId) || other.itemTawaranId == _this.itemTawaranId)&&(identical(other.perluTanggapanPengaju, _this.perluTanggapanPengaju) || other.perluTanggapanPengaju == _this.perluTanggapanPengaju)&&(identical(other.dendaTawaran, _this.dendaTawaran) || other.dendaTawaran == _this.dendaTawaran));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Booking;
  return Object.hashAll([runtimeType,_this.id,_this.itemId,_this.penyewaId,_this.tanggalMulai,_this.tanggalKembali,_this.totalHarga,_this.status,_this.pesan,_this.dibuatPada,_this.alasanTolak,_this.statusBayar,_this.metodeBayar,_this.dibayarPada,_this.dendaTerlambat,_this.dibatalkanOleh,_this.alasanBatal,_this.jenis,_this.itemTawaranId,_this.perluTanggapanPengaju,_this.dendaTawaran]);
}

@override
String toString() {
  final _this = this as Booking;
  return 'Booking(id: ${_this.id}, itemId: ${_this.itemId}, penyewaId: ${_this.penyewaId}, tanggalMulai: ${_this.tanggalMulai}, tanggalKembali: ${_this.tanggalKembali}, totalHarga: ${_this.totalHarga}, status: ${_this.status}, pesan: ${_this.pesan}, dibuatPada: ${_this.dibuatPada}, alasanTolak: ${_this.alasanTolak}, statusBayar: ${_this.statusBayar}, metodeBayar: ${_this.metodeBayar}, dibayarPada: ${_this.dibayarPada}, dendaTerlambat: ${_this.dendaTerlambat}, dibatalkanOleh: ${_this.dibatalkanOleh}, alasanBatal: ${_this.alasanBatal}, jenis: ${_this.jenis}, itemTawaranId: ${_this.itemTawaranId}, perluTanggapanPengaju: ${_this.perluTanggapanPengaju}, dendaTawaran: ${_this.dendaTawaran})';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String id, String itemId, String penyewaId, DateTime tanggalMulai, DateTime tanggalKembali, int totalHarga, StatusBooking status, String? pesan, DateTime dibuatPada, String? alasanTolak, StatusBayar statusBayar, MetodeBayar? metodeBayar, DateTime? dibayarPada, int dendaTerlambat, String? dibatalkanOleh, String? alasanBatal, JenisTransaksi jenis, String? itemTawaranId, bool perluTanggapanPengaju, int dendaTawaran
});




}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? penyewaId = null,Object? tanggalMulai = null,Object? tanggalKembali = null,Object? totalHarga = null,Object? status = null,Object? pesan = freezed,Object? dibuatPada = null,Object? alasanTolak = freezed,Object? statusBayar = null,Object? metodeBayar = freezed,Object? dibayarPada = freezed,Object? dendaTerlambat = null,Object? dibatalkanOleh = freezed,Object? alasanBatal = freezed,Object? jenis = null,Object? itemTawaranId = freezed,Object? perluTanggapanPengaju = null,Object? dendaTawaran = null,}) {
  return _then(Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,penyewaId: null == penyewaId ? _self.penyewaId : penyewaId // ignore: cast_nullable_to_non_nullable
as String,tanggalMulai: null == tanggalMulai ? _self.tanggalMulai : tanggalMulai // ignore: cast_nullable_to_non_nullable
as DateTime,tanggalKembali: null == tanggalKembali ? _self.tanggalKembali : tanggalKembali // ignore: cast_nullable_to_non_nullable
as DateTime,totalHarga: null == totalHarga ? _self.totalHarga : totalHarga // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StatusBooking,pesan: freezed == pesan ? _self.pesan : pesan // ignore: cast_nullable_to_non_nullable
as String?,dibuatPada: null == dibuatPada ? _self.dibuatPada : dibuatPada // ignore: cast_nullable_to_non_nullable
as DateTime,alasanTolak: freezed == alasanTolak ? _self.alasanTolak : alasanTolak // ignore: cast_nullable_to_non_nullable
as String?,statusBayar: null == statusBayar ? _self.statusBayar : statusBayar // ignore: cast_nullable_to_non_nullable
as StatusBayar,metodeBayar: freezed == metodeBayar ? _self.metodeBayar : metodeBayar // ignore: cast_nullable_to_non_nullable
as MetodeBayar?,dibayarPada: freezed == dibayarPada ? _self.dibayarPada : dibayarPada // ignore: cast_nullable_to_non_nullable
as DateTime?,dendaTerlambat: null == dendaTerlambat ? _self.dendaTerlambat : dendaTerlambat // ignore: cast_nullable_to_non_nullable
as int,dibatalkanOleh: freezed == dibatalkanOleh ? _self.dibatalkanOleh : dibatalkanOleh // ignore: cast_nullable_to_non_nullable
as String?,alasanBatal: freezed == alasanBatal ? _self.alasanBatal : alasanBatal // ignore: cast_nullable_to_non_nullable
as String?,jenis: null == jenis ? _self.jenis : jenis // ignore: cast_nullable_to_non_nullable
as JenisTransaksi,itemTawaranId: freezed == itemTawaranId ? _self.itemTawaranId : itemTawaranId // ignore: cast_nullable_to_non_nullable
as String?,perluTanggapanPengaju: null == perluTanggapanPengaju ? _self.perluTanggapanPengaju : perluTanggapanPengaju // ignore: cast_nullable_to_non_nullable
as bool,dendaTawaran: null == dendaTawaran ? _self.dendaTawaran : dendaTawaran // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String itemId,  String penyewaId,  DateTime tanggalMulai,  DateTime tanggalKembali,  int totalHarga,  StatusBooking status,  String? pesan,  DateTime dibuatPada,  String? alasanTolak,  StatusBayar statusBayar,  MetodeBayar? metodeBayar,  DateTime? dibayarPada,  int dendaTerlambat,  String? dibatalkanOleh,  String? alasanBatal,  JenisTransaksi jenis,  String? itemTawaranId,  bool perluTanggapanPengaju,  int dendaTawaran)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.itemId,_that.penyewaId,_that.tanggalMulai,_that.tanggalKembali,_that.totalHarga,_that.status,_that.pesan,_that.dibuatPada,_that.alasanTolak,_that.statusBayar,_that.metodeBayar,_that.dibayarPada,_that.dendaTerlambat,_that.dibatalkanOleh,_that.alasanBatal,_that.jenis,_that.itemTawaranId,_that.perluTanggapanPengaju,_that.dendaTawaran);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String itemId,  String penyewaId,  DateTime tanggalMulai,  DateTime tanggalKembali,  int totalHarga,  StatusBooking status,  String? pesan,  DateTime dibuatPada,  String? alasanTolak,  StatusBayar statusBayar,  MetodeBayar? metodeBayar,  DateTime? dibayarPada,  int dendaTerlambat,  String? dibatalkanOleh,  String? alasanBatal,  JenisTransaksi jenis,  String? itemTawaranId,  bool perluTanggapanPengaju,  int dendaTawaran)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.itemId,_that.penyewaId,_that.tanggalMulai,_that.tanggalKembali,_that.totalHarga,_that.status,_that.pesan,_that.dibuatPada,_that.alasanTolak,_that.statusBayar,_that.metodeBayar,_that.dibayarPada,_that.dendaTerlambat,_that.dibatalkanOleh,_that.alasanBatal,_that.jenis,_that.itemTawaranId,_that.perluTanggapanPengaju,_that.dendaTawaran);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String itemId,  String penyewaId,  DateTime tanggalMulai,  DateTime tanggalKembali,  int totalHarga,  StatusBooking status,  String? pesan,  DateTime dibuatPada,  String? alasanTolak,  StatusBayar statusBayar,  MetodeBayar? metodeBayar,  DateTime? dibayarPada,  int dendaTerlambat,  String? dibatalkanOleh,  String? alasanBatal,  JenisTransaksi jenis,  String? itemTawaranId,  bool perluTanggapanPengaju,  int dendaTawaran)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.itemId,_that.penyewaId,_that.tanggalMulai,_that.tanggalKembali,_that.totalHarga,_that.status,_that.pesan,_that.dibuatPada,_that.alasanTolak,_that.statusBayar,_that.metodeBayar,_that.dibayarPada,_that.dendaTerlambat,_that.dibatalkanOleh,_that.alasanBatal,_that.jenis,_that.itemTawaranId,_that.perluTanggapanPengaju,_that.dendaTawaran);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking extends Booking {
  const _Booking({required this.id, required this.itemId, required this.penyewaId, required this.tanggalMulai, required this.tanggalKembali, required this.totalHarga, this.status = StatusBooking.menunggu, this.pesan, required this.dibuatPada, this.alasanTolak, this.statusBayar = StatusBayar.belum, this.metodeBayar, this.dibayarPada, this.dendaTerlambat = 0, this.dibatalkanOleh, this.alasanBatal, this.jenis = JenisTransaksi.sewa, this.itemTawaranId, this.perluTanggapanPengaju = false, this.dendaTawaran = 0}): super._();
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  String id;
@override final  String itemId;
@override final  String penyewaId;
@override final  DateTime tanggalMulai;
@override final  DateTime tanggalKembali;
@override final  int totalHarga;
@override@JsonKey() final  StatusBooking status;
@override final  String? pesan;
@override final  DateTime dibuatPada;
/// Diisi pemilik saat menolak (atau sistem saat auto-tolak).
@override final  String? alasanTolak;
/// Dibayar langsung ke pemilik saat serah terima (COD), dicatat pemilik
/// di checklist awal (M10).
@override@JsonKey() final  StatusBayar statusBayar;
@override final  MetodeBayar? metodeBayar;
@override final  DateTime? dibayarPada;
/// Denda keterlambatan yang diterima pemilik di checklist akhir (Rp).
@override@JsonKey() final  int dendaTerlambat;
/// Id user yang membatalkan (penyewa atau pemilik).
@override final  String? dibatalkanOleh;
@override final  String? alasanBatal;
/// M11: barter = kedua pihak saling meminjamkan barang pada tanggal yang
/// sama; [totalHarga] 0 dan tanpa pembayaran.
@override@JsonKey() final  JenisTransaksi jenis;
/// Barang milik pengaju ([penyewaId]) yang ditawarkan untuk barter.
@override final  String? itemTawaranId;
/// Pemilik meminta barang lain (counter); menunggu tanggapan pengaju.
@override@JsonKey() final  bool perluTanggapanPengaju;
/// Denda telat barang tawaran (barter) yang diterima pengaju (Rp).
@override@JsonKey() final  int dendaTawaran;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.penyewaId, penyewaId) || other.penyewaId == penyewaId)&&(identical(other.tanggalMulai, tanggalMulai) || other.tanggalMulai == tanggalMulai)&&(identical(other.tanggalKembali, tanggalKembali) || other.tanggalKembali == tanggalKembali)&&(identical(other.totalHarga, totalHarga) || other.totalHarga == totalHarga)&&(identical(other.status, status) || other.status == status)&&(identical(other.pesan, pesan) || other.pesan == pesan)&&(identical(other.dibuatPada, dibuatPada) || other.dibuatPada == dibuatPada)&&(identical(other.alasanTolak, alasanTolak) || other.alasanTolak == alasanTolak)&&(identical(other.statusBayar, statusBayar) || other.statusBayar == statusBayar)&&(identical(other.metodeBayar, metodeBayar) || other.metodeBayar == metodeBayar)&&(identical(other.dibayarPada, dibayarPada) || other.dibayarPada == dibayarPada)&&(identical(other.dendaTerlambat, dendaTerlambat) || other.dendaTerlambat == dendaTerlambat)&&(identical(other.dibatalkanOleh, dibatalkanOleh) || other.dibatalkanOleh == dibatalkanOleh)&&(identical(other.alasanBatal, alasanBatal) || other.alasanBatal == alasanBatal)&&(identical(other.jenis, jenis) || other.jenis == jenis)&&(identical(other.itemTawaranId, itemTawaranId) || other.itemTawaranId == itemTawaranId)&&(identical(other.perluTanggapanPengaju, perluTanggapanPengaju) || other.perluTanggapanPengaju == perluTanggapanPengaju)&&(identical(other.dendaTawaran, dendaTawaran) || other.dendaTawaran == dendaTawaran));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,itemId,penyewaId,tanggalMulai,tanggalKembali,totalHarga,status,pesan,dibuatPada,alasanTolak,statusBayar,metodeBayar,dibayarPada,dendaTerlambat,dibatalkanOleh,alasanBatal,jenis,itemTawaranId,perluTanggapanPengaju,dendaTawaran]);
}

@override
String toString() {
    return 'Booking(id: $id, itemId: $itemId, penyewaId: $penyewaId, tanggalMulai: $tanggalMulai, tanggalKembali: $tanggalKembali, totalHarga: $totalHarga, status: $status, pesan: $pesan, dibuatPada: $dibuatPada, alasanTolak: $alasanTolak, statusBayar: $statusBayar, metodeBayar: $metodeBayar, dibayarPada: $dibayarPada, dendaTerlambat: $dendaTerlambat, dibatalkanOleh: $dibatalkanOleh, alasanBatal: $alasanBatal, jenis: $jenis, itemTawaranId: $itemTawaranId, perluTanggapanPengaju: $perluTanggapanPengaju, dendaTawaran: $dendaTawaran)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String id, String itemId, String penyewaId, DateTime tanggalMulai, DateTime tanggalKembali, int totalHarga, StatusBooking status, String? pesan, DateTime dibuatPada, String? alasanTolak, StatusBayar statusBayar, MetodeBayar? metodeBayar, DateTime? dibayarPada, int dendaTerlambat, String? dibatalkanOleh, String? alasanBatal, JenisTransaksi jenis, String? itemTawaranId, bool perluTanggapanPengaju, int dendaTawaran
});




}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? penyewaId = null,Object? tanggalMulai = null,Object? tanggalKembali = null,Object? totalHarga = null,Object? status = null,Object? pesan = freezed,Object? dibuatPada = null,Object? alasanTolak = freezed,Object? statusBayar = null,Object? metodeBayar = freezed,Object? dibayarPada = freezed,Object? dendaTerlambat = null,Object? dibatalkanOleh = freezed,Object? alasanBatal = freezed,Object? jenis = null,Object? itemTawaranId = freezed,Object? perluTanggapanPengaju = null,Object? dendaTawaran = null,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,penyewaId: null == penyewaId ? _self.penyewaId : penyewaId // ignore: cast_nullable_to_non_nullable
as String,tanggalMulai: null == tanggalMulai ? _self.tanggalMulai : tanggalMulai // ignore: cast_nullable_to_non_nullable
as DateTime,tanggalKembali: null == tanggalKembali ? _self.tanggalKembali : tanggalKembali // ignore: cast_nullable_to_non_nullable
as DateTime,totalHarga: null == totalHarga ? _self.totalHarga : totalHarga // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StatusBooking,pesan: freezed == pesan ? _self.pesan : pesan // ignore: cast_nullable_to_non_nullable
as String?,dibuatPada: null == dibuatPada ? _self.dibuatPada : dibuatPada // ignore: cast_nullable_to_non_nullable
as DateTime,alasanTolak: freezed == alasanTolak ? _self.alasanTolak : alasanTolak // ignore: cast_nullable_to_non_nullable
as String?,statusBayar: null == statusBayar ? _self.statusBayar : statusBayar // ignore: cast_nullable_to_non_nullable
as StatusBayar,metodeBayar: freezed == metodeBayar ? _self.metodeBayar : metodeBayar // ignore: cast_nullable_to_non_nullable
as MetodeBayar?,dibayarPada: freezed == dibayarPada ? _self.dibayarPada : dibayarPada // ignore: cast_nullable_to_non_nullable
as DateTime?,dendaTerlambat: null == dendaTerlambat ? _self.dendaTerlambat : dendaTerlambat // ignore: cast_nullable_to_non_nullable
as int,dibatalkanOleh: freezed == dibatalkanOleh ? _self.dibatalkanOleh : dibatalkanOleh // ignore: cast_nullable_to_non_nullable
as String?,alasanBatal: freezed == alasanBatal ? _self.alasanBatal : alasanBatal // ignore: cast_nullable_to_non_nullable
as String?,jenis: null == jenis ? _self.jenis : jenis // ignore: cast_nullable_to_non_nullable
as JenisTransaksi,itemTawaranId: freezed == itemTawaranId ? _self.itemTawaranId : itemTawaranId // ignore: cast_nullable_to_non_nullable
as String?,perluTanggapanPengaju: null == perluTanggapanPengaju ? _self.perluTanggapanPengaju : perluTanggapanPengaju // ignore: cast_nullable_to_non_nullable
as bool,dendaTawaran: null == dendaTawaran ? _self.dendaTawaran : dendaTawaran // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get id; String get nama; String get nim; String get email; String? get fotoProfil; String? get fakultas; String? get prodi;/// Maksimal [maksBio] karakter.
 String? get bio; WarnaAvatar get warnaAvatar; StatusVerifikasi get statusVerifikasi; double get rating; int get jumlahUlasan;/// Pembatalan di hari H setelah disetujui (M10).
 int get jumlahBatalMendadak;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as User;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nama, _this.nama) || other.nama == _this.nama)&&(identical(other.nim, _this.nim) || other.nim == _this.nim)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.fotoProfil, _this.fotoProfil) || other.fotoProfil == _this.fotoProfil)&&(identical(other.fakultas, _this.fakultas) || other.fakultas == _this.fakultas)&&(identical(other.prodi, _this.prodi) || other.prodi == _this.prodi)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.warnaAvatar, _this.warnaAvatar) || other.warnaAvatar == _this.warnaAvatar)&&(identical(other.statusVerifikasi, _this.statusVerifikasi) || other.statusVerifikasi == _this.statusVerifikasi)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.jumlahUlasan, _this.jumlahUlasan) || other.jumlahUlasan == _this.jumlahUlasan)&&(identical(other.jumlahBatalMendadak, _this.jumlahBatalMendadak) || other.jumlahBatalMendadak == _this.jumlahBatalMendadak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as User;
  return Object.hash(runtimeType,_this.id,_this.nama,_this.nim,_this.email,_this.fotoProfil,_this.fakultas,_this.prodi,_this.bio,_this.warnaAvatar,_this.statusVerifikasi,_this.rating,_this.jumlahUlasan,_this.jumlahBatalMendadak);
}

@override
String toString() {
  final _this = this as User;
  return 'User(id: ${_this.id}, nama: ${_this.nama}, nim: ${_this.nim}, email: ${_this.email}, fotoProfil: ${_this.fotoProfil}, fakultas: ${_this.fakultas}, prodi: ${_this.prodi}, bio: ${_this.bio}, warnaAvatar: ${_this.warnaAvatar}, statusVerifikasi: ${_this.statusVerifikasi}, rating: ${_this.rating}, jumlahUlasan: ${_this.jumlahUlasan}, jumlahBatalMendadak: ${_this.jumlahBatalMendadak})';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String nama, String nim, String email, String? fotoProfil, String? fakultas, String? prodi, String? bio, WarnaAvatar warnaAvatar, StatusVerifikasi statusVerifikasi, double rating, int jumlahUlasan, int jumlahBatalMendadak
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nama = null,Object? nim = null,Object? email = null,Object? fotoProfil = freezed,Object? fakultas = freezed,Object? prodi = freezed,Object? bio = freezed,Object? warnaAvatar = null,Object? statusVerifikasi = null,Object? rating = null,Object? jumlahUlasan = null,Object? jumlahBatalMendadak = null,}) {
  return _then(User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,nim: null == nim ? _self.nim : nim // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,fotoProfil: freezed == fotoProfil ? _self.fotoProfil : fotoProfil // ignore: cast_nullable_to_non_nullable
as String?,fakultas: freezed == fakultas ? _self.fakultas : fakultas // ignore: cast_nullable_to_non_nullable
as String?,prodi: freezed == prodi ? _self.prodi : prodi // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,warnaAvatar: null == warnaAvatar ? _self.warnaAvatar : warnaAvatar // ignore: cast_nullable_to_non_nullable
as WarnaAvatar,statusVerifikasi: null == statusVerifikasi ? _self.statusVerifikasi : statusVerifikasi // ignore: cast_nullable_to_non_nullable
as StatusVerifikasi,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,jumlahUlasan: null == jumlahUlasan ? _self.jumlahUlasan : jumlahUlasan // ignore: cast_nullable_to_non_nullable
as int,jumlahBatalMendadak: null == jumlahBatalMendadak ? _self.jumlahBatalMendadak : jumlahBatalMendadak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nama,  String nim,  String email,  String? fotoProfil,  String? fakultas,  String? prodi,  String? bio,  WarnaAvatar warnaAvatar,  StatusVerifikasi statusVerifikasi,  double rating,  int jumlahUlasan,  int jumlahBatalMendadak)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.nama,_that.nim,_that.email,_that.fotoProfil,_that.fakultas,_that.prodi,_that.bio,_that.warnaAvatar,_that.statusVerifikasi,_that.rating,_that.jumlahUlasan,_that.jumlahBatalMendadak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nama,  String nim,  String email,  String? fotoProfil,  String? fakultas,  String? prodi,  String? bio,  WarnaAvatar warnaAvatar,  StatusVerifikasi statusVerifikasi,  double rating,  int jumlahUlasan,  int jumlahBatalMendadak)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.nama,_that.nim,_that.email,_that.fotoProfil,_that.fakultas,_that.prodi,_that.bio,_that.warnaAvatar,_that.statusVerifikasi,_that.rating,_that.jumlahUlasan,_that.jumlahBatalMendadak);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nama,  String nim,  String email,  String? fotoProfil,  String? fakultas,  String? prodi,  String? bio,  WarnaAvatar warnaAvatar,  StatusVerifikasi statusVerifikasi,  double rating,  int jumlahUlasan,  int jumlahBatalMendadak)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.nama,_that.nim,_that.email,_that.fotoProfil,_that.fakultas,_that.prodi,_that.bio,_that.warnaAvatar,_that.statusVerifikasi,_that.rating,_that.jumlahUlasan,_that.jumlahBatalMendadak);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, required this.nama, required this.nim, required this.email, this.fotoProfil, this.fakultas, this.prodi, this.bio, this.warnaAvatar = WarnaAvatar.hijau, this.statusVerifikasi = StatusVerifikasi.belum, this.rating = 0, this.jumlahUlasan = 0, this.jumlahBatalMendadak = 0});
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String nama;
@override final  String nim;
@override final  String email;
@override final  String? fotoProfil;
@override final  String? fakultas;
@override final  String? prodi;
/// Maksimal [maksBio] karakter.
@override final  String? bio;
@override@JsonKey() final  WarnaAvatar warnaAvatar;
@override@JsonKey() final  StatusVerifikasi statusVerifikasi;
@override@JsonKey() final  double rating;
@override@JsonKey() final  int jumlahUlasan;
/// Pembatalan di hari H setelah disetujui (M10).
@override@JsonKey() final  int jumlahBatalMendadak;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.nama, nama) || other.nama == nama)&&(identical(other.nim, nim) || other.nim == nim)&&(identical(other.email, email) || other.email == email)&&(identical(other.fotoProfil, fotoProfil) || other.fotoProfil == fotoProfil)&&(identical(other.fakultas, fakultas) || other.fakultas == fakultas)&&(identical(other.prodi, prodi) || other.prodi == prodi)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.warnaAvatar, warnaAvatar) || other.warnaAvatar == warnaAvatar)&&(identical(other.statusVerifikasi, statusVerifikasi) || other.statusVerifikasi == statusVerifikasi)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.jumlahUlasan, jumlahUlasan) || other.jumlahUlasan == jumlahUlasan)&&(identical(other.jumlahBatalMendadak, jumlahBatalMendadak) || other.jumlahBatalMendadak == jumlahBatalMendadak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nama,nim,email,fotoProfil,fakultas,prodi,bio,warnaAvatar,statusVerifikasi,rating,jumlahUlasan,jumlahBatalMendadak);
}

@override
String toString() {
    return 'User(id: $id, nama: $nama, nim: $nim, email: $email, fotoProfil: $fotoProfil, fakultas: $fakultas, prodi: $prodi, bio: $bio, warnaAvatar: $warnaAvatar, statusVerifikasi: $statusVerifikasi, rating: $rating, jumlahUlasan: $jumlahUlasan, jumlahBatalMendadak: $jumlahBatalMendadak)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String nama, String nim, String email, String? fotoProfil, String? fakultas, String? prodi, String? bio, WarnaAvatar warnaAvatar, StatusVerifikasi statusVerifikasi, double rating, int jumlahUlasan, int jumlahBatalMendadak
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nama = null,Object? nim = null,Object? email = null,Object? fotoProfil = freezed,Object? fakultas = freezed,Object? prodi = freezed,Object? bio = freezed,Object? warnaAvatar = null,Object? statusVerifikasi = null,Object? rating = null,Object? jumlahUlasan = null,Object? jumlahBatalMendadak = null,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,nim: null == nim ? _self.nim : nim // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,fotoProfil: freezed == fotoProfil ? _self.fotoProfil : fotoProfil // ignore: cast_nullable_to_non_nullable
as String?,fakultas: freezed == fakultas ? _self.fakultas : fakultas // ignore: cast_nullable_to_non_nullable
as String?,prodi: freezed == prodi ? _self.prodi : prodi // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,warnaAvatar: null == warnaAvatar ? _self.warnaAvatar : warnaAvatar // ignore: cast_nullable_to_non_nullable
as WarnaAvatar,statusVerifikasi: null == statusVerifikasi ? _self.statusVerifikasi : statusVerifikasi // ignore: cast_nullable_to_non_nullable
as StatusVerifikasi,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,jumlahUlasan: null == jumlahUlasan ? _self.jumlahUlasan : jumlahUlasan // ignore: cast_nullable_to_non_nullable
as int,jumlahBatalMendadak: null == jumlahBatalMendadak ? _self.jumlahBatalMendadak : jumlahBatalMendadak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  nama: json['nama'] as String,
  nim: json['nim'] as String,
  email: json['email'] as String,
  fotoProfil: json['fotoProfil'] as String?,
  fakultas: json['fakultas'] as String?,
  prodi: json['prodi'] as String?,
  bio: json['bio'] as String?,
  warnaAvatar:
      $enumDecodeNullable(_$WarnaAvatarEnumMap, json['warnaAvatar']) ??
      WarnaAvatar.hijau,
  statusVerifikasi:
      $enumDecodeNullable(
        _$StatusVerifikasiEnumMap,
        json['statusVerifikasi'],
      ) ??
      StatusVerifikasi.belum,
  rating: (json['rating'] as num?)?.toDouble() ?? 0,
  jumlahUlasan: (json['jumlahUlasan'] as num?)?.toInt() ?? 0,
  jumlahBatalMendadak: (json['jumlahBatalMendadak'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'nama': instance.nama,
  'nim': instance.nim,
  'email': instance.email,
  'fotoProfil': instance.fotoProfil,
  'fakultas': instance.fakultas,
  'prodi': instance.prodi,
  'bio': instance.bio,
  'warnaAvatar': _$WarnaAvatarEnumMap[instance.warnaAvatar]!,
  'statusVerifikasi': _$StatusVerifikasiEnumMap[instance.statusVerifikasi]!,
  'rating': instance.rating,
  'jumlahUlasan': instance.jumlahUlasan,
  'jumlahBatalMendadak': instance.jumlahBatalMendadak,
};

const _$WarnaAvatarEnumMap = {
  WarnaAvatar.hijau: 'hijau',
  WarnaAvatar.pinus: 'pinus',
  WarnaAvatar.biru: 'biru',
  WarnaAvatar.ungu: 'ungu',
  WarnaAvatar.coklat: 'coklat',
  WarnaAvatar.bata: 'bata',
};

const _$StatusVerifikasiEnumMap = {
  StatusVerifikasi.belum: 'belum',
  StatusVerifikasi.menunggu: 'menunggu',
  StatusVerifikasi.terverifikasi: 'terverifikasi',
};

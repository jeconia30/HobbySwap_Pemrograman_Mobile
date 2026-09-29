// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RentangTanggal _$RentangTanggalFromJson(Map<String, dynamic> json) =>
    _RentangTanggal(
      mulai: DateTime.parse(json['mulai'] as String),
      selesai: DateTime.parse(json['selesai'] as String),
    );

Map<String, dynamic> _$RentangTanggalToJson(_RentangTanggal instance) =>
    <String, dynamic>{
      'mulai': instance.mulai.toIso8601String(),
      'selesai': instance.selesai.toIso8601String(),
    };

_Item _$ItemFromJson(Map<String, dynamic> json) => _Item(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  judul: json['judul'] as String,
  deskripsi: json['deskripsi'] as String,
  kategori: $enumDecode(_$KategoriEnumMap, json['kategori']),
  hargaPerHari: (json['hargaPerHari'] as num).toInt(),
  daftarFoto:
      (json['daftarFoto'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  lokasiKampus: json['lokasiKampus'] as String,
  rentangTidakTersedia:
      (json['rentangTidakTersedia'] as List<dynamic>?)
          ?.map((e) => RentangTanggal.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RentangTanggal>[],
  jumlahDisewa: (json['jumlahDisewa'] as num?)?.toInt() ?? 0,
  aktif: json['aktif'] as bool? ?? true,
  dendaPerHari: (json['dendaPerHari'] as num?)?.toInt() ?? 0,
  bisaBarter: json['bisaBarter'] as bool? ?? false,
  minatBarter:
      (json['minatBarter'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$KategoriEnumMap, e))
          .toList() ??
      const <Kategori>[],
);

Map<String, dynamic> _$ItemToJson(_Item instance) => <String, dynamic>{
  'id': instance.id,
  'ownerId': instance.ownerId,
  'judul': instance.judul,
  'deskripsi': instance.deskripsi,
  'kategori': _$KategoriEnumMap[instance.kategori]!,
  'hargaPerHari': instance.hargaPerHari,
  'daftarFoto': instance.daftarFoto,
  'lokasiKampus': instance.lokasiKampus,
  'rentangTidakTersedia': instance.rentangTidakTersedia
      .map((e) => e.toJson())
      .toList(),
  'jumlahDisewa': instance.jumlahDisewa,
  'aktif': instance.aktif,
  'dendaPerHari': instance.dendaPerHari,
  'bisaBarter': instance.bisaBarter,
  'minatBarter': instance.minatBarter
      .map((e) => _$KategoriEnumMap[e]!)
      .toList(),
};

const _$KategoriEnumMap = {
  Kategori.kamera: 'kamera',
  Kategori.camping: 'camping',
  Kategori.olahraga: 'olahraga',
  Kategori.musik: 'musik',
  Kategori.game: 'game',
  Kategori.lainnya: 'lainnya',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Review _$ReviewFromJson(Map<String, dynamic> json) => _Review(
  id: json['id'] as String,
  bookingId: json['bookingId'] as String,
  dariUserId: json['dariUserId'] as String,
  keUserId: json['keUserId'] as String,
  itemId: json['itemId'] as String,
  peran: $enumDecode(_$PeranUlasanEnumMap, json['peran']),
  bintang: (json['bintang'] as num).toInt(),
  teks: json['teks'] as String? ?? '',
  tag:
      (json['tag'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  tanggal: DateTime.parse(json['tanggal'] as String),
);

Map<String, dynamic> _$ReviewToJson(_Review instance) => <String, dynamic>{
  'id': instance.id,
  'bookingId': instance.bookingId,
  'dariUserId': instance.dariUserId,
  'keUserId': instance.keUserId,
  'itemId': instance.itemId,
  'peran': _$PeranUlasanEnumMap[instance.peran]!,
  'bintang': instance.bintang,
  'teks': instance.teks,
  'tag': instance.tag,
  'tanggal': instance.tanggal.toIso8601String(),
};

const _$PeranUlasanEnumMap = {
  PeranUlasan.penyewaMenilaiPemilik: 'penyewaMenilaiPemilik',
  PeranUlasan.pemilikMenilaiPenyewa: 'pemilikMenilaiPenyewa',
};

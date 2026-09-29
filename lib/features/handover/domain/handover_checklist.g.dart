// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handover_checklist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KondisiItem _$KondisiItemFromJson(Map<String, dynamic> json) => _KondisiItem(
  label: json['label'] as String,
  dicek: json['dicek'] as bool? ?? false,
  foto: json['foto'] as String?,
);

Map<String, dynamic> _$KondisiItemToJson(_KondisiItem instance) =>
    <String, dynamic>{
      'label': instance.label,
      'dicek': instance.dicek,
      'foto': instance.foto,
    };

_HandoverChecklist _$HandoverChecklistFromJson(Map<String, dynamic> json) =>
    _HandoverChecklist(
      bookingId: json['bookingId'] as String,
      tahap: $enumDecode(_$TahapChecklistEnumMap, json['tahap']),
      itemId: json['itemId'] as String?,
      daftarKondisi:
          (json['daftarKondisi'] as List<dynamic>?)
              ?.map((e) => KondisiItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <KondisiItem>[],
      disetujuiPemilik: json['disetujuiPemilik'] as bool? ?? false,
      disetujuiPenyewa: json['disetujuiPenyewa'] as bool? ?? false,
      catatan: json['catatan'] as String?,
      disetujuiPemilikPada: json['disetujuiPemilikPada'] == null
          ? null
          : DateTime.parse(json['disetujuiPemilikPada'] as String),
      disetujuiPenyewaPada: json['disetujuiPenyewaPada'] == null
          ? null
          : DateTime.parse(json['disetujuiPenyewaPada'] as String),
    );

Map<String, dynamic> _$HandoverChecklistToJson(_HandoverChecklist instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'tahap': _$TahapChecklistEnumMap[instance.tahap]!,
      'itemId': instance.itemId,
      'daftarKondisi': instance.daftarKondisi.map((e) => e.toJson()).toList(),
      'disetujuiPemilik': instance.disetujuiPemilik,
      'disetujuiPenyewa': instance.disetujuiPenyewa,
      'catatan': instance.catatan,
      'disetujuiPemilikPada': instance.disetujuiPemilikPada?.toIso8601String(),
      'disetujuiPenyewaPada': instance.disetujuiPenyewaPada?.toIso8601String(),
    };

const _$TahapChecklistEnumMap = {
  TahapChecklist.awal: 'awal',
  TahapChecklist.akhir: 'akhir',
};

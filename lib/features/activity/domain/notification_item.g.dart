// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    _NotificationItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tipe: $enumDecode(_$TipeNotifikasiEnumMap, json['tipe']),
      judul: json['judul'] as String,
      isi: json['isi'] as String,
      tanggal: DateTime.parse(json['tanggal'] as String),
      sudahDibaca: json['sudahDibaca'] as bool? ?? false,
      tautan: json['tautan'] as String?,
    );

Map<String, dynamic> _$NotificationItemToJson(_NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'tipe': _$TipeNotifikasiEnumMap[instance.tipe]!,
      'judul': instance.judul,
      'isi': instance.isi,
      'tanggal': instance.tanggal.toIso8601String(),
      'sudahDibaca': instance.sudahDibaca,
      'tautan': instance.tautan,
    };

const _$TipeNotifikasiEnumMap = {
  TipeNotifikasi.pengajuanBaru: 'pengajuanBaru',
  TipeNotifikasi.pengajuanDisetujui: 'pengajuanDisetujui',
  TipeNotifikasi.pengajuanDitolak: 'pengajuanDitolak',
  TipeNotifikasi.pengingatAmbil: 'pengingatAmbil',
  TipeNotifikasi.pengingatKembali: 'pengingatKembali',
  TipeNotifikasi.terlambat: 'terlambat',
  TipeNotifikasi.giliranChecklist: 'giliranChecklist',
  TipeNotifikasi.ulasanBaru: 'ulasanBaru',
  TipeNotifikasi.verifikasiDisetujui: 'verifikasiDisetujui',
  TipeNotifikasi.sewaDibatalkan: 'sewaDibatalkan',
  TipeNotifikasi.barterDiminta: 'barterDiminta',
  TipeNotifikasi.laporanBaru: 'laporanBaru',
  TipeNotifikasi.laporanDitanggapi: 'laporanDitanggapi',
};

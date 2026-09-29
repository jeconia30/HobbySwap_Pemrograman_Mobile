// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laporan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RiwayatLaporan _$RiwayatLaporanFromJson(Map<String, dynamic> json) =>
    _RiwayatLaporan(
      waktu: DateTime.parse(json['waktu'] as String),
      judul: json['judul'] as String,
      isi: json['isi'] as String?,
      olehUserId: json['olehUserId'] as String?,
    );

Map<String, dynamic> _$RiwayatLaporanToJson(_RiwayatLaporan instance) =>
    <String, dynamic>{
      'waktu': instance.waktu.toIso8601String(),
      'judul': instance.judul,
      'isi': instance.isi,
      'olehUserId': instance.olehUserId,
    };

_Laporan _$LaporanFromJson(Map<String, dynamic> json) => _Laporan(
  id: json['id'] as String,
  bookingId: json['bookingId'] as String?,
  pelaporId: json['pelaporId'] as String,
  terlaporId: json['terlaporId'] as String,
  jenis: $enumDecode(_$JenisLaporanEnumMap, json['jenis']),
  itemChecklistBermasalah:
      (json['itemChecklistBermasalah'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  deskripsi: json['deskripsi'] as String,
  fotoBukti:
      (json['fotoBukti'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  usulan: $enumDecodeNullable(_$UsulanPenyelesaianEnumMap, json['usulan']),
  nominal: (json['nominal'] as num?)?.toInt(),
  status:
      $enumDecodeNullable(_$StatusLaporanEnumMap, json['status']) ??
      StatusLaporan.menungguTanggapan,
  riwayat:
      (json['riwayat'] as List<dynamic>?)
          ?.map((e) => RiwayatLaporan.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RiwayatLaporan>[],
  dibuatPada: DateTime.parse(json['dibuatPada'] as String),
);

Map<String, dynamic> _$LaporanToJson(_Laporan instance) => <String, dynamic>{
  'id': instance.id,
  'bookingId': instance.bookingId,
  'pelaporId': instance.pelaporId,
  'terlaporId': instance.terlaporId,
  'jenis': _$JenisLaporanEnumMap[instance.jenis]!,
  'itemChecklistBermasalah': instance.itemChecklistBermasalah,
  'deskripsi': instance.deskripsi,
  'fotoBukti': instance.fotoBukti,
  'usulan': _$UsulanPenyelesaianEnumMap[instance.usulan],
  'nominal': instance.nominal,
  'status': _$StatusLaporanEnumMap[instance.status]!,
  'riwayat': instance.riwayat.map((e) => e.toJson()).toList(),
  'dibuatPada': instance.dibuatPada.toIso8601String(),
};

const _$JenisLaporanEnumMap = {
  JenisLaporan.kerusakan: 'kerusakan',
  JenisLaporan.keterlambatan: 'keterlambatan',
  JenisLaporan.perilaku: 'perilaku',
  JenisLaporan.lainnya: 'lainnya',
};

const _$UsulanPenyelesaianEnumMap = {
  UsulanPenyelesaian.perbaikanPenyewa: 'perbaikanPenyewa',
  UsulanPenyelesaian.gantiRugi: 'gantiRugi',
  UsulanPenyelesaian.diskusi: 'diskusi',
};

const _$StatusLaporanEnumMap = {
  StatusLaporan.menungguTanggapan: 'menungguTanggapan',
  StatusLaporan.diterima: 'diterima',
  StatusLaporan.dibanding: 'dibanding',
  StatusLaporan.selesai: 'selesai',
};

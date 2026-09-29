// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String,
  itemId: json['itemId'] as String,
  penyewaId: json['penyewaId'] as String,
  tanggalMulai: DateTime.parse(json['tanggalMulai'] as String),
  tanggalKembali: DateTime.parse(json['tanggalKembali'] as String),
  totalHarga: (json['totalHarga'] as num).toInt(),
  status:
      $enumDecodeNullable(_$StatusBookingEnumMap, json['status']) ??
      StatusBooking.menunggu,
  pesan: json['pesan'] as String?,
  dibuatPada: DateTime.parse(json['dibuatPada'] as String),
  alasanTolak: json['alasanTolak'] as String?,
  statusBayar:
      $enumDecodeNullable(_$StatusBayarEnumMap, json['statusBayar']) ??
      StatusBayar.belum,
  metodeBayar: $enumDecodeNullable(_$MetodeBayarEnumMap, json['metodeBayar']),
  dibayarPada: json['dibayarPada'] == null
      ? null
      : DateTime.parse(json['dibayarPada'] as String),
  dendaTerlambat: (json['dendaTerlambat'] as num?)?.toInt() ?? 0,
  dibatalkanOleh: json['dibatalkanOleh'] as String?,
  alasanBatal: json['alasanBatal'] as String?,
  jenis:
      $enumDecodeNullable(_$JenisTransaksiEnumMap, json['jenis']) ??
      JenisTransaksi.sewa,
  itemTawaranId: json['itemTawaranId'] as String?,
  perluTanggapanPengaju: json['perluTanggapanPengaju'] as bool? ?? false,
  dendaTawaran: (json['dendaTawaran'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'itemId': instance.itemId,
  'penyewaId': instance.penyewaId,
  'tanggalMulai': instance.tanggalMulai.toIso8601String(),
  'tanggalKembali': instance.tanggalKembali.toIso8601String(),
  'totalHarga': instance.totalHarga,
  'status': _$StatusBookingEnumMap[instance.status]!,
  'pesan': instance.pesan,
  'dibuatPada': instance.dibuatPada.toIso8601String(),
  'alasanTolak': instance.alasanTolak,
  'statusBayar': _$StatusBayarEnumMap[instance.statusBayar]!,
  'metodeBayar': _$MetodeBayarEnumMap[instance.metodeBayar],
  'dibayarPada': instance.dibayarPada?.toIso8601String(),
  'dendaTerlambat': instance.dendaTerlambat,
  'dibatalkanOleh': instance.dibatalkanOleh,
  'alasanBatal': instance.alasanBatal,
  'jenis': _$JenisTransaksiEnumMap[instance.jenis]!,
  'itemTawaranId': instance.itemTawaranId,
  'perluTanggapanPengaju': instance.perluTanggapanPengaju,
  'dendaTawaran': instance.dendaTawaran,
};

const _$StatusBookingEnumMap = {
  StatusBooking.menunggu: 'menunggu',
  StatusBooking.disetujui: 'disetujui',
  StatusBooking.ditolak: 'ditolak',
  StatusBooking.berlangsung: 'berlangsung',
  StatusBooking.selesai: 'selesai',
  StatusBooking.dibatalkan: 'dibatalkan',
};

const _$StatusBayarEnumMap = {
  StatusBayar.belum: 'belum',
  StatusBayar.lunas: 'lunas',
};

const _$MetodeBayarEnumMap = {
  MetodeBayar.tunai: 'tunai',
  MetodeBayar.transfer: 'transfer',
};

const _$JenisTransaksiEnumMap = {
  JenisTransaksi.sewa: 'sewa',
  JenisTransaksi.barter: 'barter',
};

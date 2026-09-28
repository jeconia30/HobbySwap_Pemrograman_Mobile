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
};

const _$StatusBookingEnumMap = {
  StatusBooking.menunggu: 'menunggu',
  StatusBooking.disetujui: 'disetujui',
  StatusBooking.ditolak: 'ditolak',
  StatusBooking.berlangsung: 'berlangsung',
  StatusBooking.selesai: 'selesai',
  StatusBooking.dibatalkan: 'dibatalkan',
};

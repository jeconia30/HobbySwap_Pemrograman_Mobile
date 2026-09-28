import 'package:freezed_annotation/freezed_annotation.dart';

import '../../auth/domain/user.dart';
import '../../item/domain/item.dart';
import 'booking_rules.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

enum StatusBooking {
  menunggu('Menunggu'),
  disetujui('Disetujui'),
  ditolak('Ditolak'),
  berlangsung('Berlangsung'),
  selesai('Selesai'),
  dibatalkan('Dibatalkan');

  const StatusBooking(this.label);

  final String label;

  /// Status yang mengunci tanggal di kalender.
  bool get memblokirTanggal => this == disetujui || this == berlangsung;
}

/// Pengajuan/sewa. Tanggal disimpan tanpa jam; rentang inklusif.
@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String itemId,
    required String penyewaId,
    required DateTime tanggalMulai,
    required DateTime tanggalKembali,
    required int totalHarga,
    @Default(StatusBooking.menunggu) StatusBooking status,
    String? pesan,
    required DateTime dibuatPada,

    /// Diisi pemilik saat menolak (atau sistem saat auto-tolak).
    String? alasanTolak,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}

/// Sewa beserta barang & kedua pihak, untuk daftar pengajuan/sewaan.
@immutable
class BookingDetail {
  const BookingDetail({
    required this.booking,
    required this.item,
    required this.penyewa,
    required this.pemilik,
  });

  final Booking booking;
  final Item item;
  final User penyewa;
  final User pemilik;
}

/// Status tampil barang: nonaktif > disewa (sewa berlangsung mencakup hari
/// ini) > tersedia.
({ItemStatus status, DateTime? sampai}) statusBarang(
  Item item,
  Iterable<Booking> bookings,
  DateTime today,
) {
  if (!item.aktif) return (status: ItemStatus.nonaktif, sampai: null);
  for (final b in bookings) {
    if (b.itemId == item.id &&
        b.status == StatusBooking.berlangsung &&
        rentangBertumpuk(today, today, b.tanggalMulai, b.tanggalKembali)) {
      return (status: ItemStatus.disewa, sampai: b.tanggalKembali);
    }
  }
  return (status: ItemStatus.tersedia, sampai: null);
}

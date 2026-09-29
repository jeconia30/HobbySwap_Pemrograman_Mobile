import 'package:freezed_annotation/freezed_annotation.dart';

import '../../auth/domain/user.dart';
import '../../item/domain/item.dart';
import 'booking_rules.dart';
import '../../../core/utils/dates.dart';
import '../../../core/constants/app_strings.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

enum StatusBooking {
  menunggu(AppTeks.statusMenunggu),
  disetujui(AppTeks.statusDisetujui),
  ditolak(AppTeks.statusDitolak),
  berlangsung(AppTeks.statusBerlangsung),
  selesai(AppTeks.statusSelesai),
  dibatalkan(AppTeks.statusDibatalkan);

  const StatusBooking(this.label);

  final String label;

  /// Status yang mengunci tanggal di kalender.
  bool get memblokirTanggal => this == disetujui || this == berlangsung;
}

/// Sewa biasa atau barter (tukar pinjam sementara tanpa uang, M11).
enum JenisTransaksi { sewa, barter }

enum StatusBayar { belum, lunas }

enum MetodeBayar {
  tunai('Tunai'),
  transfer('Transfer');

  const MetodeBayar(this.label);

  final String label;
}

/// Pengajuan/sewa. Tanggal disimpan tanpa jam; rentang inklusif.
@freezed
abstract class Booking with _$Booking {
  const Booking._();

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

    /// Dibayar langsung ke pemilik saat serah terima (COD), dicatat pemilik
    /// di checklist awal (M10).
    @Default(StatusBayar.belum) StatusBayar statusBayar,
    MetodeBayar? metodeBayar,
    DateTime? dibayarPada,

    /// Denda keterlambatan yang diterima pemilik di checklist akhir (Rp).
    @Default(0) int dendaTerlambat,

    /// Id user yang membatalkan (penyewa atau pemilik).
    String? dibatalkanOleh,
    String? alasanBatal,

    /// M11: barter = kedua pihak saling meminjamkan barang pada tanggal yang
    /// sama; [totalHarga] 0 dan tanpa pembayaran.
    @Default(JenisTransaksi.sewa) JenisTransaksi jenis,

    /// Barang milik pengaju ([penyewaId]) yang ditawarkan untuk barter.
    String? itemTawaranId,

    /// Pemilik meminta barang lain (counter); menunggu tanggapan pengaju.
    @Default(false) bool perluTanggapanPengaju,

    /// Denda telat barang tawaran (barter) yang diterima pengaju (Rp).
    @Default(0) int dendaTawaran,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);

  bool get barter => jenis == JenisTransaksi.barter;

  /// Barang yang terlibat: barang pemilik (+ barang tawaran untuk barter).
  List<String> get itemIds => [itemId, ?itemTawaranId];
}

/// Boleh tidaknya [b] dibatalkan pada [hariIni] (README "Aturan transaksi").
AturanBatal aturanBatal(Booking b, DateTime hariIni) => switch (b.status) {
      StatusBooking.menunggu => AturanBatal.bebas,
      StatusBooking.disetujui => daysBetween(hariIni, b.tanggalMulai) >= 1
          ? AturanBatal.bebas
          : AturanBatal.mendadak,
      _ => AturanBatal.tidakBisa,
    };

/// Sewa beserta barang & kedua pihak, untuk daftar pengajuan/sewaan.
@immutable
class BookingDetail {
  const BookingDetail({
    required this.booking,
    required this.item,
    required this.penyewa,
    required this.pemilik,
    this.itemTawaran,
  });

  final Booking booking;
  final Item item;
  final User penyewa;
  final User pemilik;

  /// Barang milik penyewa yang ditukar (barter).
  final Item? itemTawaran;

  /// Pihak lain dari sudut pandang [userId].
  User lawanDari(String userId) => userId == pemilik.id ? penyewa : pemilik;
}

/// Status tampil barang: nonaktif > disewa/dibarter (sewa atau barter
/// berlangsung yang mencakup hari ini) > tersedia.
({ItemStatus status, DateTime? sampai}) statusBarang(
  Item item,
  Iterable<Booking> bookings,
  DateTime today,
) {
  if (!item.aktif) return (status: ItemStatus.nonaktif, sampai: null);
  for (final b in bookings) {
    if (b.itemIds.contains(item.id) &&
        b.status == StatusBooking.berlangsung &&
        rentangBertumpuk(today, today, b.tanggalMulai, b.tanggalKembali)) {
      return (
        status: b.barter ? ItemStatus.dibarter : ItemStatus.disewa,
        sampai: b.tanggalKembali,
      );
    }
  }
  return (status: ItemStatus.tersedia, sampai: null);
}

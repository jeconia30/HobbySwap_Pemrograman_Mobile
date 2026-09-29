import '../../item/domain/item.dart';
import 'booking.dart';

class BookingException implements Exception {
  const BookingException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Rentang yang diajukan bertumpuk dengan tanggal yang sudah terkunci.
class BookingConflictException extends BookingException {
  const BookingConflictException([
    super.message =
        'Ada tanggal yang sudah disewa orang lain. Pilih tanggal lain, ya.',
  ]);
}

/// Kontrak data sewa. Penyewa/pemilik = user yang sedang masuk.
/// Melempar [BookingException] (atau turunannya) bila ditolak.
abstract interface class BookingRepository {
  Future<Booking> create({
    required String itemId,
    required DateTime mulai,
    required DateTime kembali,
    String? pesan,
  });

  /// Terbaru dulu.
  Future<List<BookingDetail>> bookingsForRenter(String userId);

  /// Semua sewa atas barang milik [userId], terbaru dulu.
  Future<List<BookingDetail>> bookingsForOwner(String userId);

  /// Tanggal yang tidak bisa disewa: blokir pemilik + sewa disetujui/berlangsung.
  Future<List<RentangTanggal>> blockedDates(String itemId);

  /// Pemilik menyetujui. Pengajuan menunggu lain yang bertumpuk untuk barang
  /// yang sama otomatis ditolak; mengembalikan jumlahnya.
  Future<int> approve(String bookingId);

  Future<void> reject(String bookingId, String alasan);

  /// Penyewa membatalkan; hanya untuk status menunggu.
  Future<void> cancel(String bookingId);

  /// Penyewa atau pemilik membatalkan sewa yang sudah disetujui ([alasan]
  /// wajib). Hari H tercatat sebagai pembatalan mendadak; sewa berlangsung
  /// tidak bisa dibatalkan. Tanggalnya kembali terbuka.
  Future<void> batalkanSewa(String bookingId, String alasan);

  /// Pemilik mencatat pembayaran COD (checklist awal).
  Future<Booking> catatPembayaran(
    String bookingId, {
    required MetodeBayar metode,
    required bool diterima,
  });

  /// Pemilik barang mengonfirmasi denda keterlambatan diterima (checklist
  /// akhir). Untuk barter, [itemId] = barang tawaran → dicatat pengaju.
  Future<Booking> catatDenda(
    String bookingId, {
    required bool diterima,
    String? itemId,
  });

  // Barter (M11): tukar pinjam sementara tanpa uang.

  /// Pengaju menawarkan [itemTawaranId] (miliknya) untuk dipinjam pemilik
  /// [itemId] pada tanggal yang sama.
  Future<Booking> createBarter({
    required String itemId,
    required String itemTawaranId,
    required DateTime mulai,
    required DateTime kembali,
    String? pesan,
  });

  /// Pemilik meminta barang lain milik pengaju; pengajuan kembali menunggu
  /// tanggapan pengaju.
  Future<Booking> counterBarter(String bookingId, String itemTawaranBaruId);

  /// Pengaju menyetujui barang yang diminta pemilik → barter disepakati.
  Future<Booking> setujuiCounter(String bookingId);

  /// Gabungan tanggal terblokir kedua barang (tanggal barter harus kosong
  /// di keduanya).
  Future<List<RentangTanggal>> blockedDatesBarter(
      String itemId, String itemTawaranId);

  /// Detail satu sewa (untuk checklist & rating); `null` bila tidak ada.
  Future<BookingDetail?> bookingById(String bookingId);
}

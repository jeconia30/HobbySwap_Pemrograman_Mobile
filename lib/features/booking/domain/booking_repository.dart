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

  /// Detail satu sewa (untuk checklist & rating); `null` bila tidak ada.
  Future<BookingDetail?> bookingById(String bookingId);
}

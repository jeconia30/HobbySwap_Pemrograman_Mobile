import '../../../core/storage/session_storage.dart';
import '../../../core/utils/dates.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../../auth/domain/user.dart';
import '../../item/domain/item.dart';
import '../domain/booking.dart';
import '../domain/booking_repository.dart';
import '../domain/booking_rules.dart';

class FakeBookingRepository implements BookingRepository {
  FakeBookingRepository({
    required this._storage,
    required this._accounts,
    required this._items,
    required this._bookings,
    required this._now,
    this.delay = const Duration(milliseconds: 900),
  });

  static const barangSendiriMessage = 'Ini barangmu sendiri.';
  static const pengajuanGandaMessage =
      'Kamu sudah mengajukan tanggal ini. Tunggu jawaban pemilik dulu.';
  static const autoTolakMessage = 'Tanggal sudah diambil penyewa lain';

  final SessionStorage _storage;
  final FakeAccountStore _accounts;
  final FakeItemStore _items;
  final FakeBookingStore _bookings;
  final DateTime Function() _now;
  final Duration delay;

  List<RentangTanggal> _blocked(Item item) => [
        ...item.rentangTidakTersedia,
        for (final b in _bookings.all)
          if (b.itemId == item.id && b.status.memblokirTanggal)
            RentangTanggal(mulai: b.tanggalMulai, selesai: b.tanggalKembali),
      ];

  @override
  Future<Booking> create({
    required String itemId,
    required DateTime mulai,
    required DateTime kembali,
    String? pesan,
  }) async {
    await Future<void>.delayed(delay);
    final start = dateOnly(mulai);
    final end = dateOnly(kembali);

    final renter = _accounts.byId(_storage.sessionUserId ?? '')?.user;
    if (renter == null) throw const BookingException('Sesimu habis. Masuk lagi ya.');
    if (renter.statusVerifikasi != StatusVerifikasi.terverifikasi) {
      throw const BookingException('Verifikasi KTM dulu, ya.');
    }

    final item = _items.byId(itemId);
    if (item == null) {
      throw const BookingException('Barang ini sudah tidak tersedia.');
    }
    if (item.ownerId == renter.id) {
      throw const BookingException(barangSendiriMessage);
    }
    if (!item.aktif) {
      throw const BookingException('Barang ini sedang tidak disewakan.');
    }

    final masalah = periksaRentang(
      mulai: start,
      kembali: end,
      hariIni: dateOnly(_now()),
    );
    if (masalah != null) throw BookingException(masalah.pesan);

    if (rentangMelewatiBlokir(start, end, _blocked(item))) {
      throw const BookingConflictException();
    }

    final ganda = _bookings.all.any((b) =>
        b.penyewaId == renter.id &&
        b.itemId == itemId &&
        b.status == StatusBooking.menunggu &&
        rentangBertumpuk(start, end, b.tanggalMulai, b.tanggalKembali));
    if (ganda) throw const BookingException(pengajuanGandaMessage);

    final trimmed = pesan?.trim();
    final booking = Booking(
      id: 'bkg-${(_bookings.length + 1).toString().padLeft(3, '0')}',
      itemId: itemId,
      penyewaId: renter.id,
      tanggalMulai: start,
      tanggalKembali: end,
      totalHarga: hitungTotal(item.hargaPerHari, start, end),
      pesan: trimmed == null || trimmed.isEmpty ? null : trimmed,
      dibuatPada: _now(),
    );
    _bookings.add(booking);
    return booking;
  }

  BookingDetail? _detail(Booking b) {
    final item = _items.byId(b.itemId);
    if (item == null) return null;
    final penyewa = _accounts.byId(b.penyewaId)?.user;
    final pemilik = _accounts.byId(item.ownerId)?.user;
    if (penyewa == null || pemilik == null) return null;
    return BookingDetail(
        booking: b, item: item, penyewa: penyewa, pemilik: pemilik);
  }

  List<BookingDetail> _details(bool Function(Booking b) test) =>
      _bookings.all.where(test).map(_detail).nonNulls.toList()
        ..sort((a, b) => b.booking.dibuatPada.compareTo(a.booking.dibuatPada));

  @override
  Future<List<BookingDetail>> bookingsForRenter(String userId) async {
    await Future<void>.delayed(delay);
    return _details((b) => b.penyewaId == userId);
  }

  @override
  Future<List<BookingDetail>> bookingsForOwner(String userId) async {
    await Future<void>.delayed(delay);
    final owned =
        _items.all.where((i) => i.ownerId == userId).map((i) => i.id).toSet();
    return _details((b) => owned.contains(b.itemId));
  }

  @override
  Future<List<RentangTanggal>> blockedDates(String itemId) async {
    await Future<void>.delayed(delay);
    final item = _items.byId(itemId);
    return item == null ? const [] : _blocked(item);
  }

  /// Pengajuan menunggu atas barang milik user yang sedang masuk.
  (Booking, Item) _pendingOwned(String bookingId) {
    final booking = _bookings.byId(bookingId);
    final item = booking == null ? null : _items.byId(booking.itemId);
    if (booking == null || item == null) {
      throw const BookingException('Pengajuan ini sudah tidak ada.');
    }
    if (item.ownerId != _storage.sessionUserId) {
      throw const BookingException('Ini bukan pengajuan untuk barangmu.');
    }
    if (booking.status != StatusBooking.menunggu) {
      throw const BookingException('Pengajuan ini sudah diproses.');
    }
    return (booking, item);
  }

  @override
  Future<int> approve(String bookingId) async {
    await Future<void>.delayed(delay);
    final (booking, item) = _pendingOwned(bookingId);
    if (rentangMelewatiBlokir(
        booking.tanggalMulai, booking.tanggalKembali, _blocked(item))) {
      throw const BookingConflictException(
          'Tanggalnya bentrok dengan sewa yang sudah disetujui.');
    }
    _bookings.update(booking.copyWith(status: StatusBooking.disetujui));

    final bentrok = _bookings.all.where((b) =>
        b.id != booking.id &&
        b.itemId == booking.itemId &&
        b.status == StatusBooking.menunggu &&
        rentangBertumpuk(b.tanggalMulai, b.tanggalKembali,
            booking.tanggalMulai, booking.tanggalKembali)).toList();
    for (final b in bentrok) {
      _bookings.update(b.copyWith(
        status: StatusBooking.ditolak,
        alasanTolak: autoTolakMessage,
      ));
    }
    return bentrok.length;
  }

  @override
  Future<void> reject(String bookingId, String alasan) async {
    await Future<void>.delayed(delay);
    final (booking, _) = _pendingOwned(bookingId);
    final teks = alasan.trim();
    if (teks.isEmpty) {
      throw const BookingException('Tulis alasan penolakannya dulu, ya.');
    }
    _bookings.update(
        booking.copyWith(status: StatusBooking.ditolak, alasanTolak: teks));
  }

  @override
  Future<void> cancel(String bookingId) async {
    await Future<void>.delayed(delay);
    final booking = _bookings.byId(bookingId);
    if (booking == null || booking.penyewaId != _storage.sessionUserId) {
      throw const BookingException('Pengajuan ini tidak ditemukan.');
    }
    if (booking.status != StatusBooking.menunggu) {
      throw const BookingException(
          'Pengajuan ini sudah dijawab pemilik, jadi tidak bisa dibatalkan.');
    }
    _bookings.update(booking.copyWith(status: StatusBooking.dibatalkan));
  }

  @override
  Future<BookingDetail?> bookingById(String bookingId) async {
    await Future<void>.delayed(delay);
    final booking = _bookings.byId(bookingId);
    return booking == null ? null : _detail(booking);
  }
}

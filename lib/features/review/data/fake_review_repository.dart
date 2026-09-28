import '../../../core/storage/session_storage.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_handover_review_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../../booking/domain/booking.dart';
import '../domain/review.dart';
import '../domain/review_repository.dart';

class FakeReviewRepository implements ReviewRepository {
  FakeReviewRepository({
    required this._storage,
    required this._accounts,
    required this._items,
    required this._bookings,
    required this._reviews,
    required this._now,
    this.delay = const Duration(milliseconds: 700),
  });

  final SessionStorage _storage;
  final FakeAccountStore _accounts;
  final FakeItemStore _items;
  final FakeBookingStore _bookings;
  final FakeReviewStore _reviews;
  final DateTime Function() _now;
  final Duration delay;

  @override
  Future<Review> submit({
    required String bookingId,
    required int bintang,
    String teks = '',
    List<String> tag = const [],
  }) async {
    await Future<void>.delayed(delay);
    final userId = _storage.sessionUserId;
    final booking = _bookings.byId(bookingId);
    final item = booking == null ? null : _items.byId(booking.itemId);
    if (userId == null || booking == null || item == null) {
      throw const ReviewException('Sewa ini tidak ditemukan.');
    }
    final PeranUlasan peran;
    final String keUserId;
    if (userId == booking.penyewaId) {
      peran = PeranUlasan.penyewaMenilaiPemilik;
      keUserId = item.ownerId;
    } else if (userId == item.ownerId) {
      peran = PeranUlasan.pemilikMenilaiPenyewa;
      keUserId = booking.penyewaId;
    } else {
      throw const ReviewException('Kamu bukan pihak dalam sewa ini.');
    }
    if (booking.status != StatusBooking.selesai) {
      throw const ReviewException('Ulasan bisa diberikan setelah sewa selesai.');
    }
    if (_reviews.all.any((r) => r.bookingId == bookingId && r.dariUserId == userId)) {
      throw const ReviewException('Kamu sudah memberi ulasan untuk sewa ini.');
    }
    if (bintang < 1 || bintang > 5) {
      throw const ReviewException('Pilih 1 sampai 5 bintang.');
    }
    final masalah = periksaCerita(bintang, teks);
    if (masalah != null) throw ReviewException(masalah);

    final review = Review(
      id: 'rvw-${(_reviews.length + 1).toString().padLeft(3, '0')}',
      bookingId: bookingId,
      dariUserId: userId,
      keUserId: keUserId,
      itemId: item.id,
      peran: peran,
      bintang: bintang,
      teks: teks.trim(),
      tag: tag,
      tanggal: _now(),
    );
    _reviews.add(review);

    final dinilai = _accounts.byId(keUserId)!.user;
    final baru = ratingBaru(dinilai.rating, dinilai.jumlahUlasan, bintang);
    _accounts.updateUser(
        dinilai.copyWith(rating: baru.rating, jumlahUlasan: baru.jumlah));
    return review;
  }

  @override
  Future<List<ReviewDetail>> reviewsFor(String userId) async {
    await Future<void>.delayed(delay);
    return [
      for (final r in _reviews.all.where((r) => r.keUserId == userId))
        if (_accounts.byId(r.dariUserId) case final dari?)
          ReviewDetail(review: r, dari: dari.user),
    ]..sort((a, b) => b.review.tanggal.compareTo(a.review.tanggal));
  }

  @override
  Future<List<Review>> reviewsBy(String userId) async {
    await Future<void>.delayed(delay);
    return _reviews.all.where((r) => r.dariUserId == userId).toList();
  }
}

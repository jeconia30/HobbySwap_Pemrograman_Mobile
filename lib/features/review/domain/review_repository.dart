import 'review.dart';

/// Kontrak ulasan. Penulis = user yang sedang masuk.
abstract interface class ReviewRepository {
  /// Hanya untuk sewa selesai, sekali per pihak. Memperbarui rating rata-rata
  /// & jumlah ulasan user yang dinilai. Melempar [ReviewException].
  Future<Review> submit({
    required String bookingId,
    required int bintang,
    String teks = '',
    List<String> tag = const [],
  });

  /// Ulasan yang diterima [userId], terbaru dulu.
  Future<List<ReviewDetail>> reviewsFor(String userId);

  /// Ulasan yang ditulis [userId] (untuk tahu sewa mana yang sudah dinilai).
  Future<List<Review>> reviewsBy(String userId);
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../auth/domain/user.dart';

part 'review.freezed.dart';
part 'review.g.dart';

enum PeranUlasan {
  /// Penyewa menilai pemilik (tampil di Detail Barang).
  penyewaMenilaiPemilik,

  /// Pemilik menilai penyewa.
  pemilikMenilaiPenyewa,
}

@freezed
abstract class Review with _$Review {
  const factory Review({
    required String id,
    required String bookingId,
    required String dariUserId,
    required String keUserId,
    required String itemId,
    required PeranUlasan peran,
    required int bintang,
    @Default('') String teks,
    @Default(<String>[]) List<String> tag,
    required DateTime tanggal,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}

/// Ulasan beserta penulisnya.
@immutable
class ReviewDetail {
  const ReviewDetail({required this.review, required this.dari});

  final Review review;
  final User dari;
}

class ReviewException implements Exception {
  const ReviewException(this.message);

  final String message;

  @override
  String toString() => 'ReviewException: $message';
}

const labelBintang = ['Kecewa', 'Kurang', 'Oke', 'Bagus', 'Mantap!'];

const tagPenyewaMenilai = [
  'Sesuai foto',
  'Pemilik ramah',
  'Tepat waktu',
  'Bersih & rapi',
  'Mudah diambil',
];

const tagPemilikMenilai = [
  'Tepat waktu',
  'Barang dijaga baik',
  'Komunikatif',
  'Ramah',
];

const minimalCeritaBintangRendah = 10;

/// Pesan error cerita, atau `null` bila boleh dikirim.
String? periksaCerita(int bintang, String teks) {
  if (bintang <= 2 && teks.trim().length < minimalCeritaBintangRendah) {
    return 'Ceritakan apa yang kurang supaya bisa diperbaiki '
        '(minimal $minimalCeritaBintangRendah karakter).';
  }
  return null;
}

/// Rata-rata baru setelah menambah satu ulasan.
({double rating, int jumlah}) ratingBaru(
    double rating, int jumlah, int bintang) {
  final total = rating * jumlah + bintang;
  final n = jumlah + 1;
  return (rating: double.parse((total / n).toStringAsFixed(2)), jumlah: n);
}

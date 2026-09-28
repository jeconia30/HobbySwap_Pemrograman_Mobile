import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/features/booking/domain/booking_rules.dart';
import 'package:hobby_swab/features/item/domain/item.dart';

DateTime d(int day, [int month = 10]) => DateTime(2026, month, day);

void main() {
  group('hitung hari & total', () {
    test('inklusif: 9–11 Okt = 3 hari, hari sama = 1 hari', () {
      expect(hitungHari(d(9), d(11)), 3);
      expect(hitungHari(d(9), d(9)), 1);
      expect(hitungHari(d(30), d(2, 11)), 4, reason: 'melintasi bulan');
    });

    test('total = harga per hari × jumlah hari', () {
      expect(hitungTotal(45000, d(9), d(11)), 135000);
      expect(hitungTotal(12000, d(9), d(9)), 12000);
    });
  });

  group('bentrok', () {
    test('bertumpuk sebagian', () {
      expect(rentangBertumpuk(d(9), d(11), d(11), d(13)), isTrue);
      expect(rentangBertumpuk(d(10), d(14), d(8), d(10)), isTrue);
      expect(rentangBertumpuk(d(9), d(20), d(12), d(13)), isTrue,
          reason: 'mencakup penuh');
    });

    test('bersebelahan tidak bentrok', () {
      expect(rentangBertumpuk(d(9), d(11), d(12), d(13)), isFalse);
      expect(rentangBertumpuk(d(14), d(15), d(12), d(13)), isFalse);
    });

    test('tanggal terblokir & rentang melewati blokir', () {
      final blok = [RentangTanggal(mulai: d(12), selesai: d(13))];
      expect(tanggalTerblokir(d(12), blok), isTrue);
      expect(tanggalTerblokir(d(14), blok), isFalse);
      expect(rentangMelewatiBlokir(d(10), d(15), blok), isTrue);
      expect(rentangMelewatiBlokir(d(14), d(15), blok), isFalse);
    });
  });

  group('periksaRentang', () {
    final today = d(5);

    test('valid', () {
      expect(periksaRentang(mulai: d(5), kembali: d(7), hariIni: today),
          isNull);
    });

    test('tanggal mulai lampau', () {
      expect(periksaRentang(mulai: d(4), kembali: d(7), hariIni: today),
          MasalahRentang.lampau);
    });

    test('kembali sebelum mulai', () {
      expect(periksaRentang(mulai: d(8), kembali: d(7), hariIni: today),
          MasalahRentang.terbalik);
    });

    test('batas 14 hari: 14 boleh, 15 ditolak', () {
      expect(periksaRentang(mulai: d(6), kembali: d(19), hariIni: today),
          isNull);
      final m = periksaRentang(mulai: d(6), kembali: d(20), hariIni: today);
      expect(m, MasalahRentang.terlaluLama);
      expect(m!.pesan, 'Maksimal 14 hari sekali sewa');
    });

    test('melewati tanggal terblokir', () {
      final m = periksaRentang(
        mulai: d(10),
        kembali: d(15),
        hariIni: today,
        terblokir: [RentangTanggal(mulai: d(12), selesai: d(12))],
      );
      expect(m, MasalahRentang.melewatiBlokir);
      expect(m!.pesan, 'Rentang ini melewati tanggal yang sudah disewa');
    });
  });
}

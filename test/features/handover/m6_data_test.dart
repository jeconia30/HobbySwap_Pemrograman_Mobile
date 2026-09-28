import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/storage/session_storage.dart';
import 'package:hobby_swab/data/fake/fake_account_store.dart';
import 'package:hobby_swab/data/fake/fake_booking_store.dart';
import 'package:hobby_swab/data/fake/fake_handover_review_store.dart';
import 'package:hobby_swab/data/fake/fake_item_store.dart';
import 'package:hobby_swab/data/fake/sample_data.dart';
import 'package:hobby_swab/features/booking/data/fake_booking_repository.dart';
import 'package:hobby_swab/features/booking/domain/booking.dart';
import 'package:hobby_swab/features/booking/domain/booking_repository.dart';
import 'package:hobby_swab/features/booking/domain/booking_rules.dart';
import 'package:hobby_swab/features/handover/data/fake_checklist_repository.dart';
import 'package:hobby_swab/features/handover/domain/handover_checklist.dart';
import 'package:hobby_swab/features/item/domain/kategori.dart';
import 'package:hobby_swab/features/review/data/fake_review_repository.dart';
import 'package:hobby_swab/features/review/domain/review.dart';

import '../../helpers/pump_app.dart';

const gregorian = 'usr-001';
const dimas = 'usr-005';
const sarah = 'usr-004';
const goproDisetujui = 'bkg-022'; // Gregorian menyewa GoPro dari Dimas
const sonyBerlangsung = 'bkg-021';
const stikMenunggu = 'bkg-023';
const tendaSelesai = 'bkg-024';

void main() {
  late SessionStorage storage;
  late FakeAccountStore accounts;
  late FakeBookingStore bookings;
  late FakeChecklistRepository checklist;
  late FakeBookingRepository bookingRepo;
  late FakeReviewRepository reviewRepo;

  setUp(() async {
    storage = await mockStorage({SessionStorage.sessionUserIdKey: gregorian});
    accounts = FakeAccountStore();
    final items = FakeItemStore(sampleItemsFor(testToday));
    bookings = FakeBookingStore(sampleBookingsFor(testToday));
    checklist = FakeChecklistRepository(
      store: FakeChecklistStore(sampleChecklistsFor(bookings.all)),
      bookings: bookings,
      items: items,
      now: () => testToday,
      delay: Duration.zero,
      autoApproveDelay: null,
    );
    bookingRepo = FakeBookingRepository(
      storage: storage,
      accounts: accounts,
      items: items,
      bookings: bookings,
      now: () => testToday,
      delay: Duration.zero,
    );
    reviewRepo = FakeReviewRepository(
      storage: storage,
      accounts: accounts,
      items: items,
      bookings: bookings,
      reviews: FakeReviewStore(sampleReviewsFor(bookings.all)),
      now: () => testToday,
      delay: Duration.zero,
    );
  });

  StatusBooking status(String id) => bookings.byId(id)!.status;

  /// Isi checklist sampai lolos aturan (semua dicentang, 2 foto).
  Future<void> lengkapi(String bookingId, TahapChecklist tahap) async {
    final c = await checklist.get(bookingId, tahap);
    await checklist.save(c.copyWith(daftarKondisi: [
      for (final (i, k) in c.daftarKondisi.indexed)
        k.copyWith(dicek: true, foto: i < 2 ? 'foto-$i' : null),
    ]));
  }

  group('transisi status lewat checklist', () {
    test('disetujui → berlangsung hanya setelah kedua pihak setuju (awal)',
        () async {
      await lengkapi(goproDisetujui, TahapChecklist.awal);

      await checklist.approve(goproDisetujui, TahapChecklist.awal, gregorian);
      expect(status(goproDisetujui), StatusBooking.disetujui,
          reason: 'baru penyewa yang setuju');

      final c = await checklist.approve(
          goproDisetujui, TahapChecklist.awal, dimas);
      expect(c.selesai, isTrue);
      expect(c.disetujuiPemilikPada, testToday);
      expect(status(goproDisetujui), StatusBooking.berlangsung);
    });

    test('berlangsung → selesai hanya setelah kedua pihak setuju (akhir)',
        () async {
      await lengkapi(sonyBerlangsung, TahapChecklist.akhir);
      await checklist.approve(sonyBerlangsung, TahapChecklist.akhir, 'usr-003');
      expect(status(sonyBerlangsung), StatusBooking.berlangsung);
      await checklist.approve(sonyBerlangsung, TahapChecklist.akhir, gregorian);
      expect(status(sonyBerlangsung), StatusBooking.selesai);
    });

    test('tahap akhir belum terbuka saat sewa masih disetujui', () async {
      await expectLater(
        checklist.approve(goproDisetujui, TahapChecklist.akhir, gregorian),
        throwsA(isA<ChecklistException>()),
      );
    });

    test('bukan pihak dalam sewa ditolak', () async {
      await lengkapi(goproDisetujui, TahapChecklist.awal);
      await expectLater(
        checklist.approve(goproDisetujui, TahapChecklist.awal, sarah),
        throwsA(isA<ChecklistException>()),
      );
    });

    test('checklist yang sudah selesai tidak bisa diubah', () async {
      final awal = await checklist.get(sonyBerlangsung, TahapChecklist.awal);
      expect(awal.selesai, isTrue, reason: 'data contoh');
      await expectLater(
          checklist.save(awal.copyWith(catatan: 'x')),
          throwsA(isA<ChecklistException>()));
    });
  });

  group('aturan checklist', () {
    final dasar = HandoverChecklist(
      bookingId: 'x',
      tahap: TahapChecklist.awal,
      daftarKondisi: templateChecklist(Kategori.kamera),
    );

    test('minimal 2 foto bukti', () {
      final satuFoto = dasar.copyWith(daftarKondisi: [
        for (final (i, k) in dasar.daftarKondisi.indexed)
          k.copyWith(dicek: true, foto: i == 0 ? 'f' : null),
      ]);
      expect(periksaChecklist(satuFoto),
          ['Tambahkan minimal 2 foto bukti.']);
    });

    test('item tidak dicentang wajib dijelaskan di catatan', () {
      final belum = dasar.copyWith(daftarKondisi: [
        for (final (i, k) in dasar.daftarKondisi.indexed)
          k.copyWith(dicek: i != 3, foto: i < 2 ? 'f' : null),
      ]);
      expect(periksaChecklist(belum), hasLength(1));
      expect(periksaChecklist(belum).single, contains('catatan'));
      expect(
          periksaChecklist(
              belum.copyWith(catatan: 'Kartu memori memang tidak ada.')),
          isEmpty);
    });

    test('approve ditolak bila aturan dilanggar', () async {
      await expectLater(
        checklist.approve(goproDisetujui, TahapChecklist.awal, gregorian),
        throwsA(isA<ChecklistException>().having((e) => e.message, 'message',
            'Tambahkan minimal 2 foto bukti.')),
      );
    });

    test('template 5 item untuk tiap kategori', () {
      for (final k in Kategori.values) {
        expect(templateChecklist(k), hasLength(5), reason: k.name);
      }
      expect(templateChecklist(Kategori.kamera).first.label,
          'Body mulus, tanpa goresan baru');
    });
  });

  group('batal pengajuan', () {
    test('boleh untuk status menunggu', () async {
      await bookingRepo.cancel(stikMenunggu);
      expect(status(stikMenunggu), StatusBooking.dibatalkan);
    });

    test('ditolak untuk status selain menunggu', () async {
      for (final id in [goproDisetujui, sonyBerlangsung, tendaSelesai]) {
        await expectLater(
            bookingRepo.cancel(id), throwsA(isA<BookingException>()),
            reason: id);
      }
    });

    test('hanya penyewa sendiri', () async {
      await storage.saveSession(sarah);
      await expectLater(
          bookingRepo.cancel(stikMenunggu), throwsA(isA<BookingException>()));
    });
  });

  group('ulasan', () {
    test('submit memperbarui rata-rata & jumlah ulasan yang dinilai', () async {
      final sebelum = accounts.byId(sarah)!.user; // 4.8 dari 36
      final review =
          await reviewRepo.submit(bookingId: tendaSelesai, bintang: 3);

      expect(review.peran, PeranUlasan.penyewaMenilaiPemilik);
      expect(review.keUserId, sarah);
      final sesudah = accounts.byId(sarah)!.user;
      expect(sesudah.jumlahUlasan, sebelum.jumlahUlasan + 1);
      expect(sesudah.rating, closeTo((4.8 * 36 + 3) / 37, 0.01));

      final diterima = await reviewRepo.reviewsFor(sarah);
      expect(diterima.first.review.id, review.id);
      expect(diterima.first.dari.id, gregorian);
    });

    test('hanya sekali per pihak, hanya untuk sewa selesai', () async {
      await reviewRepo.submit(bookingId: tendaSelesai, bintang: 5);
      await expectLater(reviewRepo.submit(bookingId: tendaSelesai, bintang: 4),
          throwsA(isA<ReviewException>()));
      await expectLater(reviewRepo.submit(bookingId: sonyBerlangsung, bintang: 4),
          throwsA(isA<ReviewException>()));
    });

    test('bintang 1–2 wajib cerita minimal 10 karakter', () async {
      await expectLater(
          reviewRepo.submit(bookingId: tendaSelesai, bintang: 2, teks: 'jelek'),
          throwsA(isA<ReviewException>()));
      expect(periksaCerita(2, 'Tendanya bocor di sudut.'), isNull);
      expect(periksaCerita(4, ''), isNull);
    });

    test('pemilik menilai penyewa', () async {
      final r = await reviewRepo.submit(
          bookingId: sewaBelumDinilaiPemilik, bintang: 5, tag: ['Ramah']);
      expect(r.peran, PeranUlasan.pemilikMenilaiPenyewa);
      expect(r.keUserId, 'usr-003');
    });

    test('ratingBaru', () {
      final r = ratingBaru(4.0, 1, 5);
      expect((r.rating, r.jumlah), (4.5, 2));
    });
  });

  group('hari tersisa & terlambat', () {
    test('sisa hari', () {
      expect(sisaHariSewa(hPlus(2), testToday), 2);
      expect(teksSisaHari(2), 'Kembalikan dalam 2 hari');
      expect(teksSisaHari(0), 'Kembalikan hari ini');
      expect(teksSisaHari(sisaHariSewa(hPlus(-3), testToday)),
          'Terlambat 3 hari, segera kembalikan');
    });

    test('progres = hari berjalan / total hari', () {
      // h-1..h+1 = 3 hari, hari ini hari ke-2.
      expect(progresSewa(hPlus(-1), hPlus(1), testToday), closeTo(2 / 3, 1e-9));
      expect(progresSewa(hPlus(1), hPlus(2), testToday), 0);
      expect(progresSewa(hPlus(-5), hPlus(-2), testToday), 1);
    });
  });
}

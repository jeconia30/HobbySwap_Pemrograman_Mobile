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
import 'package:hobby_swab/features/item/domain/item.dart';
import 'package:hobby_swab/features/item/domain/kategori.dart';

import '../../helpers/pump_app.dart';

const dimas = 'usr-005';
const tawaranMasuk = 'bkg-026'; // GoPro Dimas ⇄ Carrier Eiger Gregorian, h+8..9
const carrier = 'itm-013', gopro = 'itm-003', sony = 'itm-001';
const tenda = 'itm-004', kompor = 'itm-006';

void main() {
  late SessionStorage storage;
  late FakeItemStore items;
  late FakeBookingStore bookings;
  late FakeBookingRepository repo;
  late FakeChecklistRepository checklist;

  setUp(() async {
    storage = await mockStorage({SessionStorage.sessionUserIdKey: gregorian});
    items = FakeItemStore(sampleItemsFor(testToday));
    bookings = FakeBookingStore(sampleBookingsFor(testToday));
    repo = FakeBookingRepository(
      storage: storage,
      accounts: FakeAccountStore(),
      items: items,
      bookings: bookings,
      now: () => testToday,
      delay: Duration.zero,
    );
    checklist = FakeChecklistRepository(
      store: FakeChecklistStore(sampleChecklistsFor(bookings.all)),
      bookings: bookings,
      items: items,
      now: () => testToday,
      delay: Duration.zero,
      autoApproveDelay: null,
    );
  });

  bool terkunci(List<RentangTanggal> r, DateTime hari) =>
      tanggalTerblokir(hari, r);

  test('data contoh: tawaran masuk & barter berlangsung', () {
    final masuk = bookings.byId(tawaranMasuk)!;
    expect(masuk.barter, isTrue);
    expect(masuk.itemTawaranId, gopro);
    expect(masuk.totalHarga, 0);
    expect(items.byId(carrier)!.bisaBarter, isTrue);
    expect(items.byId(carrier)!.minatBarter, [Kategori.kamera]);
    expect(items.all.where((i) => i.bisaBarter && i.ownerId != gregorian),
        hasLength(4));
    expect(
      bookings.all.where((b) =>
          b.barter &&
          b.status == StatusBooking.berlangsung &&
          b.penyewaId == gregorian),
      hasLength(1),
    );
  });

  test('tanggal terblokir = gabungan tanggal terblokir kedua barang',
      () async {
    final a = await repo.blockedDates(sony);
    final b = await repo.blockedDates(tenda);
    final gabung = await repo.blockedDatesBarter(sony, tenda);
    expect(gabung, hasLength(a.length + b.length));
    expect(gabung, containsAll([...a, ...b]));
    expect(terkunci(gabung, hPlus(2)), isTrue, reason: 'blokir Sony');
    expect(terkunci(gabung, hPlus(12)), isTrue, reason: 'blokir Tenda');
    expect(terkunci(gabung, hPlus(7)), isFalse);
  });

  test('barter disetujui memblokir tanggal di kedua barang', () async {
    expect(terkunci(await repo.blockedDates(carrier), hPlus(8)), isFalse);
    expect(terkunci(await repo.blockedDates(gopro), hPlus(8)), isFalse);
    await repo.approve(tawaranMasuk);
    expect(bookings.byId(tawaranMasuk)!.status, StatusBooking.disetujui);
    expect(terkunci(await repo.blockedDates(carrier), hPlus(8)), isTrue);
    expect(terkunci(await repo.blockedDates(gopro), hPlus(9)), isTrue);
    // Sewa biasa atas GoPro di tanggal itu sekarang ditolak.
    await storage.saveSession('usr-004');
    await expectLater(
      repo.create(itemId: gopro, mulai: hPlus(8), kembali: hPlus(8)),
      throwsA(isA<BookingConflictException>()),
    );
  });

  test('counter mengganti barang & kembali menunggu tanggapan pengaju',
      () async {
    final c = await repo.counterBarter(tawaranMasuk, kompor);
    expect(c.itemTawaranId, kompor);
    expect(c.status, StatusBooking.menunggu);
    expect(c.perluTanggapanPengaju, isTrue);
    await expectLater(repo.approve(tawaranMasuk),
        throwsA(isA<BookingException>()),
        reason: 'pemilik menunggu jawaban pengaju');

    await storage.saveSession(dimas);
    final s = await repo.setujuiCounter(tawaranMasuk);
    expect(s.status, StatusBooking.disetujui);
    expect(s.perluTanggapanPengaju, isFalse);
    expect(terkunci(await repo.blockedDates(kompor), hPlus(8)), isTrue);
    expect(terkunci(await repo.blockedDates(gopro), hPlus(8)), isFalse);
  });

  test('counter hanya dengan barang aktif milik pengaju', () async {
    await expectLater(repo.counterBarter(tawaranMasuk, sony),
        throwsA(isA<BookingException>()));
  });

  group('checklist dua barang', () {
    Future<void> beres(TahapChecklist tahap, String? itemId) async {
      final c = await checklist.get(tawaranMasuk, tahap, itemId: itemId);
      await checklist.save(c.copyWith(daftarKondisi: [
        for (final (i, k) in c.daftarKondisi.indexed)
          k.copyWith(dicek: true, foto: i < 2 ? 'foto-$i' : null),
      ]));
      // Barang utama: pemilik Gregorian, peminjam Dimas.
      // Barang tawaran: pemilik Dimas, peminjam Gregorian.
      await checklist.approve(tawaranMasuk, tahap, gregorian, itemId: itemId);
      await checklist.approve(tawaranMasuk, tahap, dimas, itemId: itemId);
    }

    StatusBooking status() => bookings.byId(tawaranMasuk)!.status;

    test('berlangsung/selesai hanya setelah checklist kedua barang lengkap',
        () async {
      await repo.approve(tawaranMasuk);

      await beres(TahapChecklist.awal, null);
      expect(status(), StatusBooking.disetujui,
          reason: 'barang tawaran belum dicek');
      await beres(TahapChecklist.awal, gopro);
      expect(status(), StatusBooking.berlangsung);

      await beres(TahapChecklist.akhir, gopro);
      expect(status(), StatusBooking.berlangsung);
      await beres(TahapChecklist.akhir, null);
      expect(status(), StatusBooking.selesai);
    });

    test('checklist barang tawaran memakai kategori barang itu', () async {
      await repo.approve(tawaranMasuk);
      final c =
          await checklist.get(tawaranMasuk, TahapChecklist.awal, itemId: gopro);
      expect(c.itemId, gopro);
      expect(
        c.daftarKondisi.map((k) => k.label),
        templateChecklist(items.byId(gopro)!.kategori).map((k) => k.label),
      );
    });
  });

  group('tanpa uang', () {
    test('createBarter: totalHarga 0, jenis barter, tanpa tagihan', () async {
      final b = await repo.createBarter(
        itemId: sony,
        itemTawaranId: carrier,
        mulai: hPlus(4),
        kembali: hPlus(6),
      );
      expect(b.barter, isTrue);
      expect(b.totalHarga, 0);
      expect(b.itemTawaranId, carrier);

      await storage.saveSession('usr-003');
      await repo.approve(b.id);
      await expectLater(
        repo.catatPembayaran(b.id, metode: MetodeBayar.tunai, diterima: true),
        throwsA(isA<BookingException>()),
      );
      // Pemilik bisa menyetujui checklist awal tanpa pembayaran.
      expect(
          checklist.syaratPemilik(bookings.byId(b.id)!, TahapChecklist.awal),
          isNull);
    });

    test('createBarter ditolak: barang tidak menerima barter / bukan milikku',
        () async {
      await expectLater(
        repo.createBarter(
            itemId: 'itm-002',
            itemTawaranId: carrier,
            mulai: hPlus(4),
            kembali: hPlus(5)),
        throwsA(isA<BookingException>()),
      );
      await expectLater(
        repo.createBarter(
            itemId: sony,
            itemTawaranId: gopro,
            mulai: hPlus(4),
            kembali: hPlus(5)),
        throwsA(isA<BookingException>()),
      );
    });
  });
}

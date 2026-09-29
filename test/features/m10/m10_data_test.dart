import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/storage/session_storage.dart';
import 'package:hobby_swab/data/fake/fake_account_store.dart';
import 'package:hobby_swab/data/fake/fake_booking_store.dart';
import 'package:hobby_swab/data/fake/fake_favorite_store.dart';
import 'package:hobby_swab/data/fake/fake_handover_review_store.dart';
import 'package:hobby_swab/data/fake/fake_item_store.dart';
import 'package:hobby_swab/data/fake/fake_laporan_store.dart';
import 'package:hobby_swab/data/fake/sample_data.dart';
import 'package:hobby_swab/features/booking/data/fake_booking_repository.dart';
import 'package:hobby_swab/features/booking/domain/booking.dart';
import 'package:hobby_swab/features/booking/domain/booking_repository.dart';
import 'package:hobby_swab/features/booking/domain/booking_rules.dart';
import 'package:hobby_swab/features/handover/data/fake_checklist_repository.dart';
import 'package:hobby_swab/features/handover/domain/handover_checklist.dart';
import 'package:hobby_swab/features/laporan/data/fake_laporan_repository.dart';
import 'package:hobby_swab/features/laporan/domain/laporan.dart';
import 'package:hobby_swab/features/laporan/domain/laporan_repository.dart';

import '../../helpers/pump_app.dart';

const dimas = 'usr-005', sarah = 'usr-004';
const gopro = 'bkg-022'; // Gregorian menyewa GoPro dari Dimas, mulai h+1
const sony = 'bkg-021'; // berlangsung
const tenda = 'bkg-024'; // selesai, Sarah pemilik

void main() {
  late SessionStorage storage;
  late FakeAccountStore accounts;
  late FakeItemStore items;
  late FakeBookingStore bookings;

  setUp(() async {
    storage = await mockStorage({SessionStorage.sessionUserIdKey: gregorian});
    accounts = FakeAccountStore();
    items = FakeItemStore(sampleItemsFor(testToday));
    bookings = FakeBookingStore(sampleBookingsFor(testToday));
  });

  FakeBookingRepository bookingRepo({DateTime? hariIni}) =>
      FakeBookingRepository(
        storage: storage,
        accounts: accounts,
        items: items,
        bookings: bookings,
        now: () => hariIni ?? testToday,
        delay: Duration.zero,
      );

  group('pembayaran COD', () {
    test('pemilik tidak bisa menyetujui checklist awal sebelum bayar diterima',
        () async {
      final checklist = FakeChecklistRepository(
        store: FakeChecklistStore(const []),
        bookings: bookings,
        items: items,
        now: () => testToday,
        delay: Duration.zero,
        autoApproveDelay: null,
      );
      final c = await checklist.get(gopro, TahapChecklist.awal);
      await checklist.save(c.copyWith(daftarKondisi: [
        for (final (i, k) in c.daftarKondisi.indexed)
          k.copyWith(dicek: true, foto: i < 2 ? 'foto-$i' : null),
      ]));
      expect(bookings.byId(gopro)!.statusBayar, StatusBayar.belum);

      await expectLater(
        checklist.approve(gopro, TahapChecklist.awal, dimas),
        throwsA(isA<ChecklistException>()),
      );

      await storage.saveSession(dimas);
      final b = await bookingRepo().catatPembayaran(gopro,
          metode: MetodeBayar.transfer, diterima: true);
      expect(b.statusBayar, StatusBayar.lunas);
      expect(b.metodeBayar, MetodeBayar.transfer);
      final hasil = await checklist.approve(gopro, TahapChecklist.awal, dimas);
      expect(hasil.disetujuiPemilik, isTrue);
    });

    test('penyewa tidak bisa mencatat pembayaran', () async {
      await expectLater(
        bookingRepo().catatPembayaran(gopro,
            metode: MetodeBayar.tunai, diterima: true),
        throwsA(isA<BookingException>()),
      );
    });
  });

  group('denda keterlambatan', () {
    test('hari lewat tanggal kembali × denda per hari', () {
      expect(
        hitungDenda(
            tanggalKembali: hPlus(-2),
            hariKembali: testToday,
            dendaPerHari: 22500),
        (hari: 2, total: 45000),
      );
      expect(
        hitungDenda(
            tanggalKembali: testToday, hariKembali: testToday, dendaPerHari: 22500),
        (hari: 0, total: 0),
      );
      expect(
        hitungDenda(
            tanggalKembali: hPlus(-3), hariKembali: testToday, dendaPerHari: 0),
        (hari: 3, total: 0),
      );
    });

    test('saran denda 50% harga sewa & teksnya', () {
      expect(saranDenda(45000), 22500);
      expect(teksDenda(22500), 'Denda telat Rp22.500/hari');
      expect(teksDenda(0), 'Tanpa denda keterlambatan');
    });
  });

  group('pembatalan setelah disetujui', () {
    test('H-1: bebas, tidak menambah pembatalan mendadak', () async {
      await bookingRepo().batalkanSewa(gopro, 'Rencana berubah');
      final b = bookings.byId(gopro)!;
      expect(b.status, StatusBooking.dibatalkan);
      expect(b.dibatalkanOleh, gregorian);
      expect(b.alasanBatal, 'Rencana berubah');
      expect(accounts.byId(gregorian)!.user.jumlahBatalMendadak, 0);
    });

    test('hari H: boleh, jumlahBatalMendadak pembatal bertambah', () async {
      await storage.saveSession(dimas);
      await bookingRepo(hariIni: hPlus(1))
          .batalkanSewa(gopro, 'Barang dipakai sendiri');
      expect(bookings.byId(gopro)!.dibatalkanOleh, dimas);
      expect(accounts.byId(dimas)!.user.jumlahBatalMendadak, 1);
      expect(accounts.byId(gregorian)!.user.jumlahBatalMendadak, 0);
    });

    test('tanggal terbuka lagi setelah dibatalkan', () async {
      final repo = bookingRepo();
      final itemId = bookings.byId(gopro)!.itemId;
      bool terkunci(List<dynamic> r) => r.any((x) =>
          rentangBertumpuk(hPlus(1), hPlus(1), x.mulai, x.selesai));
      expect(terkunci(await repo.blockedDates(itemId)), isTrue);
      await repo.batalkanSewa(gopro, 'Rencana berubah');
      expect(terkunci(await repo.blockedDates(itemId)), isFalse);
    });

    test('sewa berlangsung tidak bisa dibatalkan; alasan wajib', () async {
      await expectLater(bookingRepo().batalkanSewa(sony, 'Rencana berubah'),
          throwsA(isA<BookingException>()));
      await expectLater(bookingRepo().batalkanSewa(gopro, '  '),
          throwsA(isA<BookingException>()));
      expect(bookings.byId(sony)!.status, StatusBooking.berlangsung);
    });
  });

  group('laporan', () {
    late FakeLaporanRepository repo;

    setUp(() {
      repo = FakeLaporanRepository(
        store: FakeLaporanStore(const []),
        storage: storage,
        accounts: accounts,
        items: items,
        bookings: bookings,
        now: () => testToday,
        delay: Duration.zero,
      );
    });

    Future<Laporan> kirimDariSarah() async {
      await storage.saveSession(sarah);
      return repo.kirim(
        bookingId: tenda,
        terlaporId: gregorian,
        jenis: JenisLaporan.kerusakan,
        itemBermasalah: const ['Frame, pasak, atau tali lengkap'],
        deskripsi: 'Dua pasak hilang dan satu tali putus saat dikembalikan.',
        usulan: UsulanPenyelesaian.gantiRugi,
        nominal: 20000,
      );
    }

    test('menunggu → diterima → selesai', () async {
      final l = await kirimDariSarah();
      expect(l.status, StatusLaporan.menungguTanggapan);
      await expectLater(
          repo.terimaUsulan(l.id), throwsA(isA<LaporanException>()),
          reason: 'pelapor tidak bisa menanggapi laporannya sendiri');

      await storage.saveSession(gregorian);
      final diterima = await repo.terimaUsulan(l.id);
      expect(diterima.status, StatusLaporan.diterima);
      await expectLater(
          repo.ajukanBanding(l.id), throwsA(isA<LaporanException>()));

      await storage.saveSession(sarah);
      final selesai = await repo.tandaiSelesai(l.id);
      expect(selesai.status, StatusLaporan.selesai);
      expect(selesai.riwayat.map((r) => r.judul),
          ['Laporan dikirim', 'Usulan diterima', 'Laporan selesai']);
    });

    test('menunggu → dibanding', () async {
      final l = await kirimDariSarah();
      await storage.saveSession(gregorian);
      final banding = await repo.ajukanBanding(l.id);
      expect(banding.status, StatusLaporan.dibanding);
      expect(banding.riwayat.last.isi,
          'Diteruskan ke tim HobbySwap untuk ditinjau.');
    });

    test('validasi: deskripsi 20–500, ganti rugi wajib nominal', () async {
      await storage.saveSession(sarah);
      await expectLater(
        repo.kirim(
            bookingId: tenda,
            terlaporId: gregorian,
            jenis: JenisLaporan.kerusakan,
            itemBermasalah: const ['x'],
            deskripsi: 'Terlalu pendek',
            usulan: UsulanPenyelesaian.diskusi),
        throwsA(isA<LaporanException>()),
      );
      await expectLater(
        repo.kirim(
            bookingId: tenda,
            terlaporId: gregorian,
            jenis: JenisLaporan.kerusakan,
            itemBermasalah: const ['x'],
            deskripsi: 'Pasak hilang dua buah saat dikembalikan.',
            usulan: UsulanPenyelesaian.gantiRugi),
        throwsA(isA<LaporanException>()),
      );
    });
  });

  group('data tetap ada setelah store dibuat ulang dari penyimpanan', () {
    ProviderContainer buka() {
      final c = ProviderContainer(overrides: [
        sessionStorageProvider.overrideWithValue(storage),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    test('favorit', () async {
      buka().read(fakeFavoriteStoreProvider).set(gregorian, 'itm-001',
          favorit: true);
      await pumpEventQueue();
      expect(buka().read(fakeFavoriteStoreProvider).of(gregorian),
          ['itm-001']);
    });

    test('sewa, akun, dan laporan', () async {
      final c1 = buka();
      final b = c1.read(fakeBookingStoreProvider);
      b.update(b.byId(gopro)!.copyWith(status: StatusBooking.dibatalkan));
      final a = c1.read(fakeAccountStoreProvider);
      a.updateUser(a.byId(gregorian)!.user.copyWith(bio: 'Bio baru'));
      await pumpEventQueue();

      final c2 = buka();
      expect(c2.read(fakeBookingStoreProvider).byId(gopro)!.status,
          StatusBooking.dibatalkan);
      expect(c2.read(fakeAccountStoreProvider).byId(gregorian)!.user.bio,
          'Bio baru');
      expect(c2.read(fakeLaporanStoreProvider).all, isNotEmpty);
    });
  });
}

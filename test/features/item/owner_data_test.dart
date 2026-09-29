import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/storage/session_storage.dart';
import 'package:hobby_swab/core/utils/dates.dart';
import 'package:hobby_swab/core/utils/formatters.dart';
import 'package:hobby_swab/data/fake/fake_account_store.dart';
import 'package:hobby_swab/data/fake/fake_booking_store.dart';
import 'package:hobby_swab/data/fake/fake_item_store.dart';
import 'package:hobby_swab/data/fake/sample_data.dart';
import 'package:hobby_swab/features/booking/data/fake_booking_repository.dart';
import 'package:hobby_swab/features/booking/domain/booking.dart';
import 'package:hobby_swab/features/booking/domain/booking_repository.dart';
import 'package:hobby_swab/features/booking/domain/owner_stats.dart';
import 'package:hobby_swab/features/item/data/fake_item_repository.dart';
import 'package:hobby_swab/features/item/domain/item.dart';
import 'package:hobby_swab/features/item/domain/item_repository.dart';
import 'package:hobby_swab/features/item/domain/kategori.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/pump_app.dart';

const gregorian = 'usr-001';
const carrier = 'itm-013';
const switchOled = 'itm-014';
const raketYonex = 'itm-015';
const hammock = 'itm-016';

const input = ItemInput(
  judul: '  Drone DJI Mini 2  ',
  deskripsi: 'Termasuk 3 baterai, remote, dan tas. Kondisi mulus.',
  kategori: Kategori.kamera,
  hargaPerHari: 60000,
  lokasiKampus: 'Fasilkom-TI',
);

void main() {
  late SessionStorage storage;
  late FakeItemStore items;
  late FakeBookingStore bookings;
  late FakeItemRepository itemRepo;
  late FakeBookingRepository bookingRepo;

  setUpAll(() => initializeDateFormatting(appLocale));

  setUp(() async {
    storage = await mockStorage({SessionStorage.sessionUserIdKey: gregorian});
    final accounts = FakeAccountStore();
    items = FakeItemStore(sampleItemsFor(testToday));
    bookings = FakeBookingStore(sampleBookingsFor(testToday));
    itemRepo = FakeItemRepository(
      storage: storage,
      accounts: accounts,
      items: items,
      bookings: bookings,
      now: () => testToday,
      delay: Duration.zero,
    );
    bookingRepo = FakeBookingRepository(
      storage: storage,
      accounts: accounts,
      items: items,
      bookings: bookings,
      now: () => testToday,
      delay: Duration.zero,
    );
  });

  Booking booking(String id) => bookings.byId(id)!;
  String idOf(String penyewa, String itemId) => bookings.all
      .firstWhere((b) => b.penyewaId == penyewa && b.itemId == itemId &&
          b.status == StatusBooking.menunggu)
      .id;

  group('ItemRepository (pemilik)', () {
    test('itemsByOwner: termasuk nonaktif, dengan status turunan', () async {
      final mine = await itemRepo.itemsByOwner(gregorian);
      final status = {for (final l in mine) l.item.id: l.status};
      expect(status, {
        carrier: ItemStatus.tersedia,
        switchOled: ItemStatus.disewa,
        raketYonex: ItemStatus.dibarter, // M11: dibarter dengan Keyboard Sarah
        hammock: ItemStatus.nonaktif,
      });
      final sw = mine.firstWhere((l) => l.item.id == switchOled);
      expect(sw.disewaSampai, hPlus(2));
    });

    test('create: milik user yang masuk, di-trim, tampil di Beranda orang lain',
        () async {
      final item = await itemRepo.create(input);
      expect(item.ownerId, gregorian);
      expect(item.judul, 'Drone DJI Mini 2');
      expect(item.aktif, isTrue);
      expect((await itemRepo.itemsByOwner(gregorian)).first.item.id, item.id);

      await storage.saveSession('usr-003');
      final beranda = await itemRepo.fetchItems();
      expect(beranda.map((l) => l.item.id), contains(item.id));
    });

    test('update & setAktif', () async {
      final updated = await itemRepo.update(
        raketYonex,
        const ItemInput(
          judul: 'Raket Yonex Astrox 88D',
          deskripsi: 'Untuk pemain depan-belakang. Grip baru, senar 27 lbs.',
          kategori: Kategori.olahraga,
          hargaPerHari: 18000,
          lokasiKampus: 'Pintu 4',
        ),
      );
      expect(updated.hargaPerHari, 18000);
      expect(items.byId(raketYonex)!.judul, 'Raket Yonex Astrox 88D');

      await itemRepo.setAktif(raketYonex, false);
      await storage.saveSession('usr-003');
      final beranda = await itemRepo.fetchItems();
      expect(beranda.map((l) => l.item.id), isNot(contains(raketYonex)));
    });

    test('hapus ditolak bila masih ada sewa menunggu/berlangsung', () async {
      final ditolak = throwsA(isA<ItemException>().having((e) => e.message,
          'message', 'Masih ada sewa aktif untuk barang ini'));
      await expectLater(itemRepo.delete(carrier), ditolak); // menunggu
      await expectLater(itemRepo.delete(switchOled), ditolak); // berlangsung
      await itemRepo.delete(hammock); // hanya riwayat selesai
      expect(items.byId(hammock), isNull);
    });

    test('tidak bisa mengubah barang orang lain', () async {
      await expectLater(
          itemRepo.setAktif('itm-001', false), throwsA(isA<ItemException>()));
    });
  });

  group('BookingRepository (pemilik)', () {
    test('approve: tanggal terblokir & pengajuan bertumpuk otomatis ditolak',
        () async {
      final aulia = idOf('usr-002', carrier);
      final sarah = idOf('usr-004', carrier);

      final ditolak = await bookingRepo.approve(aulia);

      expect(ditolak, 1);
      expect(booking(aulia).status, StatusBooking.disetujui);
      expect(booking(sarah).status, StatusBooking.ditolak);
      expect(booking(sarah).alasanTolak, 'Tanggal sudah diambil penyewa lain');
      final blocked = await bookingRepo.blockedDates(carrier);
      expect(blocked.map((r) => (r.mulai, r.selesai)),
          contains((hPlus(20), hPlus(22))));
    });

    test('approve pengajuan yang tidak bertumpuk tidak menolak yang lain',
        () async {
      expect(await bookingRepo.approve(idOf('usr-005', raketYonex)), 0);
    });

    test('approve yang bentrok dengan sewa disetujui → exception', () async {
      // Pengajuan menunggu yang menabrak sewa berlangsung Switch OLED.
      bookings.add(Booking(
        id: 'bkg-900',
        itemId: switchOled,
        penyewaId: 'usr-003',
        tanggalMulai: hPlus(2),
        tanggalKembali: hPlus(3),
        totalHarga: 80000,
        dibuatPada: testToday,
      ));
      await expectLater(
          bookingRepo.approve('bkg-900'), throwsA(isA<BookingConflictException>()));
      expect(booking('bkg-900').status, StatusBooking.menunggu);
    });

    test('approve dua kali → sudah diproses', () async {
      final id = idOf('usr-005', raketYonex);
      await bookingRepo.approve(id);
      await expectLater(bookingRepo.approve(id), throwsA(isA<BookingException>()));
    });

    test('reject menyimpan alasan; alasan kosong ditolak', () async {
      final id = idOf('usr-005', raketYonex);
      await expectLater(
          bookingRepo.reject(id, '  '), throwsA(isA<BookingException>()));
      await bookingRepo.reject(id, 'Barangnya lagi dipakai');
      expect(booking(id).status, StatusBooking.ditolak);
      expect(booking(id).alasanTolak, 'Barangnya lagi dipakai');
    });

    test('bukan pemilik tidak bisa menyetujui', () async {
      await storage.saveSession('usr-003');
      await expectLater(bookingRepo.approve(idOf('usr-005', raketYonex)),
          throwsA(isA<BookingException>()));
    });

    test('barang nonaktif tidak bisa disewa', () async {
      await storage.saveSession('usr-003');
      await expectLater(
        bookingRepo.create(itemId: hammock, mulai: hPlus(1), kembali: hPlus(2)),
        throwsA(isA<BookingException>()),
      );
    });

    test('bookingsForOwner membawa barang & penyewa', () async {
      final list = await bookingRepo.bookingsForOwner(gregorian);
      final aulia = list.firstWhere((d) => d.penyewa.id == 'usr-002');
      expect(aulia.item.judul, 'Carrier Eiger Rhinos 45L');
      expect(aulia.booking.pesan, startsWith('Buat pendakian Sibayak'));
      expect(aulia.pemilik.id, gregorian);
    });
  });

  group('statistik pemilik', () {
    test('pendapatan bulan ini & jumlah disewakan', () async {
      final mine = await bookingRepo.bookingsForOwner(gregorian);
      final s = hitungStatistikPemilik(mine.map((d) => d.booking), testToday);
      // Selesai bulan ini: 50rb + 80rb + 30rb; berlangsung Switch: 4 × 40rb.
      expect(s.pendapatanBulanIni, 320000);
      expect(s.jumlahDisewakan, 12);
      expect(formatRupiahRingkas(s.pendapatanBulanIni), 'Rp320rb');
    });

    test('format ringkas', () {
      expect(formatRupiahRingkas(12500), 'Rp12,5rb');
      expect(formatRupiahRingkas(2000000), 'Rp2jt');
      expect(formatRupiahRingkas(1300000), 'Rp1,3jt');
      expect(formatRupiahRingkas(800), 'Rp800');
    });

    test('ringkasan nama peminta', () {
      expect(ringkasPeminta(['Aulia Putri']),
          'Aulia Putri ingin menyewa barangmu');
      expect(ringkasPeminta(['Aulia Putri', 'Dimas']),
          'Aulia Putri dan Dimas ingin menyewa barangmu');
      expect(ringkasPeminta(['A', 'B', 'C']),
          'A dan 2 lainnya ingin menyewa barangmu');
    });
  });
}

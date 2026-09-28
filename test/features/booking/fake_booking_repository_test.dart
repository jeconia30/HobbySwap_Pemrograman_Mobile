import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/storage/session_storage.dart';
import 'package:hobby_swab/data/fake/fake_account_store.dart';
import 'package:hobby_swab/data/fake/fake_booking_store.dart';
import 'package:hobby_swab/data/fake/fake_item_store.dart';
import 'package:hobby_swab/data/fake/sample_data.dart';
import 'package:hobby_swab/features/booking/data/fake_booking_repository.dart';
import 'package:hobby_swab/features/booking/domain/booking.dart';
import 'package:hobby_swab/features/booking/domain/booking_repository.dart';

import '../../helpers/pump_app.dart';

const gregorian = 'usr-001';
const sony = 'itm-001'; // milik Rizky, blokir pemilik h+2..h+3 & h+9..h+10
const tenda = 'itm-004'; // sewa disetujui h+4..h+6
const carrierEiger = 'itm-013'; // milik Gregorian

void main() {
  late SessionStorage storage;
  late FakeBookingRepository repo;

  setUp(() async {
    storage = await mockStorage({SessionStorage.sessionUserIdKey: gregorian});
    repo = FakeBookingRepository(
      storage: storage,
      accounts: FakeAccountStore(),
      items: FakeItemStore(sampleItemsFor(testToday)),
      bookings: FakeBookingStore(sampleBookingsFor(testToday)),
      now: () => testToday,
      delay: Duration.zero,
    );
  });

  Matcher throwsMessage(String message) => throwsA(
      isA<BookingException>().having((e) => e.message, 'message', message));

  test('pengajuan valid: status menunggu, total inklusif, pesan di-trim',
      () async {
    final b = await repo.create(
      itemId: sony,
      mulai: hPlus(4),
      kembali: hPlus(6),
      pesan: '  buat liputan  ',
    );
    expect(b.status, StatusBooking.menunggu);
    expect(b.penyewaId, gregorian);
    expect(b.totalHarga, 3 * 45000);
    expect(b.pesan, 'buat liputan');
    expect(b.dibuatPada, testToday);
    expect((await repo.bookingsForRenter(gregorian)).map((d) => d.booking),
        contains(b));
  });

  test('pesan kosong disimpan sebagai null', () async {
    final b = await repo.create(
        itemId: sony, mulai: hPlus(4), kembali: hPlus(4), pesan: '   ');
    expect(b.pesan, isNull);
  });

  test('bentrok dengan blokir pemilik → BookingConflictException', () async {
    await expectLater(
      repo.create(itemId: sony, mulai: hPlus(1), kembali: hPlus(2)),
      throwsA(isA<BookingConflictException>().having((e) => e.message,
          'message', 'Ada tanggal yang sudah disewa orang lain. Pilih tanggal lain, ya.')),
    );
  });

  test('bentrok dengan sewa disetujui → BookingConflictException', () async {
    await expectLater(
      repo.create(itemId: tenda, mulai: hPlus(6), kembali: hPlus(8)),
      throwsA(isA<BookingConflictException>()),
    );
  });

  test('bersebelahan dengan blokir tidak bentrok', () async {
    final b = await repo.create(itemId: sony, mulai: hPlus(4), kembali: hPlus(8));
    expect(b.status, StatusBooking.menunggu);
  });

  test('pengajuan menunggu milik orang lain tidak memblokir', () async {
    // bkg-004: Dimas menunggu Sony h+6.
    final b = await repo.create(itemId: sony, mulai: hPlus(6), kembali: hPlus(6));
    expect(b.status, StatusBooking.menunggu);
  });

  test('menyewa barang sendiri ditolak', () async {
    await expectLater(
      repo.create(itemId: carrierEiger, mulai: hPlus(1), kembali: hPlus(2)),
      throwsMessage('Ini barangmu sendiri.'),
    );
  });

  test('pengajuan ganda (rentang bertumpuk, masih menunggu) ditolak', () async {
    await repo.create(itemId: sony, mulai: hPlus(4), kembali: hPlus(6));
    await expectLater(
      repo.create(itemId: sony, mulai: hPlus(6), kembali: hPlus(7)),
      throwsMessage(
          'Kamu sudah mengajukan tanggal ini. Tunggu jawaban pemilik dulu.'),
    );
    // Rentang lain di barang yang sama tetap boleh.
    final lain = await repo.create(
        itemId: sony, mulai: hPlus(11), kembali: hPlus(12));
    expect(lain.status, StatusBooking.menunggu);
  });

  test('lebih dari 14 hari ditolak', () async {
    await expectLater(
      repo.create(itemId: sony, mulai: hPlus(11), kembali: hPlus(25)),
      throwsMessage('Maksimal 14 hari sekali sewa'),
    );
  });

  test('tanggal mulai lampau ditolak', () async {
    await expectLater(
      repo.create(itemId: sony, mulai: hPlus(-1), kembali: hPlus(1)),
      throwsA(isA<BookingException>()),
    );
  });

  test('blockedDates = blokir pemilik + sewa disetujui/berlangsung', () async {
    final sonyBlocked = await repo.blockedDates(sony);
    // Blokir pemilik + sewa berlangsung Gregorian (h-1..h+1).
    expect(sonyBlocked.map((r) => (r.mulai, r.selesai)), [
      (hPlus(2), hPlus(3)),
      (hPlus(9), hPlus(10)),
      (hPlus(-1), hPlus(1)),
    ]);

    final tendaBlocked = await repo.blockedDates(tenda);
    expect(tendaBlocked.map((r) => (r.mulai, r.selesai)),
        containsAll([(hPlus(12), hPlus(13)), (hPlus(4), hPlus(6))]));
  });

  test('bookingsForOwner hanya sewa atas barang milik user itu', () async {
    final rizky = await repo.bookingsForOwner('usr-003');
    expect(rizky.map((d) => d.booking.itemId).toSet(), {sony, 'itm-009'});
  });
}

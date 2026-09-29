import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/storage/session_storage.dart';
import 'package:hobby_swab/core/storage/settings_storage.dart';
import 'package:hobby_swab/data/fake/fake_account_store.dart';
import 'package:hobby_swab/data/fake/fake_booking_store.dart';
import 'package:hobby_swab/data/fake/fake_item_store.dart';
import 'package:hobby_swab/data/fake/fake_notification_store.dart';
import 'package:hobby_swab/data/fake/sample_data.dart';
import 'package:hobby_swab/features/activity/data/fake_notification_repository.dart';
import 'package:hobby_swab/features/activity/domain/notification_item.dart';
import 'package:hobby_swab/features/booking/data/fake_booking_repository.dart';
import 'package:hobby_swab/features/booking/domain/booking.dart';

import '../../helpers/pump_app.dart';

const gregorian = 'usr-001';
const rizky = 'usr-003';
const sony = 'itm-001'; // milik Rizky

void main() {
  group('notifikasi dari kejadian sewa', () {
    late SessionStorage storage;
    late FakeNotificationStore notifs;
    late FakeBookingRepository repo;

    setUp(() async {
      storage = await mockStorage({SessionStorage.sessionUserIdKey: gregorian});
      notifs = FakeNotificationStore(const [], now: () => testToday);
      repo = FakeBookingRepository(
        storage: storage,
        accounts: FakeAccountStore(),
        items: FakeItemStore(sampleItemsFor(testToday)),
        bookings: FakeBookingStore(sampleBookingsFor(testToday)),
        now: () => testToday,
        notifications: notifs,
        delay: Duration.zero,
      );
    });

    List<NotificationItem> untuk(String userId) =>
        notifs.all.where((n) => n.userId == userId).toList();

    test('pengajuan baru → pemilik dapat "pengajuanBaru"', () async {
      await repo.create(itemId: sony, mulai: hPlus(4), kembali: hPlus(6));
      expect(untuk(rizky).map((n) => n.tipe), [TipeNotifikasi.pengajuanBaru]);
      expect(untuk(gregorian), isEmpty);
    });

    test('disetujui → penyewa dapat "pengajuanDisetujui"', () async {
      final b =
          await repo.create(itemId: sony, mulai: hPlus(4), kembali: hPlus(6));
      await storage.saveSession(rizky);
      await repo.approve(b.id);
      final n = untuk(gregorian).single;
      expect(n.tipe, TipeNotifikasi.pengajuanDisetujui);
      expect(n.sudahDibaca, isFalse);
      expect(n.tautan, isNotNull);
    });

    test('ditolak → penyewa dapat "pengajuanDitolak" berisi alasan', () async {
      final b =
          await repo.create(itemId: sony, mulai: hPlus(4), kembali: hPlus(6));
      await storage.saveSession(rizky);
      await repo.reject(b.id, 'Kameranya lagi diservis');
      final n = untuk(gregorian).single;
      expect(n.tipe, TipeNotifikasi.pengajuanDitolak);
      expect(n.isi, contains('Kameranya lagi diservis'));
    });
  });

  group('pengingat relatif ke hari ini', () {
    Booking sewa(String id, StatusBooking status, DateTime mulai,
            DateTime kembali) =>
        Booking(
          id: id,
          itemId: sony,
          penyewaId: gregorian,
          tanggalMulai: mulai,
          tanggalKembali: kembali,
          totalHarga: 45000,
          status: status,
          dibuatPada: hPlus(-10),
        );

    test('H-1 ambil untuk sewa disetujui yang mulai besok', () {
      final hasil = hitungPengingat([
        sewa('a', StatusBooking.disetujui, hPlus(1), hPlus(2)),
        sewa('b', StatusBooking.disetujui, hPlus(3), hPlus(4)),
      ], (_) => null, testToday);
      expect(hasil.single.tipe, TipeNotifikasi.pengingatAmbil);
      expect(hasil.single.userId, gregorian);
    });

    test('H-1 & hari H kembali untuk sewa berlangsung', () {
      final hasil = hitungPengingat([
        sewa('a', StatusBooking.berlangsung, hPlus(-1), hPlus(1)),
        sewa('b', StatusBooking.berlangsung, hPlus(-2), testToday),
      ], (_) => null, testToday);
      expect(hasil.map((n) => n.tipe),
          everyElement(TipeNotifikasi.pengingatKembali));
      expect(hasil.map((n) => n.judul),
          [startsWith('Besok'), startsWith('Hari ini')]);
    });

    test('terlambat untuk sewa berlangsung yang lewat tanggal kembali', () {
      final hasil = hitungPengingat([
        sewa('a', StatusBooking.berlangsung, hPlus(-5), hPlus(-2)),
        sewa('b', StatusBooking.selesai, hPlus(-5), hPlus(-2)),
      ], (_) => null, testToday);
      expect(hasil.single.tipe, TipeNotifikasi.terlambat);
      expect(hasil.single.judul, startsWith('Terlambat 2 hari'));
    });
  });

  test('markAllRead → unreadCount 0', () async {
    final repo = FakeNotificationRepository(
      store: FakeNotificationStore(sampleNotificationsFor(testToday),
          now: () => testToday),
      delay: Duration.zero,
    );
    expect(await repo.unreadCount(gregorian).first, greaterThan(0));
    await repo.markAllRead(gregorian);
    expect(await repo.unreadCount(gregorian).first, 0);
    expect((await repo.list(gregorian)).every((n) => n.sudahDibaca), isTrue);
  });

  test('themeMode tersimpan dan terbaca lagi saat app dibuka ulang', () async {
    await mockStorage();
    final container = ProviderContainer(overrides: [
      settingsStorageProvider.overrideWithValue(await SettingsStorage.create()),
    ]);
    addTearDown(container.dispose);
    expect(container.read(settingsControllerProvider).themeMode,
        ThemeMode.system);

    await container
        .read(settingsControllerProvider.notifier)
        .setThemeMode(ThemeMode.dark);
    expect(container.read(settingsControllerProvider).themeMode,
        ThemeMode.dark);

    final dibukaUlang = await SettingsStorage.create();
    expect(dibukaUlang.themeMode, ThemeMode.dark);
  });
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/clock.dart';
import '../../features/activity/domain/notification_item.dart';
import 'fake_booking_store.dart';
import 'fake_item_store.dart';
import 'fake_persistence.dart';
import 'sample_data.dart';

/// Notifikasi di memori. Repository palsu lain memanggil [kirim] saat terjadi
/// kejadian (pengajuan, persetujuan, checklist, ulasan, verifikasi).
class FakeNotificationStore {
  FakeNotificationStore(
    List<NotificationItem> seed, {
    DateTime Function()? now,
    this._db = const FakePersistence.none(),
  })  : _items = [...seed],
        _now = now ?? DateTime.now;

  static const storageKey = 'notifications';

  final FakePersistence _db;

  void _changed() {
    _db.save(storageKey, _items, (n) => n.toJson());
    _changes.add(null);
  }

  final List<NotificationItem> _items;
  final DateTime Function() _now;
  final _changes = StreamController<void>.broadcast();
  var _seq = 0;

  Stream<void> get changes => _changes.stream;

  List<NotificationItem> get all => List.unmodifiable(_items);

  void kirim({
    required String userId,
    required TipeNotifikasi tipe,
    required String judul,
    required String isi,
    String? tautan,
  }) {
    _items.add(NotificationItem(
      id: 'ntf-baru-${++_seq}-${_now().microsecondsSinceEpoch}',
      userId: userId,
      tipe: tipe,
      judul: judul,
      isi: isi,
      tanggal: _now(),
      tautan: tautan,
    ));
    _changed();
  }

  void put(NotificationItem item) {
    final i = _items.indexWhere((n) => n.id == item.id);
    if (i < 0) {
      _items.add(item);
    } else {
      _items[i] = item;
    }
    _changed();
  }

  void remove(String id) {
    _items.removeWhere((n) => n.id == id);
    _changed();
  }
}

final fakeNotificationStoreProvider = Provider<FakeNotificationStore>((ref) {
  final now = ref.watch(clockProvider);
  final items = ref.watch(fakeItemStoreProvider);
  final bookings = ref.watch(fakeBookingStoreProvider);
  final db = ref.watch(fakePersistenceProvider);
  final tersimpan = db.load(
      FakeNotificationStore.storageKey, NotificationItem.fromJson);
  final base = tersimpan ?? sampleNotificationsFor(now());
  final ada = {for (final n in base) n.id};
  return FakeNotificationStore(
    [
      ...base,
      // Pengingat hari ini (id per tanggal, jadi tidak dobel).
      for (final n in hitungPengingat(bookings.all, items.byId, now()))
        if (!ada.contains(n.id)) n,
    ],
    now: now,
    db: db,
  );
});

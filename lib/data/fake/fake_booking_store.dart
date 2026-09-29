import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/clock.dart';
import '../../features/booking/domain/booking.dart';
import 'fake_persistence.dart';
import 'sample_data.dart';

/// Sewa di memori, dipakai bersama oleh repository palsu.
class FakeBookingStore {
  FakeBookingStore(List<Booking> seed,
      [this._db = const FakePersistence.none()])
      : _bookings = [...seed];

  static const storageKey = 'bookings';

  final List<Booking> _bookings;
  final FakePersistence _db;

  void _simpan() => _db.save(storageKey, _bookings, (b) => b.toJson());

  List<Booking> get all => List.unmodifiable(_bookings);

  int get length => _bookings.length;

  Booking? byId(String id) => _bookings.where((b) => b.id == id).firstOrNull;

  void add(Booking booking) {
    _bookings.add(booking);
    _simpan();
  }

  Booking update(Booking booking) {
    final i = _bookings.indexWhere((b) => b.id == booking.id);
    if (i < 0) throw StateError('Sewa ${booking.id} tidak ada');
    _bookings[i] = booking;
    _simpan();
    return booking;
  }
}

final fakeBookingStoreProvider = Provider<FakeBookingStore>((ref) {
  final db = ref.watch(fakePersistenceProvider);
  return FakeBookingStore(
    db.load(FakeBookingStore.storageKey, Booking.fromJson) ??
        sampleBookingsFor(ref.watch(clockProvider)()),
    db,
  );
});

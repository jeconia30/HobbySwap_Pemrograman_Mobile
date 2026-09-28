import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/clock.dart';
import '../../features/booking/domain/booking.dart';
import 'sample_data.dart';

/// Sewa di memori, dipakai bersama oleh repository palsu.
class FakeBookingStore {
  FakeBookingStore(List<Booking> seed) : _bookings = [...seed];

  final List<Booking> _bookings;

  List<Booking> get all => List.unmodifiable(_bookings);

  int get length => _bookings.length;

  Booking? byId(String id) => _bookings.where((b) => b.id == id).firstOrNull;

  void add(Booking booking) => _bookings.add(booking);

  Booking update(Booking booking) {
    final i = _bookings.indexWhere((b) => b.id == booking.id);
    if (i < 0) throw StateError('Sewa ${booking.id} tidak ada');
    return _bookings[i] = booking;
  }
}

final fakeBookingStoreProvider = Provider<FakeBookingStore>(
  (ref) => FakeBookingStore(sampleBookingsFor(ref.watch(clockProvider)())),
);

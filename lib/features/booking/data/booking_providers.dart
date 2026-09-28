import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/session_storage.dart';
import '../../../core/utils/clock.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../item/domain/item.dart';
import '../domain/booking.dart';
import '../domain/booking_repository.dart';
import 'fake_booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => FakeBookingRepository(
    storage: ref.watch(sessionStorageProvider),
    accounts: ref.watch(fakeAccountStoreProvider),
    items: ref.watch(fakeItemStoreProvider),
    bookings: ref.watch(fakeBookingStoreProvider),
    now: ref.watch(clockProvider),
  ),
);

final bookingByIdProvider =
    FutureProvider.autoDispose.family<BookingDetail?, String>(
  (ref, id) => ref.watch(bookingRepositoryProvider).bookingById(id),
  retry: (_, _) => null,
);

final blockedDatesProvider =
    FutureProvider.autoDispose.family<List<RentangTanggal>, String>(
  (ref, itemId) => ref.watch(bookingRepositoryProvider).blockedDates(itemId),
  retry: (_, _) => null,
);

/// Pengajuan milik user yang sedang masuk sebagai penyewa (terbaru dulu).
final myBookingsProvider = FutureProvider.autoDispose<List<BookingDetail>>(
  (ref) {
    final userId = ref.watch(authControllerProvider.select((u) => u?.id));
    if (userId == null) return const [];
    return ref.watch(bookingRepositoryProvider).bookingsForRenter(userId);
  },
  retry: (_, _) => null,
);

/// Semua sewa atas barang milik user yang sedang masuk (terbaru dulu).
final ownerBookingsProvider = FutureProvider.autoDispose<List<BookingDetail>>(
  (ref) {
    final userId = ref.watch(authControllerProvider.select((u) => u?.id));
    if (userId == null) return const [];
    return ref.watch(bookingRepositoryProvider).bookingsForOwner(userId);
  },
  retry: (_, _) => null,
);

/// Jumlah pengajuan masuk yang menunggu jawaban (badge tab Barang).
final pendingIncomingCountProvider = Provider.autoDispose<int>((ref) =>
    ref
        .watch(ownerBookingsProvider)
        .value
        ?.where((d) => d.booking.status == StatusBooking.menunggu)
        .length ??
    0);

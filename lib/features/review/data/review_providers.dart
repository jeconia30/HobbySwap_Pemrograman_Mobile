import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/fake/fake_notification_store.dart';

import '../../../core/storage/session_storage.dart';
import '../../../core/utils/clock.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_handover_review_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/review.dart';
import '../domain/review_repository.dart';
import 'fake_review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => FakeReviewRepository(
    storage: ref.watch(sessionStorageProvider),
    accounts: ref.watch(fakeAccountStoreProvider),
    items: ref.watch(fakeItemStoreProvider),
    bookings: ref.watch(fakeBookingStoreProvider),
    reviews: ref.watch(fakeReviewStoreProvider),
    now: ref.watch(clockProvider),
    notifications: ref.watch(fakeNotificationStoreProvider),
  ),
);

/// Ulasan yang diterima user (terbaru dulu).
final reviewsForUserProvider = FutureProvider.autoDispose
    .family<List<ReviewDetail>, String>(
      (ref, userId) => ref.watch(reviewRepositoryProvider).reviewsFor(userId),
      retry: (_, _) => null,
    );

/// Id sewa yang sudah dinilai user yang sedang masuk.
final myReviewedBookingIdsProvider = FutureProvider.autoDispose<Set<String>>((
  ref,
) async {
  final userId = ref.watch(authControllerProvider.select((u) => u?.id));
  if (userId == null) return const {};
  final reviews = await ref.watch(reviewRepositoryProvider).reviewsBy(userId);
  return {for (final r in reviews) r.bookingId};
}, retry: (_, _) => null);

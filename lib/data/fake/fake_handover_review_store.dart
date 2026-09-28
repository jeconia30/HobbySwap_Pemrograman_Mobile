import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/handover/domain/handover_checklist.dart';
import '../../features/review/domain/review.dart';
import 'fake_booking_store.dart';
import 'sample_data.dart';

/// Checklist serah terima di memori.
class FakeChecklistStore {
  FakeChecklistStore(List<HandoverChecklist> seed) {
    for (final c in seed) {
      put(c);
    }
  }

  final _byKey = <(String, TahapChecklist), HandoverChecklist>{};

  HandoverChecklist? get(String bookingId, TahapChecklist tahap) =>
      _byKey[(bookingId, tahap)];

  HandoverChecklist put(HandoverChecklist c) =>
      _byKey[(c.bookingId, c.tahap)] = c;
}

/// Ulasan di memori.
class FakeReviewStore {
  FakeReviewStore(List<Review> seed) : _reviews = [...seed];

  final List<Review> _reviews;

  List<Review> get all => List.unmodifiable(_reviews);

  int get length => _reviews.length;

  void add(Review review) => _reviews.add(review);
}

final fakeChecklistStoreProvider = Provider<FakeChecklistStore>(
  (ref) => FakeChecklistStore(
      sampleChecklistsFor(ref.watch(fakeBookingStoreProvider).all)),
);

final fakeReviewStoreProvider = Provider<FakeReviewStore>(
  (ref) =>
      FakeReviewStore(sampleReviewsFor(ref.watch(fakeBookingStoreProvider).all)),
);

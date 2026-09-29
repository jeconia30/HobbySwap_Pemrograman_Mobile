import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/handover/domain/handover_checklist.dart';
import '../../features/review/domain/review.dart';
import 'fake_booking_store.dart';
import 'fake_persistence.dart';
import 'sample_data.dart';

/// Checklist serah terima di memori.
class FakeChecklistStore {
  FakeChecklistStore(List<HandoverChecklist> seed,
      [this._db = const FakePersistence.none()]) {
    for (final c in seed) {
      _byKey[(c.bookingId, c.tahap, c.itemId ?? '')] = c;
    }
  }

  static const storageKey = 'checklists';

  final FakePersistence _db;
  /// Kunci: sewa, tahap, barang ('' = barang utama).
  final _byKey = <(String, TahapChecklist, String), HandoverChecklist>{};

  List<HandoverChecklist> get all => List.unmodifiable(_byKey.values);

  HandoverChecklist? get(String bookingId, TahapChecklist tahap,
          {String? itemId}) =>
      _byKey[(bookingId, tahap, itemId ?? '')];

  HandoverChecklist put(HandoverChecklist c) {
    _byKey[(c.bookingId, c.tahap, c.itemId ?? '')] = c;
    _db.save(storageKey, _byKey.values, (c) => c.toJson());
    return c;
  }
}

/// Ulasan di memori.
class FakeReviewStore {
  FakeReviewStore(List<Review> seed, [this._db = const FakePersistence.none()])
      : _reviews = [...seed];

  static const storageKey = 'reviews';

  final List<Review> _reviews;
  final FakePersistence _db;

  List<Review> get all => List.unmodifiable(_reviews);

  int get length => _reviews.length;

  void add(Review review) {
    _reviews.add(review);
    _db.save(storageKey, _reviews, (r) => r.toJson());
  }
}

final fakeChecklistStoreProvider = Provider<FakeChecklistStore>((ref) {
  final db = ref.watch(fakePersistenceProvider);
  return FakeChecklistStore(
    db.load(FakeChecklistStore.storageKey, HandoverChecklist.fromJson) ??
        sampleChecklistsFor(ref.watch(fakeBookingStoreProvider).all),
    db,
  );
});

final fakeReviewStoreProvider = Provider<FakeReviewStore>((ref) {
  final db = ref.watch(fakePersistenceProvider);
  return FakeReviewStore(
    db.load(FakeReviewStore.storageKey, Review.fromJson) ??
        sampleReviewsFor(ref.watch(fakeBookingStoreProvider).all),
    db,
  );
});

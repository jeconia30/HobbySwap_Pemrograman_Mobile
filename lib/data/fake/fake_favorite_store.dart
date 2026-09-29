import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fake_persistence.dart';

/// Favorit per user: urutan = urutan ditandai (terbaru di akhir).
class FakeFavoriteStore {
  FakeFavoriteStore([
    Map<String, List<String>> seed = const {},
    this._db = const FakePersistence.none(),
  ]) : _byUser = {for (final e in seed.entries) e.key: [...e.value]};

  static const storageKey = 'favorit';

  final Map<String, List<String>> _byUser;
  final FakePersistence _db;
  final _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  List<String> of(String userId) => List.unmodifiable(_byUser[userId] ?? []);

  void set(String userId, String itemId, {required bool favorit}) {
    final list = _byUser.putIfAbsent(userId, () => []);
    list.remove(itemId);
    if (favorit) list.add(itemId);
    _db.save(storageKey, _byUser.entries,
        (e) => {'userId': e.key, 'itemIds': e.value});
    _changes.add(null);
  }

  static Map<String, List<String>> fromSaved(
          List<({String userId, List<String> itemIds})> rows) =>
      {for (final r in rows) r.userId: r.itemIds};
}

final fakeFavoriteStoreProvider = Provider<FakeFavoriteStore>((ref) {
  final db = ref.watch(fakePersistenceProvider);
  final rows = db.load(
    FakeFavoriteStore.storageKey,
    (j) => (
      userId: j['userId'] as String,
      itemIds: [for (final id in j['itemIds'] as List) id as String],
    ),
  );
  return FakeFavoriteStore(
      rows == null ? const {} : FakeFavoriteStore.fromSaved(rows), db);
});

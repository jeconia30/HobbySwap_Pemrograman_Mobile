import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/session_storage.dart';
import '../../../data/fake/fake_favorite_store.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../item/data/item_providers.dart';
import '../../item/domain/item.dart';
import '../../item/domain/item_repository.dart';
import '../domain/favorite_repository.dart';

class FakeFavoriteRepository implements FavoriteRepository {
  FakeFavoriteRepository({
    required this._store,
    required this._storage,
    required this._items,
  });

  final FakeFavoriteStore _store;
  final SessionStorage _storage;
  final ItemRepository _items;

  @override
  Stream<Set<String>> favoritIds(String userId) async* {
    yield _store.of(userId).toSet();
    yield* _store.changes.map((_) => _store.of(userId).toSet());
  }

  @override
  Future<void> setFavorit(String itemId, {required bool favorit}) async {
    final me = _storage.sessionUserId;
    if (me == null) return;
    _store.set(me, itemId, favorit: favorit);
  }

  @override
  Future<List<ItemListing>> favoritku(String userId) async {
    final listings = await Future.wait(
        _store.of(userId).reversed.map(_items.itemById));
    return listings.nonNulls.toList();
  }
}

final favoriteRepositoryProvider = Provider<FavoriteRepository>(
  (ref) => FakeFavoriteRepository(
    store: ref.watch(fakeFavoriteStoreProvider),
    storage: ref.watch(sessionStorageProvider),
    items: ref.watch(itemRepositoryProvider),
  ),
);

/// Id barang favorit user yang sedang masuk (hati di kartu & Detail).
final favoritIdsProvider = StreamProvider.autoDispose<Set<String>>((ref) {
  final userId = ref.watch(authControllerProvider.select((u) => u?.id));
  if (userId == null) return Stream.value(const {});
  return ref.watch(favoriteRepositoryProvider).favoritIds(userId);
}, retry: (_, _) => null);

/// Halaman Favoritku.
final favoritkuProvider = FutureProvider.autoDispose<List<ItemListing>>((ref) {
  final userId = ref.watch(authControllerProvider.select((u) => u?.id));
  if (userId == null) return const [];
  // Muat ulang saat daftar favorit berubah.
  ref.watch(favoritIdsProvider);
  return ref.watch(favoriteRepositoryProvider).favoritku(userId);
}, retry: (_, _) => null);

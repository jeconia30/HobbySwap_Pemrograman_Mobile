import '../../item/domain/item.dart';

/// Barang favorit per user (tersimpan di perangkat untuk sekarang).
abstract interface class FavoriteRepository {
  /// Id barang favorit [userId]; nilai baru setiap kali berubah.
  Stream<Set<String>> favoritIds(String userId);

  /// Tandai/lepas favorit untuk user yang sedang masuk.
  Future<void> setFavorit(String itemId, {required bool favorit});

  /// Barang favorit [userId] yang masih ada, terbaru ditandai dulu.
  Future<List<ItemListing>> favoritku(String userId);
}

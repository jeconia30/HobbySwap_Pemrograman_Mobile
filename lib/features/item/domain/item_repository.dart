import 'item.dart';
import 'item_filter.dart';
import 'kategori.dart';

class ItemException implements Exception {
  const ItemException(this.message);

  final String message;

  @override
  String toString() => 'ItemException: $message';
}

/// Kontrak data barang. [fetchItems] hanya barang aktif dan bukan milik user
/// yang sedang masuk. Melempar [ItemException] bila gagal/ditolak.
abstract interface class ItemRepository {
  Future<List<ItemListing>> fetchItems({
    String query = '',
    Kategori? kategori,
    ItemSort sort = ItemSort.terpopuler,
    int? hargaMaks,
    bool hanyaTersedia = false,
    bool hanyaBarter = false,
  });

  Future<ItemListing?> itemById(String id);

  /// Semua barang milik [userId] (termasuk nonaktif), terbaru dulu.
  Future<List<ItemListing>> itemsByOwner(String userId);

  /// Pemilik = user yang sedang masuk.
  Future<Item> create(ItemInput input);

  Future<Item> update(String id, ItemInput input);

  Future<void> setAktif(String id, bool aktif);

  /// Ditolak bila masih ada sewa menunggu/disetujui/berlangsung.
  Future<void> delete(String id);
}

import 'package:freezed_annotation/freezed_annotation.dart';

import 'item.dart';
import 'kategori.dart';

part 'item_filter.freezed.dart';

enum ItemSort {
  terpopuler('Terpopuler'),
  termurah('Termurah'),
  ratingTertinggi('Rating tertinggi');

  const ItemSort(this.label);

  final String label;
}

/// Rentang slider "Harga maksimal per hari". Nilai [max] = tanpa batas.
abstract final class HargaFilter {
  static const min = 10000;
  static const max = 50000;
  static const step = 5000;
}

@freezed
abstract class ItemFilter with _$ItemFilter {
  const ItemFilter._();

  const factory ItemFilter({
    @Default('') String query,
    Kategori? kategori,
    @Default(ItemSort.terpopuler) ItemSort sort,

    /// `null` = tanpa batas harga.
    int? hargaMaks,
    @Default(false) bool hanyaTersedia,
  }) = _ItemFilter;

  /// Jumlah filter dari bottom sheet (untuk angka di tombol filter).
  int get sheetFilterCount =>
      (sort != ItemSort.terpopuler ? 1 : 0) +
      (hargaMaks != null ? 1 : 0) +
      (hanyaTersedia ? 1 : 0);

  bool get isActive =>
      query.trim().isNotEmpty || kategori != null || sheetFilterCount > 0;
}

/// Logika filter murni, dipakai repository palsu (dan nanti bisa dipindah ke API).
/// Barang nonaktif dan milik [viewerId] tidak ikut ditampilkan.
List<ItemListing> applyItemFilter(
  Iterable<ItemListing> listings,
  ItemFilter filter, {
  String? viewerId,
}) {
  final q = filter.query.trim().toLowerCase();

  bool matches(ItemListing l) {
    final item = l.item;
    if (l.status == ItemStatus.nonaktif) return false;
    if (viewerId != null && item.ownerId == viewerId) return false;
    if (filter.kategori != null && item.kategori != filter.kategori) {
      return false;
    }
    if (filter.hargaMaks != null && item.hargaPerHari > filter.hargaMaks!) {
      return false;
    }
    if (filter.hanyaTersedia && l.status != ItemStatus.tersedia) return false;
    if (q.isEmpty) return true;
    return item.judul.toLowerCase().contains(q) ||
        item.kategori.label.toLowerCase().contains(q) ||
        item.lokasiKampus.toLowerCase().contains(q);
  }

  int byPopularity(ItemListing a, ItemListing b) =>
      b.item.jumlahDisewa.compareTo(a.item.jumlahDisewa);

  final result = listings.where(matches).toList();
  result.sort(switch (filter.sort) {
    ItemSort.terpopuler => byPopularity,
    ItemSort.termurah => (a, b) {
        final c = a.item.hargaPerHari.compareTo(b.item.hargaPerHari);
        return c != 0 ? c : byPopularity(a, b);
      },
    ItemSort.ratingTertinggi => (a, b) {
        final c = b.owner.rating.compareTo(a.owner.rating);
        return c != 0 ? c : byPopularity(a, b);
      },
  });
  return result;
}

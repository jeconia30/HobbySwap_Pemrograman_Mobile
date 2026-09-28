import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../item/data/item_providers.dart';
import '../../item/domain/item.dart';
import '../../item/domain/item_filter.dart';
import '../../item/domain/kategori.dart';

/// Filter Beranda; kembali ke default saat user berganti.
final homeFilterProvider =
    NotifierProvider<HomeFilterController, ItemFilter>(HomeFilterController.new);

class HomeFilterController extends Notifier<ItemFilter> {
  @override
  ItemFilter build() {
    ref.watch(authControllerProvider.select((u) => u?.id));
    return const ItemFilter();
  }

  void setQuery(String query) => state = state.copyWith(query: query);

  void setKategori(Kategori? kategori) =>
      state = state.copyWith(kategori: kategori);

  void applySheet({
    required ItemSort sort,
    required int? hargaMaks,
    required bool hanyaTersedia,
  }) =>
      state = state.copyWith(
        sort: sort,
        hargaMaks: hargaMaks,
        hanyaTersedia: hanyaTersedia,
      );

  void reset() => state = const ItemFilter();
}

final homeItemsProvider = FutureProvider.autoDispose<List<ItemListing>>(
  (ref) {
    ref.watch(authControllerProvider.select((u) => u?.id));
    final f = ref.watch(homeFilterProvider);
    return ref.watch(itemRepositoryProvider).fetchItems(
          query: f.query,
          kategori: f.kategori,
          sort: f.sort,
          hargaMaks: f.hargaMaks,
          hanyaTersedia: f.hanyaTersedia,
        );
  },
  // Error ditampilkan dengan tombol "Coba lagi", bukan dicoba ulang diam-diam.
  retry: (_, _) => null,
);

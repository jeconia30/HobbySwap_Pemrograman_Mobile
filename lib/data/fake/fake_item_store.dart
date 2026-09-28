import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/clock.dart';
import '../../features/item/domain/item.dart';
import 'sample_data.dart';

/// Barang di memori, dipakai bersama oleh repository palsu (item & booking).
class FakeItemStore {
  FakeItemStore(List<Item> seed) : _items = [...seed];

  final List<Item> _items;
  int _lastId = 0;

  List<Item> get all => List.unmodifiable(_items);

  Item? byId(String id) => _items.where((i) => i.id == id).firstOrNull;

  /// Id baru yang tidak bentrok meski ada barang yang dihapus.
  String nextId() {
    final max = _items
        .map((i) => int.tryParse(i.id.replaceFirst('itm-', '')) ?? 0)
        .fold(_lastId, (a, b) => a > b ? a : b);
    _lastId = max + 1;
    return 'itm-${_lastId.toString().padLeft(3, '0')}';
  }

  void add(Item item) => _items.add(item);

  Item update(Item item) {
    final i = _items.indexWhere((x) => x.id == item.id);
    if (i < 0) throw StateError('Barang ${item.id} tidak ada');
    return _items[i] = item;
  }

  void remove(String id) => _items.removeWhere((i) => i.id == id);
}

final fakeItemStoreProvider = Provider<FakeItemStore>(
  (ref) => FakeItemStore(sampleItemsFor(ref.watch(clockProvider)())),
);

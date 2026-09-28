import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/session_storage.dart';
import '../../../core/utils/clock.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/item.dart';
import '../domain/item_repository.dart';
import 'fake_item_repository.dart';

final itemRepositoryProvider = Provider<ItemRepository>(
  (ref) => FakeItemRepository(
    storage: ref.watch(sessionStorageProvider),
    accounts: ref.watch(fakeAccountStoreProvider),
    items: ref.watch(fakeItemStoreProvider),
    bookings: ref.watch(fakeBookingStoreProvider),
    now: ref.watch(clockProvider),
  ),
);

final itemByIdProvider = FutureProvider.autoDispose.family<ItemListing?, String>(
  (ref, id) => ref.watch(itemRepositoryProvider).itemById(id),
  retry: (_, _) => null,
);

/// Barang milik user yang sedang masuk (Barang Saya).
final myItemsProvider = FutureProvider.autoDispose<List<ItemListing>>(
  (ref) {
    final userId = ref.watch(authControllerProvider.select((u) => u?.id));
    if (userId == null) return const [];
    return ref.watch(itemRepositoryProvider).itemsByOwner(userId);
  },
  retry: (_, _) => null,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/session_storage.dart';
import '../../../core/utils/clock.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../../../data/fake/fake_laporan_store.dart';
import '../../../data/fake/fake_notification_store.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/laporan_repository.dart';
import 'fake_laporan_repository.dart';

final laporanRepositoryProvider = Provider<LaporanRepository>(
  (ref) => FakeLaporanRepository(
    store: ref.watch(fakeLaporanStoreProvider),
    storage: ref.watch(sessionStorageProvider),
    accounts: ref.watch(fakeAccountStoreProvider),
    items: ref.watch(fakeItemStoreProvider),
    bookings: ref.watch(fakeBookingStoreProvider),
    now: ref.watch(clockProvider),
    notifications: ref.watch(fakeNotificationStoreProvider),
  ),
);

final laporankuProvider = StreamProvider.autoDispose<List<LaporanView>>((ref) {
  final userId = ref.watch(authControllerProvider.select((u) => u?.id));
  if (userId == null) return Stream.value(const []);
  return ref.watch(laporanRepositoryProvider).laporanku(userId);
}, retry: (_, _) => null);

final laporanProvider =
    StreamProvider.autoDispose.family<LaporanView?, String>((ref, id) {
  final userId = ref.watch(authControllerProvider.select((u) => u?.id));
  if (userId == null) return Stream.value(null);
  return ref.watch(laporanRepositoryProvider).watch(id, userId);
}, retry: (_, _) => null);

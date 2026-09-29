import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/fake/fake_notification_store.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/notification_item.dart';
import '../domain/notification_repository.dart';
import 'fake_notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => FakeNotificationRepository(
    store: ref.watch(fakeNotificationStoreProvider),
  ),
);

/// Notifikasi user yang sedang masuk (terbaru dulu).
final notificationsProvider =
    FutureProvider.autoDispose<List<NotificationItem>>(
  (ref) {
    final userId = ref.watch(authControllerProvider.select((u) => u?.id));
    if (userId == null) return const [];
    return ref.watch(notificationRepositoryProvider).list(userId);
  },
  retry: (_, _) => null,
);

/// Jumlah notifikasi belum dibaca (titik/angka di lonceng Beranda).
final unreadCountProvider = StreamProvider.autoDispose<int>(
  (ref) {
    final userId = ref.watch(authControllerProvider.select((u) => u?.id));
    if (userId == null) return Stream.value(0);
    return ref.watch(notificationRepositoryProvider).unreadCount(userId);
  },
  retry: (_, _) => null,
);

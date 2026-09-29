import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/fake/fake_chat_store.dart';
import '../../../data/fake/fake_notification_store.dart';

import '../../../core/utils/clock.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_handover_review_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../domain/checklist_repository.dart';
import '../domain/handover_checklist.dart';
import 'fake_checklist_repository.dart';

/// Jeda pihak lawan menyetujui otomatis (repository palsu). `null` di test.
final checklistAutoApproveDelayProvider = Provider<Duration?>(
  (ref) => const Duration(seconds: 2),
);

final checklistRepositoryProvider = Provider<ChecklistRepository>(
  (ref) => FakeChecklistRepository(
    store: ref.watch(fakeChecklistStoreProvider),
    bookings: ref.watch(fakeBookingStoreProvider),
    items: ref.watch(fakeItemStoreProvider),
    now: ref.watch(clockProvider),
    autoApproveDelay: ref.watch(checklistAutoApproveDelayProvider),
    notifications: ref.watch(fakeNotificationStoreProvider),
    chat: ref.watch(fakeChatStoreProvider),
  ),
);

/// Kunci: (sewa, tahap, barang). Barang `null` = barang utama; untuk barter
/// barang tawaran punya checklist sendiri.
final checklistProvider = StreamProvider.autoDispose
    .family<HandoverChecklist, (String, TahapChecklist, String?)>(
      (ref, key) => ref
          .watch(checklistRepositoryProvider)
          .watch(key.$1, key.$2, itemId: key.$3),
      retry: (_, _) => null,
    );

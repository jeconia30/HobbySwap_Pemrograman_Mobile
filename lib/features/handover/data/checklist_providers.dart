import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/clock.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_handover_review_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../domain/checklist_repository.dart';
import '../domain/handover_checklist.dart';
import 'fake_checklist_repository.dart';

/// Jeda pihak lawan menyetujui otomatis (repository palsu). `null` di test.
final checklistAutoApproveDelayProvider =
    Provider<Duration?>((ref) => const Duration(seconds: 2));

final checklistRepositoryProvider = Provider<ChecklistRepository>(
  (ref) => FakeChecklistRepository(
    store: ref.watch(fakeChecklistStoreProvider),
    bookings: ref.watch(fakeBookingStoreProvider),
    items: ref.watch(fakeItemStoreProvider),
    now: ref.watch(clockProvider),
    autoApproveDelay: ref.watch(checklistAutoApproveDelayProvider),
  ),
);

final checklistProvider = StreamProvider.autoDispose
    .family<HandoverChecklist, (String, TahapChecklist)>(
  (ref, key) => ref.watch(checklistRepositoryProvider).watch(key.$1, key.$2),
  retry: (_, _) => null,
);

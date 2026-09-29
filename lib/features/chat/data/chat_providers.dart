import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/session_storage.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_chat_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';
import 'fake_chat_repository.dart';

/// Sakelar balasan otomatis (Profil → Alat pengembang).
final chatAutoBalasAktifProvider =
    NotifierProvider<ChatAutoBalasAktif, bool>(ChatAutoBalasAktif.new);

class ChatAutoBalasAktif extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

/// Balasan otomatis lawan bicara (simulasi). `null` = mati (sakelar / test).
final chatAutoBalasProvider = Provider<AutoBalas?>(
  (ref) => ref.watch(chatAutoBalasAktifProvider) ? const AutoBalas() : null,
);

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final repo = FakeChatRepository(
    store: ref.watch(fakeChatStoreProvider),
    storage: ref.watch(sessionStorageProvider),
    accounts: ref.watch(fakeAccountStoreProvider),
    items: ref.watch(fakeItemStoreProvider),
    bookings: ref.watch(fakeBookingStoreProvider),
    autoBalas: ref.watch(chatAutoBalasProvider),
  );
  ref.onDispose(repo.dispose);
  return repo;
});

String? _userId(Ref ref) =>
    ref.watch(authControllerProvider.select((u) => u?.id));

/// Kotak masuk user yang sedang masuk.
final chatThreadsProvider =
    StreamProvider.autoDispose<List<ChatThreadView>>((ref) {
  final userId = _userId(ref);
  if (userId == null) return Stream.value(const []);
  return ref.watch(chatRepositoryProvider).threadsFor(userId);
}, retry: (_, _) => null);

final chatThreadProvider =
    StreamProvider.autoDispose.family<ChatThreadView?, String>((ref, id) {
  final userId = _userId(ref);
  if (userId == null) return Stream.value(null);
  return ref.watch(chatRepositoryProvider).thread(id, userId);
}, retry: (_, _) => null);

final chatMessagesProvider =
    StreamProvider.autoDispose.family<List<ChatMessage>, String>(
  (ref, id) => ref.watch(chatRepositoryProvider).messages(id),
  retry: (_, _) => null,
);

/// Lawan bicara sedang mengetik.
final chatTypingProvider =
    StreamProvider.autoDispose.family<bool, String>((ref, id) {
  final userId = _userId(ref);
  if (userId == null) return Stream.value(false);
  return ref.watch(chatRepositoryProvider).typing(id, userId);
}, retry: (_, _) => null);

/// Badge ikon pesan di Beranda.
final chatUnreadProvider = StreamProvider.autoDispose<int>((ref) {
  final userId = _userId(ref);
  if (userId == null) return Stream.value(0);
  return ref.watch(chatRepositoryProvider).totalUnread(userId);
}, retry: (_, _) => null);

import '../../auth/domain/user.dart';
import '../../booking/domain/booking.dart';
import '../../item/domain/item.dart';
import 'chat_message.dart';
import 'chat_thread.dart';

class ChatException implements Exception {
  const ChatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thread yang sudah digabung dengan data tampilannya, dilihat dari [viewerId].
class ChatThreadView {
  const ChatThreadView({
    required this.thread,
    required this.viewerId,
    required this.lawan,
    required this.item,
    this.booking,
    this.itemTawaran,
    this.terakhir,
  });

  final ChatThread thread;
  final String viewerId;
  final User lawan;
  final Item item;
  final Booking? booking;

  /// Barang tawaran bila [booking] adalah barter.
  final Item? itemTawaran;

  /// Pesan terakhir (null = thread baru, belum ada pesan).
  final ChatMessage? terakhir;

  String get id => thread.id;
  int get unread => thread.unreadUntuk(viewerId);
  bool get dibisukan => thread.dibisukanUntuk(viewerId);

  /// Viewer adalah pemilik barang di thread ini.
  bool get sayaPemilik => item.ownerId == viewerId;
}

abstract interface class ChatRepository {
  /// Thread milik [userId], pesan terbaru di atas.
  Stream<List<ChatThreadView>> threadsFor(String userId);

  /// Satu thread (header & kartu transaksi ruang obrolan).
  Stream<ChatThreadView?> thread(String threadId, String userId);

  /// Pesan di thread, urut lama → baru.
  Stream<List<ChatMessage>> messages(String threadId);

  /// `true` selama lawan bicara [userId] sedang mengetik.
  Stream<bool> typing(String threadId, String userId);

  /// Kirim pesan sebagai user yang sedang masuk.
  Future<ChatMessage> send(
    String threadId,
    TipePesan tipe,
    String isi, {
    Map<String, dynamic> payload = const {},
  });

  Future<void> markRead(String threadId, String userId);

  /// Thread user yang sedang masuk dengan [otherUserId] tentang [itemId];
  /// dibuat kalau belum ada, tidak pernah ganda.
  Future<ChatThread> openOrCreate({
    required String otherUserId,
    required String itemId,
    String? bookingId,
  });

  /// Penerima menjawab usulan COD.
  Future<void> respondCod(String messageId, {required bool setuju});

  Future<void> setMuted(String threadId, String userId, {required bool muted});

  /// Total pesan belum dibaca [userId] di semua thread.
  Stream<int> totalUnread(String userId);
}

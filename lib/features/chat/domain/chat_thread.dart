import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_thread.freezed.dart';
part 'chat_thread.g.dart';

/// Satu percakapan antara dua user tentang satu barang.
@freezed
abstract class ChatThread with _$ChatThread {
  const ChatThread._();

  const factory ChatThread({
    required String id,

    /// Tepat dua user (penyewa & pemilik).
    required List<String> participantIds,
    required String itemId,

    /// Sewa terbaru pasangan ini untuk barang tsb. (null = belum ada sewa).
    String? bookingId,
    required DateTime lastMessageAt,

    /// Jumlah pesan belum dibaca, per user.
    @Default(<String, int>{}) Map<String, int> unreadCount,

    /// Notifikasi dibisukan, per user.
    @Default(<String, bool>{}) Map<String, bool> muted,
  }) = _ChatThread;

  factory ChatThread.fromJson(Map<String, dynamic> json) =>
      _$ChatThreadFromJson(json);

  /// Lawan bicara [userId] di thread ini.
  String lawanDari(String userId) =>
      participantIds.firstWhere((p) => p != userId, orElse: () => userId);

  int unreadUntuk(String userId) => unreadCount[userId] ?? 0;

  bool dibisukanUntuk(String userId) => muted[userId] ?? false;
}

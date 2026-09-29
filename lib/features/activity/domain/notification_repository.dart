import 'notification_item.dart';

/// Kontrak notifikasi (Aktivitas).
abstract interface class NotificationRepository {
  /// Terbaru dulu.
  Future<List<NotificationItem>> list(String userId);

  /// Jumlah belum dibaca; memancarkan ulang setiap ada perubahan.
  Stream<int> unreadCount(String userId);

  Future<void> markRead(String id);

  Future<void> markAllRead(String userId);

  Future<void> delete(String id);

  /// Mengembalikan notifikasi yang baru dihapus ("Urungkan").
  Future<void> restore(NotificationItem item);
}

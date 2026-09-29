import '../../../data/fake/fake_notification_store.dart';
import '../domain/notification_item.dart';
import '../domain/notification_repository.dart';

class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({
    required this._store,
    this.delay = const Duration(milliseconds: 400),
  });

  final FakeNotificationStore _store;
  final Duration delay;

  int _unread(String userId) =>
      _store.all.where((n) => n.userId == userId && !n.sudahDibaca).length;

  @override
  Future<List<NotificationItem>> list(String userId) async {
    await Future<void>.delayed(delay);
    return _store.all.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
  }

  @override
  Stream<int> unreadCount(String userId) async* {
    yield _unread(userId);
    yield* _store.changes.map((_) => _unread(userId));
  }

  @override
  Future<void> markRead(String id) async {
    final n = _store.all.where((n) => n.id == id).firstOrNull;
    if (n != null && !n.sudahDibaca) _store.put(n.copyWith(sudahDibaca: true));
  }

  @override
  Future<void> markAllRead(String userId) async {
    for (final n in _store.all.where((n) => n.userId == userId)) {
      if (!n.sudahDibaca) _store.put(n.copyWith(sudahDibaca: true));
    }
  }

  @override
  Future<void> delete(String id) async => _store.remove(id);

  @override
  Future<void> restore(NotificationItem item) async => _store.put(item);
}

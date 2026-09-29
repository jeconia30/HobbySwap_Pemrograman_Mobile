import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/clock.dart';
import '../../features/booking/domain/booking.dart';
import '../../features/chat/domain/chat_message.dart';
import '../../features/chat/domain/chat_thread.dart';
import 'fake_persistence.dart';
import 'sample_data.dart';

/// Percakapan di memori, dipakai bersama repository chat, sewa, dan checklist
/// (pesan sistem dari kejadian sewa).
class FakeChatStore {
  FakeChatStore({
    List<ChatThread> threads = const [],
    List<ChatMessage> messages = const [],
    DateTime Function()? now,
    this._db = const FakePersistence.none(),
  })  : _threads = [...threads],
        _messages = [...messages],
        _now = now ?? DateTime.now;

  static const threadsKey = 'chatThreads';
  static const messagesKey = 'chatMessages';

  final FakePersistence _db;

  final List<ChatThread> _threads;
  final List<ChatMessage> _messages;
  final DateTime Function() _now;
  final _typing = <String, Set<String>>{};
  final _changes = StreamController<void>.broadcast();
  var _seq = 0;

  Stream<void> get changes => _changes.stream;

  DateTime now() => _now();

  List<ChatThread> get threads => List.unmodifiable(_threads);

  ChatThread? thread(String id) =>
      _threads.where((t) => t.id == id).firstOrNull;

  List<ChatMessage> messagesOf(String threadId) =>
      _messages.where((m) => m.threadId == threadId).toList()
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));

  ChatMessage? message(String id) =>
      _messages.where((m) => m.id == id).firstOrNull;

  ChatMessage? lastOf(String threadId) {
    final list = messagesOf(threadId);
    return list.isEmpty ? null : list.last;
  }

  bool isTyping(String threadId, String userId) =>
      _typing[threadId]?.contains(userId) ?? false;

  void _changed() {
    _db
      ..save(threadsKey, _threads, (t) => t.toJson())
      ..save(messagesKey, _messages, (m) => m.toJson());
    _changes.add(null);
  }

  String _id(String prefix) =>
      '$prefix-baru-${++_seq}-${_now().microsecondsSinceEpoch}';

  /// Thread pasangan [a]–[b] untuk [itemId] (urutan user tidak penting).
  ChatThread? find(String a, String b, String itemId) => _threads
      .where((t) =>
          t.itemId == itemId &&
          t.participantIds.contains(a) &&
          t.participantIds.contains(b))
      .firstOrNull;

  ChatThread putThread(ChatThread t) {
    final i = _threads.indexWhere((x) => x.id == t.id);
    if (i < 0) {
      _threads.add(t);
    } else {
      _threads[i] = t;
    }
    _changed();
    return t;
  }

  ChatThread findOrCreate(String a, String b, String itemId,
      {String? bookingId}) {
    final existing = find(a, b, itemId);
    if (existing != null) {
      if (bookingId != null && existing.bookingId != bookingId) {
        return putThread(existing.copyWith(bookingId: bookingId));
      }
      return existing;
    }
    return putThread(ChatThread(
      id: _id('thr'),
      participantIds: [a, b],
      itemId: itemId,
      bookingId: bookingId,
      lastMessageAt: _now(),
    ));
  }

  /// Menambah pesan dan menaikkan unread semua peserta selain [kecuali]
  /// (pengirim; untuk pesan sistem: user yang memicu kejadian).
  ChatMessage add({
    required String threadId,
    required String? senderId,
    required TipePesan tipe,
    required String isi,
    Map<String, dynamic> payload = const {},
    String? kecuali,
  }) {
    final t = thread(threadId);
    if (t == null) throw StateError('Thread $threadId tidak ada');
    final msg = ChatMessage(
      id: _id('msg'),
      threadId: threadId,
      senderId: senderId,
      tipe: tipe,
      isi: isi,
      payload: payload,
      sentAt: _now(),
    );
    _messages.add(msg);
    final skip = kecuali ?? senderId;
    putThread(t.copyWith(
      lastMessageAt: msg.sentAt,
      unreadCount: {
        for (final p in t.participantIds)
          p: p == skip ? t.unreadUntuk(p) : t.unreadUntuk(p) + 1,
      },
    ));
    return msg;
  }

  ChatMessage putMessage(ChatMessage m) {
    final i = _messages.indexWhere((x) => x.id == m.id);
    if (i < 0) throw StateError('Pesan ${m.id} tidak ada');
    _messages[i] = m;
    _changed();
    return m;
  }

  /// [userId] membaca thread: unread-nya nol dan pesan lawan diberi readAt.
  void markRead(String threadId, String userId) {
    final t = thread(threadId);
    if (t == null) return;
    final at = _now();
    for (var i = 0; i < _messages.length; i++) {
      final m = _messages[i];
      if (m.threadId == threadId &&
          m.senderId != null &&
          m.senderId != userId &&
          m.readAt == null) {
        _messages[i] = m.copyWith(readAt: at);
      }
    }
    putThread(t.copyWith(unreadCount: {...t.unreadCount, userId: 0}));
  }

  void setTyping(String threadId, String userId, bool typing) {
    final set = _typing.putIfAbsent(threadId, () => {});
    // Status mengetik tidak disimpan.
    if (typing ? set.add(userId) : set.remove(userId)) _changes.add(null);
  }

  /// Pesan sistem di thread penyewa–pemilik untuk sewa [b].
  void catatKejadian(Booking b, String ownerId, KejadianSewa k,
      {String? pemicu}) {
    final t = findOrCreate(b.penyewaId, ownerId, b.itemId, bookingId: b.id);
    add(
      threadId: t.id,
      senderId: null,
      tipe: TipePesan.sistem,
      isi: k.teks,
      payload: {'kejadian': k.name, 'bookingId': b.id},
      kecuali: pemicu,
    );
  }
}

final fakeChatStoreProvider = Provider<FakeChatStore>((ref) {
  final now = ref.watch(clockProvider);
  final db = ref.watch(fakePersistenceProvider);
  final threads = db.load(FakeChatStore.threadsKey, ChatThread.fromJson);
  final messages = db.load(FakeChatStore.messagesKey, ChatMessage.fromJson);
  if (threads != null && messages != null) {
    return FakeChatStore(
        threads: threads, messages: messages, now: now, db: db);
  }
  final (t, m) = sampleChatsFor(now());
  return FakeChatStore(threads: t, messages: m, now: now, db: db);
});

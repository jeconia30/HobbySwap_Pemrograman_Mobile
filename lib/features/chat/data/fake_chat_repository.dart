import 'dart:async';
import 'dart:math';

import '../../../core/storage/session_storage.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_chat_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../../booking/domain/booking.dart';
import '../../item/domain/item.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';
import '../domain/chat_thread.dart';

/// Jeda balasan otomatis lawan bicara (simulasi), acak di antara [min]–[max].
class AutoBalas {
  const AutoBalas({
    this.min = const Duration(milliseconds: 1500),
    this.max = const Duration(seconds: 3),
  });

  final Duration min;
  final Duration max;
}

/// Balasan lawan yang cocok dengan pesan terakhir user (simulasi).
String balasanOtomatis(ChatMessage pesan, Item item, int urutan) {
  if (pesan.tipe == TipePesan.lokasiCod) {
    return 'Oke, aku setuju. Sampai ketemu di ${pesan.cod!.lokasi}!';
  }
  if (pesan.tipe == TipePesan.foto) return 'Sip, fotonya udah aku lihat.';
  final t = pesan.isi.toLowerCase();
  bool ada(List<String> kata) => kata.any(t.contains);
  if (ada(['tersedia', 'masih ada', 'kosong'])) {
    return 'Masih kok, tanggalnya aman.';
  }
  if (ada(['jam berapa', 'jam', 'kapan'])) return 'Bisa, jam 4 sore gimana?';
  if (ada(['cod', 'di mana', 'dimana', 'lokasi'])) {
    return 'Di depan ${item.lokasiKampus} aja ya, dekat parkiran motor.';
  }
  if (ada(['ktm'])) return 'Siap, KTM-nya aku bawa.';
  if (ada(['makasih', 'terima kasih'])) return 'Sama-sama!';
  const umum = [
    'Oke, aku tunggu ya!',
    'Siap, nanti aku kabari lagi.',
    'Oke, noted.',
  ];
  return umum[urutan % umum.length];
}

class FakeChatRepository implements ChatRepository {
  FakeChatRepository({
    required this._store,
    required this._storage,
    required this._accounts,
    required this._items,
    required this._bookings,
    this.autoBalas = const AutoBalas(),
    Random? random,
    this.delay = const Duration(milliseconds: 300),
  }) : _random = random ?? Random();

  final FakeChatStore _store;
  final SessionStorage _storage;
  final FakeAccountStore _accounts;
  final FakeItemStore _items;
  final FakeBookingStore _bookings;
  final Random _random;
  final Duration delay;

  /// `null` = lawan tidak membalas otomatis (test).
  final AutoBalas? autoBalas;

  final _timers = <String, List<Timer>>{};
  var _balasanKe = 0;

  String get _me {
    final id = _storage.sessionUserId;
    if (id == null) throw const ChatException('Sesimu habis. Masuk lagi ya.');
    return id;
  }

  ChatThreadView? _view(ChatThread t, String userId) {
    final lawan = _accounts.byId(t.lawanDari(userId))?.user;
    final item = _items.byId(t.itemId);
    if (lawan == null || item == null) return null;
    final booking = t.bookingId == null ? null : _bookings.byId(t.bookingId!);
    return ChatThreadView(
      thread: t,
      viewerId: userId,
      lawan: lawan,
      item: item,
      booking: booking,
      itemTawaran: booking?.itemTawaranId == null
          ? null
          : _items.byId(booking!.itemTawaranId!),
      terakhir: _store.lastOf(t.id),
    );
  }

  List<ChatThreadView> _views(String userId) => [
        for (final t in _store.threads)
          if (t.participantIds.contains(userId)) _view(t, userId),
      ].nonNulls.toList()
        ..sort((a, b) => b.thread.lastMessageAt.compareTo(a.thread.lastMessageAt));

  /// Nilai sekarang, lalu nilai baru setiap kali store berubah.
  Stream<T> _live<T>(T Function() read, {bool jeda = false}) async* {
    if (jeda) await Future<void>.delayed(delay);
    yield read();
    yield* _store.changes.map((_) => read());
  }

  @override
  Stream<List<ChatThreadView>> threadsFor(String userId) =>
      _live(() => _views(userId), jeda: true);

  @override
  Stream<ChatThreadView?> thread(String threadId, String userId) => _live(() {
        final t = _store.thread(threadId);
        return t == null ? null : _view(t, userId);
      });

  @override
  Stream<List<ChatMessage>> messages(String threadId) =>
      _live(() => _store.messagesOf(threadId), jeda: true);

  @override
  Stream<bool> typing(String threadId, String userId) => _live(() {
        final t = _store.thread(threadId);
        return t != null && _store.isTyping(threadId, t.lawanDari(userId));
      }).distinct();

  @override
  Stream<int> totalUnread(String userId) => _live(() => _store.threads
      .where((t) =>
          t.participantIds.contains(userId) && !t.dibisukanUntuk(userId))
      .fold(0, (sum, t) => sum + t.unreadUntuk(userId))).distinct();

  ChatThread _threadSaya(String threadId, String me) {
    final t = _store.thread(threadId);
    if (t == null || !t.participantIds.contains(me)) {
      throw const ChatException('Percakapan ini tidak ditemukan.');
    }
    return t;
  }

  @override
  Future<ChatMessage> send(
    String threadId,
    TipePesan tipe,
    String isi, {
    Map<String, dynamic> payload = const {},
  }) async {
    final me = _me;
    final t = _threadSaya(threadId, me);
    final teks = isi.trim();
    if (tipe == TipePesan.sistem) {
      throw const ChatException('Pesan sistem tidak bisa dikirim manual.');
    }
    if (tipe == TipePesan.teks && teks.isEmpty) {
      throw const ChatException('Tulis pesannya dulu, ya.');
    }
    final pesan = _store.add(
      threadId: threadId,
      senderId: me,
      tipe: tipe,
      isi: teks,
      payload: payload,
    );
    _jadwalkanBalasan(t, pesan);
    return pesan;
  }

  void _jadwalkanBalasan(ChatThread t, ChatMessage pesan) {
    final cfg = autoBalas;
    if (cfg == null) return;
    final lawan = t.lawanDari(pesan.senderId!);
    for (final timer in _timers.remove(t.id) ?? const <Timer>[]) {
      timer.cancel();
    }
    final rentang = cfg.max - cfg.min;
    final total = cfg.min + rentang * _random.nextDouble();
    _timers[t.id] = [
      Timer(total * 0.3, () => _store.setTyping(t.id, lawan, true)),
      Timer(total, () {
        _timers.remove(t.id);
        _store.setTyping(t.id, lawan, false);
        final item = _items.byId(t.itemId);
        if (item == null) return;
        _store.markRead(t.id, lawan);
        final cod = pesan.cod;
        if (cod != null && cod.status == StatusCod.menunggu) {
          _jawabCod(pesan.id, lawan, setuju: true);
        }
        _store.add(
          threadId: t.id,
          senderId: lawan,
          tipe: TipePesan.teks,
          isi: balasanOtomatis(pesan, item, _balasanKe++),
        );
      }),
    ];
  }

  @override
  Future<void> markRead(String threadId, String userId) async =>
      _store.markRead(threadId, userId);

  @override
  Future<ChatThread> openOrCreate({
    required String otherUserId,
    required String itemId,
    String? bookingId,
  }) async {
    final me = _me;
    if (me == otherUserId) {
      throw const ChatException('Ini barangmu sendiri.');
    }
    final item = _items.byId(itemId);
    if (item == null || _accounts.byId(otherUserId) == null) {
      throw const ChatException('Percakapan ini belum bisa dibuka.');
    }
    return _store.findOrCreate(me, otherUserId, itemId,
        bookingId: bookingId ?? _sewaTerbaru(me, otherUserId, item)?.id);
  }

  /// Sewa terbaru antara dua user untuk [item] (untuk kartu transaksi).
  Booking? _sewaTerbaru(String a, String b, Item item) {
    final penyewa = item.ownerId == a ? b : a;
    if (item.ownerId != a && item.ownerId != b) return null;
    final list = _bookings.all
        .where((x) => x.itemId == item.id && x.penyewaId == penyewa)
        .toList()
      ..sort((x, y) => y.dibuatPada.compareTo(x.dibuatPada));
    return list.firstOrNull;
  }

  @override
  Future<void> respondCod(String messageId, {required bool setuju}) async =>
      _jawabCod(messageId, _me, setuju: setuju);

  void _jawabCod(String messageId, String userId, {required bool setuju}) {
    final m = _store.message(messageId);
    final cod = m?.cod;
    if (m == null || cod == null) {
      throw const ChatException('Usulan ini tidak ditemukan.');
    }
    final t = _threadSaya(m.threadId, userId);
    if (m.senderId == userId || !t.participantIds.contains(userId)) {
      throw const ChatException('Usulanmu sendiri tidak bisa kamu jawab.');
    }
    if (cod.status != StatusCod.menunggu) {
      throw const ChatException('Usulan ini sudah dijawab.');
    }
    _store.putMessage(m.copyWith(
      payload: UsulanCod(
        lokasi: cod.lokasi,
        waktu: cod.waktu,
        status: setuju ? StatusCod.disetujui : StatusCod.usulLain,
      ).toPayload(),
    ));
  }

  @override
  Future<void> setMuted(String threadId, String userId,
      {required bool muted}) async {
    final t = _threadSaya(threadId, userId);
    _store.putThread(t.copyWith(muted: {...t.muted, userId: muted}));
  }

  /// Hentikan balasan yang masih terjadwal (dipanggil saat provider dibuang).
  void dispose() {
    for (final list in _timers.values) {
      for (final timer in list) {
        timer.cancel();
      }
    }
    _timers.clear();
  }
}

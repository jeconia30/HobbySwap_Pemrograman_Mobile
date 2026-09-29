import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/storage/session_storage.dart';
import 'package:hobby_swab/data/fake/fake_account_store.dart';
import 'package:hobby_swab/data/fake/fake_booking_store.dart';
import 'package:hobby_swab/data/fake/fake_chat_store.dart';
import 'package:hobby_swab/data/fake/fake_item_store.dart';
import 'package:hobby_swab/data/fake/sample_data.dart';
import 'package:hobby_swab/features/booking/data/fake_booking_repository.dart';
import 'package:hobby_swab/features/chat/data/fake_chat_repository.dart';
import 'package:hobby_swab/features/chat/domain/chat_message.dart';
import 'package:hobby_swab/features/chat/domain/chat_repository.dart';

import '../../helpers/pump_app.dart';

const aulia = 'usr-002', rizky = 'usr-003', sarah = 'usr-004';
const dimas = 'usr-005';

void main() {
  late SessionStorage storage;
  late FakeAccountStore accounts;
  late FakeItemStore items;
  late FakeBookingStore bookings;
  late FakeChatStore chat;
  late FakeChatRepository repo;

  setUp(() async {
    storage = await mockStorage({SessionStorage.sessionUserIdKey: gregorian});
    accounts = FakeAccountStore();
    items = FakeItemStore(sampleItemsFor(testToday));
    bookings = FakeBookingStore(sampleBookingsFor(testToday));
    final (threads, messages) = sampleChatsFor(testToday);
    chat = FakeChatStore(
        threads: threads, messages: messages, now: () => testToday);
    repo = FakeChatRepository(
      store: chat,
      storage: storage,
      accounts: accounts,
      items: items,
      bookings: bookings,
      autoBalas: null,
      delay: Duration.zero,
    );
  });

  group('openOrCreate', () {
    test('memakai thread yang sudah ada untuk pasangan + barang sama', () async {
      final t = await repo.openOrCreate(otherUserId: rizky, itemId: 'itm-001');
      expect(t.id, 'thr-001');
      expect(chat.threads, hasLength(4));
    });

    test('tidak membuat thread ganda, dari sisi mana pun', () async {
      final a = await repo.openOrCreate(otherUserId: sarah, itemId: 'itm-002');
      final b = await repo.openOrCreate(otherUserId: sarah, itemId: 'itm-002');
      expect(b.id, a.id);
      await storage.saveSession(sarah);
      final c =
          await repo.openOrCreate(otherUserId: gregorian, itemId: 'itm-002');
      expect(c.id, a.id);
      expect(chat.threads, hasLength(5));
    });

    test('barang berbeda = thread berbeda; barang sendiri ditolak', () async {
      final a = await repo.openOrCreate(otherUserId: rizky, itemId: 'itm-005');
      expect(a.id, isNot('thr-001'));
      await expectLater(
        repo.openOrCreate(otherUserId: gregorian, itemId: 'itm-013'),
        throwsA(isA<ChatException>()),
      );
    });
  });

  test('markRead mengosongkan unread dan menandai pesan lawan dibaca',
      () async {
    expect(chat.thread('thr-002')!.unreadUntuk(gregorian), 2);
    await repo.markRead('thr-002', gregorian);
    expect(chat.thread('thr-002')!.unreadUntuk(gregorian), 0);
    expect(
      chat.messagesOf('thr-002').where((m) => m.senderId == aulia),
      everyElement(predicate<ChatMessage>((m) => m.readAt != null)),
    );
  });

  test('pesan sistem masuk saat pengajuan disetujui (dan yang bentrok ditolak)',
      () async {
    final bookingRepo = FakeBookingRepository(
      storage: storage,
      accounts: accounts,
      items: items,
      bookings: bookings,
      now: () => testToday,
      chat: chat,
      delay: Duration.zero,
    );
    // bkg-005: Aulia → Carrier Eiger milik Gregorian; bkg-007 Sarah bentrok.
    await bookingRepo.approve('bkg-005');

    final auliaThread = chat.find(gregorian, aulia, 'itm-013')!;
    final terakhir = chat.lastOf(auliaThread.id)!;
    expect(terakhir.tipe, TipePesan.sistem);
    expect(terakhir.kejadian, KejadianSewa.disetujui);
    expect(terakhir.isi, 'Pengajuan sewa disetujui');
    expect(auliaThread.unreadUntuk(aulia), greaterThan(0));
    expect(auliaThread.unreadUntuk(gregorian), 2,
        reason: 'pemicu kejadian tidak dapat unread baru');

    final sarahThread = chat.find(gregorian, sarah, 'itm-013')!;
    expect(chat.lastOf(sarahThread.id)!.kejadian, KejadianSewa.ditolak);
    expect(sarahThread.bookingId, 'bkg-007');
  });

  group('respondCod', () {
    Future<ChatMessage> usulDariGregorian() => repo.send(
          'thr-003',
          TipePesan.lokasiCod,
          'Usulan titik COD',
          payload: UsulanCod(lokasi: 'FEB', waktu: hPlus(1)).toPayload(),
        );

    test('penerima menyetujui: status jadi disetujui', () async {
      final m = await usulDariGregorian();
      expect(m.cod!.status, StatusCod.menunggu);
      await storage.saveSession(dimas);
      await repo.respondCod(m.id, setuju: true);
      expect(chat.message(m.id)!.cod!.status, StatusCod.disetujui);
      await expectLater(repo.respondCod(m.id, setuju: false),
          throwsA(isA<ChatException>()));
    });

    test('minta usulan lain; pengusul tidak bisa menjawab sendiri', () async {
      final m = await usulDariGregorian();
      await expectLater(repo.respondCod(m.id, setuju: true),
          throwsA(isA<ChatException>()));
      await storage.saveSession(dimas);
      await repo.respondCod(m.id, setuju: false);
      expect(chat.message(m.id)!.cod!.status, StatusCod.usulLain);
    });
  });

  test('totalUnread menjumlah semua thread, tanpa yang dibisukan', () async {
    expect(await repo.totalUnread(gregorian).first, 2);
    chat.add(
        threadId: 'thr-001',
        senderId: rizky,
        tipe: TipePesan.teks,
        isi: 'Jangan lupa tripodnya ya');
    expect(await repo.totalUnread(gregorian).first, 3);
    expect(await repo.totalUnread(rizky).first, 0);

    await repo.setMuted('thr-001', gregorian, muted: true);
    expect(await repo.totalUnread(gregorian).first, 2);
    await repo.markRead('thr-002', gregorian);
    expect(await repo.totalUnread(gregorian).first, 0);
  });

  test('kirim pesan menaikkan unread lawan, bukan pengirim', () async {
    await repo.send('thr-003', TipePesan.teks, 'Oke Kak, jam 4 ya');
    final t = chat.thread('thr-003')!;
    expect(t.unreadUntuk(dimas), 1);
    expect(t.unreadUntuk(gregorian), 0);
    await expectLater(repo.send('thr-003', TipePesan.teks, '   '),
        throwsA(isA<ChatException>()));
  });

  test('lawan mengetik lalu membalas otomatis, pesanku jadi dibaca', () async {
    final otomatis = FakeChatRepository(
      store: chat,
      storage: storage,
      accounts: accounts,
      items: items,
      bookings: bookings,
      autoBalas: const AutoBalas(
        min: Duration(milliseconds: 60),
        max: Duration(milliseconds: 60),
      ),
      delay: Duration.zero,
    );
    addTearDown(otomatis.dispose);
    final kirim =
        await otomatis.send('thr-003', TipePesan.teks, 'Bisa ambil jam berapa?');
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(chat.isTyping('thr-003', dimas), isTrue);
    expect(await otomatis.typing('thr-003', gregorian).first, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(chat.isTyping('thr-003', dimas), isFalse);
    final balasan = chat.lastOf('thr-003')!;
    expect(balasan.senderId, dimas);
    expect(balasan.isi, 'Bisa, jam 4 sore gimana?');
    expect(chat.message(kirim.id)!.readAt, isNotNull);
    expect(chat.thread('thr-003')!.unreadUntuk(gregorian), 1);
  });

  test('balasan otomatis sesuai konteks pesan', () {
    final item = items.byId('itm-003')!;
    ChatMessage teks(String isi) => ChatMessage(
        id: 'x',
        threadId: 'thr-003',
        senderId: gregorian,
        tipe: TipePesan.teks,
        isi: isi,
        sentAt: testToday);
    expect(balasanOtomatis(teks('Bisa ambil jam berapa?'), item, 0),
        'Bisa, jam 4 sore gimana?');
    expect(balasanOtomatis(teks('Masih tersedia?'), item, 0),
        'Masih kok, tanggalnya aman.');
    expect(balasanOtomatis(teks('Titik COD-nya di mana?'), item, 0),
        contains(item.lokasiKampus));
  });
}

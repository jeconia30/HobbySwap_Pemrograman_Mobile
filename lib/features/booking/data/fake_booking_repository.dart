import '../../../core/storage/session_storage.dart';
import '../../../core/utils/dates.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_chat_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../../../data/fake/fake_notification_store.dart';
import '../../activity/domain/notification_item.dart';
import '../../auth/domain/user.dart';
import '../../chat/domain/chat_message.dart';
import '../../item/domain/item.dart';
import '../domain/booking.dart';
import '../domain/booking_repository.dart';
import '../domain/booking_rules.dart';
import '../../../core/constants/app_strings.dart';

class FakeBookingRepository implements BookingRepository {
  FakeBookingRepository({
    required this._storage,
    required this._accounts,
    required this._items,
    required this._bookings,
    required this._now,
    this._notifications,
    this._chat,
    this.delay = const Duration(milliseconds: 900),
  });

  static const barangSendiriMessage = 'Ini barangmu sendiri.';
  static const pengajuanGandaMessage =
      'Kamu sudah mengajukan tanggal ini. Tunggu jawaban pemilik dulu.';
  static const autoTolakMessage = 'Tanggal sudah diambil penyewa lain';

  final SessionStorage _storage;
  final FakeAccountStore _accounts;
  final FakeItemStore _items;
  final FakeBookingStore _bookings;
  final DateTime Function() _now;
  final FakeNotificationStore? _notifications;

  /// Pesan sistem ke thread penyewa–pemilik (null = tidak dicatat).
  final FakeChatStore? _chat;
  final Duration delay;

  List<RentangTanggal> _blocked(Item item) => [
        ...item.rentangTidakTersedia,
        for (final b in _bookings.all)
          if (b.itemIds.contains(item.id) && b.status.memblokirTanggal)
            RentangTanggal(mulai: b.tanggalMulai, selesai: b.tanggalKembali),
      ];

  @override
  Future<Booking> create({
    required String itemId,
    required DateTime mulai,
    required DateTime kembali,
    String? pesan,
  }) async {
    await Future<void>.delayed(delay);
    final start = dateOnly(mulai);
    final end = dateOnly(kembali);

    final renter = _accounts.byId(_storage.sessionUserId ?? '')?.user;
    if (renter == null) throw const BookingException(AppTeks.sesiHabis);
    if (renter.statusVerifikasi != StatusVerifikasi.terverifikasi) {
      throw const BookingException(AppTeks.verifikasiDulu);
    }

    final item = _items.byId(itemId);
    if (item == null) {
      throw const BookingException('Barang ini sudah tidak tersedia.');
    }
    if (item.ownerId == renter.id) {
      throw const BookingException(barangSendiriMessage);
    }
    if (!item.aktif) {
      throw const BookingException('Barang ini sedang tidak disewakan.');
    }

    final masalah = periksaRentang(
      mulai: start,
      kembali: end,
      hariIni: dateOnly(_now()),
    );
    if (masalah != null) throw BookingException(masalah.pesan);

    if (rentangMelewatiBlokir(start, end, _blocked(item))) {
      throw const BookingConflictException();
    }

    final ganda = _bookings.all.any((b) =>
        b.penyewaId == renter.id &&
        b.itemId == itemId &&
        b.status == StatusBooking.menunggu &&
        rentangBertumpuk(start, end, b.tanggalMulai, b.tanggalKembali));
    if (ganda) throw const BookingException(pengajuanGandaMessage);

    final trimmed = pesan?.trim();
    final booking = Booking(
      id: 'bkg-${(_bookings.length + 1).toString().padLeft(3, '0')}',
      itemId: itemId,
      penyewaId: renter.id,
      tanggalMulai: start,
      tanggalKembali: end,
      totalHarga: hitungTotal(item.hargaPerHari, start, end),
      pesan: trimmed == null || trimmed.isEmpty ? null : trimmed,
      dibuatPada: _now(),
    );
    _bookings.add(booking);
    _chat?.catatKejadian(booking, item.ownerId, KejadianSewa.dikirim,
        pemicu: renter.id);
    _notifications?.kirim(
      userId: item.ownerId,
      tipe: TipeNotifikasi.pengajuanBaru,
      judul: 'Pengajuan baru untuk ${item.judul}',
      isi: '${renter.nama} ingin menyewa ${hitungHari(start, end)} hari. '
          'Cek dan jawab, ya.',
      tautan: '/pengajuan',
    );
    return booking;
  }

  BookingDetail? _detail(Booking b) {
    final item = _items.byId(b.itemId);
    if (item == null) return null;
    final penyewa = _accounts.byId(b.penyewaId)?.user;
    final pemilik = _accounts.byId(item.ownerId)?.user;
    if (penyewa == null || pemilik == null) return null;
    final tawaran = b.itemTawaranId == null ? null : _items.byId(b.itemTawaranId!);
    if (b.barter && tawaran == null) return null;
    return BookingDetail(
      booking: b,
      item: item,
      penyewa: penyewa,
      pemilik: pemilik,
      itemTawaran: tawaran,
    );
  }

  List<BookingDetail> _details(bool Function(Booking b) test) =>
      _bookings.all.where(test).map(_detail).nonNulls.toList()
        ..sort((a, b) => b.booking.dibuatPada.compareTo(a.booking.dibuatPada));

  @override
  Future<List<BookingDetail>> bookingsForRenter(String userId) async {
    await Future<void>.delayed(delay);
    // Barter yang sudah disepakati: pemilik juga meminjam barang pengaju.
    return _details((b) =>
        b.penyewaId == userId ||
        (b.barter &&
            _items.byId(b.itemId)?.ownerId == userId &&
            (b.status == StatusBooking.disetujui ||
                b.status == StatusBooking.berlangsung ||
                b.status == StatusBooking.selesai)));
  }

  @override
  Future<List<BookingDetail>> bookingsForOwner(String userId) async {
    await Future<void>.delayed(delay);
    final owned =
        _items.all.where((i) => i.ownerId == userId).map((i) => i.id).toSet();
    return _details((b) => owned.contains(b.itemId));
  }

  @override
  Future<List<RentangTanggal>> blockedDates(String itemId) async {
    await Future<void>.delayed(delay);
    final item = _items.byId(itemId);
    return item == null ? const [] : _blocked(item);
  }

  /// Pengajuan menunggu atas barang milik user yang sedang masuk.
  (Booking, Item) _pendingOwned(String bookingId) {
    final booking = _bookings.byId(bookingId);
    final item = booking == null ? null : _items.byId(booking.itemId);
    if (booking == null || item == null) {
      throw const BookingException('Pengajuan ini sudah tidak ada.');
    }
    if (item.ownerId != _storage.sessionUserId) {
      throw const BookingException('Ini bukan pengajuan untuk barangmu.');
    }
    if (booking.status != StatusBooking.menunggu) {
      throw const BookingException('Pengajuan ini sudah diproses.');
    }
    if (booking.perluTanggapanPengaju) {
      throw const BookingException(
          'Menunggu tanggapan pengaju atas barang yang kamu minta.');
    }
    return (booking, item);
  }

  @override
  Future<int> approve(String bookingId) async {
    await Future<void>.delayed(delay);
    final (booking, item) = _pendingOwned(bookingId);
    return _setujui(booking, item);
  }

  /// Menyetujui [booking] (sewa, barter, atau counter barter yang disetujui
  /// pengaju): mengunci tanggal semua barangnya dan menolak otomatis
  /// pengajuan menunggu lain yang bertumpuk pada barang-barang itu.
  int _setujui(Booking booking, Item item, {bool olehPengaju = false}) {
    final tawaran = booking.itemTawaranId == null
        ? null
        : _items.byId(booking.itemTawaranId!);
    for (final i in [item, ?tawaran]) {
      if (rentangMelewatiBlokir(
          booking.tanggalMulai, booking.tanggalKembali, _blocked(i))) {
        throw BookingConflictException(
            'Tanggalnya bentrok dengan jadwal ${i.judul}.');
      }
    }
    _bookings.update(booking.copyWith(
      status: StatusBooking.disetujui,
      perluTanggapanPengaju: false,
    ));
    final pemicu = olehPengaju ? booking.penyewaId : item.ownerId;
    _chat?.catatKejadian(
        booking,
        item.ownerId,
        booking.barter ? KejadianSewa.barterDisetujui : KejadianSewa.disetujui,
        pemicu: pemicu);
    _notifications?.kirim(
      userId: olehPengaju ? item.ownerId : booking.penyewaId,
      tipe: TipeNotifikasi.pengajuanDisetujui,
      judul: booking.barter
          ? 'Barter disepakati'
          : 'Pengajuanmu disetujui',
      isi: booking.barter
          ? '${item.judul} ditukar pinjam dengan ${tawaran?.judul ?? ''}. '
              'Isi checklist kedua '
              'barang saat bertemu, ya.'
          : '${item.judul}. Isi checklist saat ambil barang, ya.',
      tautan: '/sewaan',
    );

    final bentrok = _bookings.all.where((b) =>
        b.id != booking.id &&
        b.itemIds.any(booking.itemIds.contains) &&
        b.status == StatusBooking.menunggu &&
        rentangBertumpuk(b.tanggalMulai, b.tanggalKembali,
            booking.tanggalMulai, booking.tanggalKembali)).toList();
    for (final b in bentrok) {
      _bookings.update(b.copyWith(
        status: StatusBooking.ditolak,
        alasanTolak: autoTolakMessage,
      ));
      final pemilikB = _items.byId(b.itemId)?.ownerId ?? item.ownerId;
      _chat?.catatKejadian(b, pemilikB, KejadianSewa.ditolak,
          pemicu: pemilikB);
      _notifications?.kirim(
        userId: b.penyewaId,
        tipe: TipeNotifikasi.pengajuanDitolak,
        judul: 'Pengajuanmu ditolak',
        isi: '${_items.byId(b.itemId)?.judul ?? item.judul}: tanggalnya '
            'sudah diambil orang lain.',
        tautan: '/sewaan?tab=riwayat',
      );
    }
    return bentrok.length;
  }

  @override
  Future<void> reject(String bookingId, String alasan) async {
    await Future<void>.delayed(delay);
    final (booking, item) = _pendingOwned(bookingId);
    final teks = alasan.trim();
    if (teks.isEmpty) {
      throw const BookingException('Tulis alasan penolakannya dulu, ya.');
    }
    _bookings.update(
        booking.copyWith(status: StatusBooking.ditolak, alasanTolak: teks));
    _chat?.catatKejadian(booking, item.ownerId, KejadianSewa.ditolak,
        pemicu: item.ownerId);
    _notifications?.kirim(
      userId: booking.penyewaId,
      tipe: TipeNotifikasi.pengajuanDitolak,
      judul: 'Pengajuanmu ditolak',
      isi: '${item.judul}: $teks',
      tautan: '/sewaan?tab=riwayat',
    );
  }

  @override
  Future<void> cancel(String bookingId) async {
    await Future<void>.delayed(delay);
    final booking = _bookings.byId(bookingId);
    if (booking == null || booking.penyewaId != _storage.sessionUserId) {
      throw const BookingException('Pengajuan ini tidak ditemukan.');
    }
    if (booking.status != StatusBooking.menunggu) {
      throw const BookingException(
          'Pengajuan ini sudah dijawab pemilik, jadi tidak bisa dibatalkan.');
    }
    _bookings.update(booking.copyWith(status: StatusBooking.dibatalkan));
  }

  /// Sewa + barang yang melibatkan user yang sedang masuk (penyewa/pemilik).
  (Booking, Item, String me) _sewaSaya(String bookingId) {
    final me = _storage.sessionUserId;
    final booking = _bookings.byId(bookingId);
    final item = booking == null ? null : _items.byId(booking.itemId);
    if (me == null || booking == null || item == null) {
      throw const BookingException(AppTeks.sewaTidakDitemukan);
    }
    if (booking.penyewaId != me && item.ownerId != me) {
      throw const BookingException('Kamu bukan pihak dalam sewa ini.');
    }
    return (booking, item, me);
  }

  @override
  Future<void> batalkanSewa(String bookingId, String alasan) async {
    await Future<void>.delayed(delay);
    final (booking, item, me) = _sewaSaya(bookingId);
    final teks = alasan.trim();
    if (teks.isEmpty) {
      throw const BookingException('Pilih atau tulis alasannya dulu, ya.');
    }
    final aturan = aturanBatal(booking, dateOnly(_now()));
    if (aturan == AturanBatal.tidakBisa ||
        booking.status != StatusBooking.disetujui) {
      throw BookingException(booking.status == StatusBooking.berlangsung
          ? 'Sewa yang sudah berlangsung tidak bisa dibatalkan.'
          : 'Sewa ini tidak bisa dibatalkan lagi.');
    }
    final batal = _bookings.update(booking.copyWith(
      status: StatusBooking.dibatalkan,
      dibatalkanOleh: me,
      alasanBatal: teks,
    ));
    if (aturan == AturanBatal.mendadak) {
      final akun = _accounts.byId(me)?.user;
      if (akun != null) {
        _accounts.updateUser(
            akun.copyWith(jumlahBatalMendadak: akun.jumlahBatalMendadak + 1));
      }
    }
    final olehPemilik = me == item.ownerId;
    final nama = _accounts.byId(me)?.user.nama ?? 'Pihak lain';
    _notifications?.kirim(
      userId: olehPemilik ? booking.penyewaId : item.ownerId,
      tipe: TipeNotifikasi.sewaDibatalkan,
      judul: 'Sewa dibatalkan',
      isi: '$nama membatalkan sewa ${item.judul}: $teks',
      tautan: olehPemilik ? '/sewaan?tab=riwayat' : '/pengajuan',
    );
    _chat?.catatKejadian(batal, item.ownerId, KejadianSewa.dibatalkan,
        pemicu: me);
  }

  @override
  Future<Booking> catatPembayaran(
    String bookingId, {
    required MetodeBayar metode,
    required bool diterima,
  }) async {
    final (booking, item, me) = _sewaSaya(bookingId);
    if (item.ownerId != me) {
      throw const BookingException('Hanya pemilik yang mencatat pembayaran.');
    }
    if (booking.barter) {
      throw const BookingException('Barter tidak memakai pembayaran.');
    }
    if (booking.status != StatusBooking.disetujui &&
        booking.status != StatusBooking.berlangsung) {
      throw const BookingException('Sewa ini tidak menunggu pembayaran.');
    }
    return _bookings.update(booking.copyWith(
      metodeBayar: metode,
      statusBayar: diterima ? StatusBayar.lunas : StatusBayar.belum,
      dibayarPada: diterima ? _now() : null,
    ));
  }

  @override
  Future<Booking> catatDenda(
    String bookingId, {
    required bool diterima,
    String? itemId,
  }) async {
    final (booking, item, me) = _sewaSaya(bookingId);
    final tawaran = itemId != null && itemId == booking.itemTawaranId;
    // Barang tawaran barter milik pengaju: pengaju yang menerima dendanya.
    final barang = tawaran ? _items.byId(itemId) : item;
    if (barang == null || barang.ownerId != me) {
      throw const BookingException('Hanya pemilik barang yang mencatat denda.');
    }
    final denda = hitungDenda(
      tanggalKembali: booking.tanggalKembali,
      hariKembali: dateOnly(_now()),
      dendaPerHari: barang.dendaPerHari,
    );
    final nilai = diterima ? denda.total : 0;
    return _bookings.update(tawaran
        ? booking.copyWith(dendaTawaran: nilai)
        : booking.copyWith(dendaTerlambat: nilai));
  }

  @override
  Future<List<RentangTanggal>> blockedDatesBarter(
      String itemId, String itemTawaranId) async {
    await Future<void>.delayed(delay);
    return [
      for (final id in [itemId, itemTawaranId])
        if (_items.byId(id) case final item?) ..._blocked(item),
    ];
  }

  @override
  Future<Booking> createBarter({
    required String itemId,
    required String itemTawaranId,
    required DateTime mulai,
    required DateTime kembali,
    String? pesan,
  }) async {
    await Future<void>.delayed(delay);
    final start = dateOnly(mulai);
    final end = dateOnly(kembali);
    final pengaju = _accounts.byId(_storage.sessionUserId ?? '')?.user;
    if (pengaju == null) throw const BookingException(AppTeks.sesiHabis);
    if (pengaju.statusVerifikasi != StatusVerifikasi.terverifikasi) {
      throw const BookingException(AppTeks.verifikasiDulu);
    }
    final item = _items.byId(itemId);
    final tawaran = _items.byId(itemTawaranId);
    if (item == null || !item.aktif || !item.bisaBarter) {
      throw const BookingException('Barang ini tidak menerima barter.');
    }
    if (item.ownerId == pengaju.id) {
      throw const BookingException(barangSendiriMessage);
    }
    if (tawaran == null || tawaran.ownerId != pengaju.id || !tawaran.aktif) {
      throw const BookingException('Pilih barang aktif milikmu untuk ditukar.');
    }
    final masalah =
        periksaRentang(mulai: start, kembali: end, hariIni: dateOnly(_now()));
    if (masalah != null) throw BookingException(masalah.pesan);
    for (final i in [item, tawaran]) {
      if (rentangMelewatiBlokir(start, end, _blocked(i))) {
        throw BookingConflictException(
            'Tanggalnya bentrok dengan jadwal ${i.judul}. Pilih tanggal lain.');
      }
    }
    final ganda = _bookings.all.any((b) =>
        b.penyewaId == pengaju.id &&
        b.itemId == itemId &&
        b.status == StatusBooking.menunggu &&
        rentangBertumpuk(start, end, b.tanggalMulai, b.tanggalKembali));
    if (ganda) throw const BookingException(pengajuanGandaMessage);

    final trimmed = pesan?.trim();
    final booking = Booking(
      id: 'bkg-${(_bookings.length + 1).toString().padLeft(3, '0')}',
      itemId: itemId,
      penyewaId: pengaju.id,
      tanggalMulai: start,
      tanggalKembali: end,
      totalHarga: 0,
      pesan: trimmed == null || trimmed.isEmpty ? null : trimmed,
      dibuatPada: _now(),
      jenis: JenisTransaksi.barter,
      itemTawaranId: itemTawaranId,
    );
    _bookings.add(booking);
    _chat?.catatKejadian(booking, item.ownerId, KejadianSewa.barterDikirim,
        pemicu: pengaju.id);
    _notifications?.kirim(
      userId: item.ownerId,
      tipe: TipeNotifikasi.pengajuanBaru,
      judul: 'Tawaran barter untuk ${item.judul}',
      isi: '${pengaju.nama} menawarkan ${tawaran.judul} untuk '
          '${hitungHari(start, end)} hari. Cek dan jawab, ya.',
      tautan: '/pengajuan',
    );
    return booking;
  }

  @override
  Future<Booking> counterBarter(
      String bookingId, String itemTawaranBaruId) async {
    await Future<void>.delayed(delay);
    final (booking, item) = _pendingOwned(bookingId);
    if (!booking.barter) {
      throw const BookingException('Ini bukan tawaran barter.');
    }
    final baru = _items.byId(itemTawaranBaruId);
    if (baru == null || baru.ownerId != booking.penyewaId || !baru.aktif) {
      throw const BookingException('Pilih barang aktif milik pengaju.');
    }
    if (baru.id == booking.itemTawaranId) {
      throw const BookingException('Barang itu sudah ditawarkan.');
    }
    if (rentangMelewatiBlokir(
        booking.tanggalMulai, booking.tanggalKembali, _blocked(baru))) {
      throw BookingConflictException(
          '${baru.judul} sudah terpakai di tanggal itu.');
    }
    final updated = _bookings.update(booking.copyWith(
      itemTawaranId: baru.id,
      perluTanggapanPengaju: true,
    ));
    _chat?.catatKejadian(updated, item.ownerId, KejadianSewa.barterDiminta,
        pemicu: item.ownerId);
    _notifications?.kirim(
      userId: booking.penyewaId,
      tipe: TipeNotifikasi.barterDiminta,
      judul: 'Pemilik meminta barang lain',
      isi: 'Untuk barter ${item.judul}, pemilik ingin meminjam '
          '${baru.judul}. Setuju atau batalkan dari Sewaan Saya.',
      tautan: '/sewaan?tab=menunggu',
    );
    return updated;
  }

  @override
  Future<Booking> setujuiCounter(String bookingId) async {
    await Future<void>.delayed(delay);
    final booking = _bookings.byId(bookingId);
    final item = booking == null ? null : _items.byId(booking.itemId);
    if (booking == null ||
        item == null ||
        booking.penyewaId != _storage.sessionUserId) {
      throw const BookingException('Tawaran barter ini tidak ditemukan.');
    }
    if (booking.status != StatusBooking.menunggu ||
        !booking.perluTanggapanPengaju) {
      throw const BookingException('Tawaran ini tidak menunggu jawabanmu.');
    }
    _setujui(booking, item, olehPengaju: true);
    return _bookings.byId(bookingId)!;
  }

  @override
  Future<BookingDetail?> bookingById(String bookingId) async {
    await Future<void>.delayed(delay);
    final booking = _bookings.byId(bookingId);
    return booking == null ? null : _detail(booking);
  }
}

import 'dart:async';

import '../../../core/utils/dates.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_chat_store.dart';
import '../../../data/fake/fake_handover_review_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../../../data/fake/fake_notification_store.dart';
import '../../activity/domain/notification_item.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/booking_rules.dart';
import '../../chat/domain/chat_message.dart';
import '../../item/domain/item.dart';
import '../domain/checklist_repository.dart';
import '../domain/handover_checklist.dart';
import '../../../core/constants/app_strings.dart';

class FakeChecklistRepository implements ChecklistRepository {
  FakeChecklistRepository({
    required this._store,
    required this._bookings,
    required this._items,
    required this._now,
    this._notifications,
    this._chat,
    this.delay = const Duration(milliseconds: 500),
    this.autoApproveDelay = const Duration(seconds: 2),
  });

  final FakeChecklistStore _store;
  final FakeBookingStore _bookings;
  final FakeItemStore _items;
  final DateTime Function() _now;
  final FakeNotificationStore? _notifications;

  /// Pesan sistem saat serah terima / pengembalian beres.
  final FakeChatStore? _chat;
  final Duration delay;

  /// Pihak lawan otomatis menyetujui setelah jeda ini; `null` = mati (test).
  final Duration? autoApproveDelay;

  final _changes = StreamController<HandoverChecklist>.broadcast();

  /// Sewa + barang yang dicek + pemilik & peminjam barang itu.
  /// Barang tawaran barter: pemilik = pengaju, peminjam = pemilik barang utama.
  ({Booking booking, Item barang, String pemilik, String peminjam}) _konteks(
      String bookingId, String? itemId) {
    final booking = _bookings.byId(bookingId);
    final utama = booking == null ? null : _items.byId(booking.itemId);
    if (booking == null || utama == null) {
      throw const ChecklistException(AppTeks.sewaTidakDitemukan);
    }
    if (itemId == null || itemId == booking.itemId) {
      return (
        booking: booking,
        barang: utama,
        pemilik: utama.ownerId,
        peminjam: booking.penyewaId,
      );
    }
    final tawaran = _items.byId(itemId);
    if (!booking.barter || itemId != booking.itemTawaranId || tawaran == null) {
      throw const ChecklistException('Barang ini bukan bagian dari sewa ini.');
    }
    return (
      booking: booking,
      barang: tawaran,
      pemilik: booking.penyewaId,
      peminjam: utama.ownerId,
    );
  }

  /// `null` untuk barang utama supaya kunci sewa biasa tidak berubah.
  String? _kunci(Booking b, String? itemId) =>
      itemId == null || itemId == b.itemId ? null : itemId;

  HandoverChecklist _current(
      String bookingId, TahapChecklist tahap, String? itemId) {
    final k = _konteks(bookingId, itemId);
    final kunci = _kunci(k.booking, itemId);
    final existing = _store.get(bookingId, tahap, itemId: kunci);
    if (existing != null) return existing;
    return _store.put(HandoverChecklist(
      bookingId: bookingId,
      tahap: tahap,
      itemId: kunci,
      daftarKondisi: templateChecklist(k.barang.kategori),
    ));
  }

  void _assertTahapTerbuka(Booking booking, TahapChecklist tahap) {
    final bisa = switch (tahap) {
      TahapChecklist.awal => booking.status == StatusBooking.disetujui ||
          booking.status == StatusBooking.berlangsung ||
          booking.status == StatusBooking.selesai,
      TahapChecklist.akhir => booking.status == StatusBooking.berlangsung ||
          booking.status == StatusBooking.selesai,
    };
    if (!bisa) {
      throw ChecklistException(tahap == TahapChecklist.awal
          ? 'Checklist ambil barang terbuka setelah pengajuan disetujui.'
          : 'Checklist pengembalian terbuka setelah serah terima awal beres.');
    }
  }

  HandoverChecklist _emit(HandoverChecklist c) {
    _changes.add(c);
    return c;
  }

  @override
  Future<HandoverChecklist> get(String bookingId, TahapChecklist tahap,
      {String? itemId}) async {
    await Future<void>.delayed(delay);
    return _current(bookingId, tahap, itemId);
  }

  @override
  Stream<HandoverChecklist> watch(String bookingId, TahapChecklist tahap,
      {String? itemId}) async* {
    final first = await get(bookingId, tahap, itemId: itemId);
    yield first;
    yield* _changes.stream.where((c) =>
        c.bookingId == bookingId && c.tahap == tahap && c.itemId == first.itemId);
  }

  @override
  Future<HandoverChecklist> save(HandoverChecklist checklist) async {
    final current =
        _current(checklist.bookingId, checklist.tahap, checklist.itemId);
    if (current.selesai) {
      throw const ChecklistException(
          'Checklist ini sudah disetujui kedua pihak.');
    }
    return _emit(_store.put(checklist.copyWith(
      itemId: current.itemId,
      disetujuiPemilik: current.disetujuiPemilik,
      disetujuiPenyewa: current.disetujuiPenyewa,
      disetujuiPemilikPada: current.disetujuiPemilikPada,
      disetujuiPenyewaPada: current.disetujuiPenyewaPada,
    )));
  }

  @override
  Future<HandoverChecklist> approve(
      String bookingId, TahapChecklist tahap, String userId,
      {String? itemId}) async {
    await Future<void>.delayed(delay);
    final k = _konteks(bookingId, itemId);
    final sebagaiPemilik = userId == k.pemilik;
    if (!sebagaiPemilik && userId != k.peminjam) {
      throw const ChecklistException('Kamu bukan pihak dalam sewa ini.');
    }
    _assertTahapTerbuka(k.booking, tahap);

    final current = _current(bookingId, tahap, itemId);
    if (current.selesai) return current;
    final masalah = periksaChecklist(current);
    if (masalah.isNotEmpty) throw ChecklistException(masalah.first);

    if (sebagaiPemilik) {
      final syarat = syaratPemilik(k.booking, tahap, itemId: itemId);
      if (syarat != null) throw ChecklistException(syarat);
    }

    final updated = _setuju(current, sebagaiPemilik);
    if (!updated.selesai && autoApproveDelay != null) {
      Timer(autoApproveDelay!, () {
        final latest = _store.get(bookingId, tahap, itemId: current.itemId);
        if (latest != null && !latest.selesai) {
          // Simulasi: pemilik lawan mencatat pembayaran / denda dulu.
          if (!sebagaiPemilik) {
            _lengkapiSyaratPemilik(bookingId, tahap, current.itemId);
          }
          _setuju(latest, !sebagaiPemilik);
        }
      });
    }
    return updated;
  }

  /// Syarat sebelum pemilik barang boleh menyetujui (README "Aturan
  /// transaksi"): awal = pembayaran COD sudah diterima (bukan untuk barter);
  /// akhir = denda telat sudah diterima bila terlambat. `null` = boleh.
  String? syaratPemilik(Booking booking, TahapChecklist tahap,
      {String? itemId}) {
    if (tahap == TahapChecklist.awal) {
      return booking.barter || booking.statusBayar == StatusBayar.lunas
          ? null
          : 'Tandai pembayaran sudah diterima dulu, ya.';
    }
    final tawaran = _kunci(booking, itemId) != null;
    final denda = _denda(booking, itemId);
    final tercatat = tawaran ? booking.dendaTawaran : booking.dendaTerlambat;
    return denda > 0 && tercatat < denda
        ? 'Konfirmasi denda keterlambatan sudah diterima dulu, ya.'
        : null;
  }

  int _denda(Booking b, String? itemId) => hitungDenda(
        tanggalKembali: b.tanggalKembali,
        hariKembali: dateOnly(_now()),
        dendaPerHari:
            _items.byId(_kunci(b, itemId) ?? b.itemId)?.dendaPerHari ?? 0,
      ).total;

  void _lengkapiSyaratPemilik(
      String bookingId, TahapChecklist tahap, String? itemId) {
    final b = _bookings.byId(bookingId);
    if (b == null) return;
    if (tahap == TahapChecklist.awal) {
      if (b.barter) return;
      _bookings.update(b.copyWith(
        statusBayar: StatusBayar.lunas,
        metodeBayar: b.metodeBayar ?? MetodeBayar.tunai,
        dibayarPada: b.dibayarPada ?? _now(),
      ));
      return;
    }
    final denda = _denda(b, itemId);
    _bookings.update(_kunci(b, itemId) != null
        ? b.copyWith(dendaTawaran: denda)
        : b.copyWith(dendaTerlambat: denda));
  }

  /// Semua checklist tahap ini sudah disetujui kedua pihak (dua barang untuk
  /// barter).
  bool _tahapBeres(Booking b, TahapChecklist tahap) => [
        null,
        if (b.barter) b.itemTawaranId,
      ].every((id) => _store.get(b.id, tahap, itemId: id)?.selesai ?? false);

  HandoverChecklist _setuju(HandoverChecklist c, bool pemilik) {
    final now = _now();
    final updated = _store.put(pemilik
        ? c.copyWith(disetujuiPemilik: true, disetujuiPemilikPada: now)
        : c.copyWith(disetujuiPenyewa: true, disetujuiPenyewaPada: now));
    final k = _konteks(c.bookingId, c.itemId);
    final booking = k.booking;
    final akhir = c.tahap == TahapChecklist.akhir;
    if (!updated.selesai) {
      _notifications?.kirim(
        userId: pemilik ? k.peminjam : k.pemilik,
        tipe: TipeNotifikasi.giliranChecklist,
        judul: 'Giliranmu konfirmasi serah terima',
        isi: '${pemilik ? 'Pemilik' : 'Peminjam'} sudah menyetujui checklist '
            '${akhir ? 'pengembalian' : 'ambil barang'} ${k.barang.judul}.',
        tautan: '/sewa/${c.bookingId}/checklist${akhir ? '?tahap=akhir' : ''}',
      );
    }
    if (updated.selesai && _tahapBeres(booking, c.tahap)) {
      final next = akhir ? StatusBooking.selesai : StatusBooking.berlangsung;
      if (booking.status != next) {
        _bookings.update(booking.copyWith(status: next));
        final pemilikUtama = _items.byId(booking.itemId)?.ownerId;
        if (pemilikUtama != null) {
          _chat?.catatKejadian(
            booking,
            pemilikUtama,
            akhir ? KejadianSewa.pengembalian : KejadianSewa.serahTerima,
          );
        }
      }
    }
    return _emit(updated);
  }
}

import 'dart:async';

import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_handover_review_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../../booking/domain/booking.dart';
import '../domain/checklist_repository.dart';
import '../domain/handover_checklist.dart';

class FakeChecklistRepository implements ChecklistRepository {
  FakeChecklistRepository({
    required this._store,
    required this._bookings,
    required this._items,
    required this._now,
    this.delay = const Duration(milliseconds: 500),
    this.autoApproveDelay = const Duration(seconds: 2),
  });

  final FakeChecklistStore _store;
  final FakeBookingStore _bookings;
  final FakeItemStore _items;
  final DateTime Function() _now;
  final Duration delay;

  /// Pihak lawan otomatis menyetujui setelah jeda ini; `null` = mati (test).
  final Duration? autoApproveDelay;

  final _changes = StreamController<HandoverChecklist>.broadcast();

  (Booking, String ownerId) _booking(String bookingId) {
    final booking = _bookings.byId(bookingId);
    final item = booking == null ? null : _items.byId(booking.itemId);
    if (booking == null || item == null) {
      throw const ChecklistException('Sewa ini tidak ditemukan.');
    }
    return (booking, item.ownerId);
  }

  HandoverChecklist _current(String bookingId, TahapChecklist tahap) {
    final existing = _store.get(bookingId, tahap);
    if (existing != null) return existing;
    final (booking, _) = _booking(bookingId);
    final item = _items.byId(booking.itemId)!;
    return _store.put(HandoverChecklist(
      bookingId: bookingId,
      tahap: tahap,
      daftarKondisi: templateChecklist(item.kategori),
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
  Future<HandoverChecklist> get(String bookingId, TahapChecklist tahap) async {
    await Future<void>.delayed(delay);
    return _current(bookingId, tahap);
  }

  @override
  Stream<HandoverChecklist> watch(
      String bookingId, TahapChecklist tahap) async* {
    yield await get(bookingId, tahap);
    yield* _changes.stream
        .where((c) => c.bookingId == bookingId && c.tahap == tahap);
  }

  @override
  Future<HandoverChecklist> save(HandoverChecklist checklist) async {
    final current = _current(checklist.bookingId, checklist.tahap);
    if (current.selesai) {
      throw const ChecklistException(
          'Checklist ini sudah disetujui kedua pihak.');
    }
    return _emit(_store.put(checklist.copyWith(
      disetujuiPemilik: current.disetujuiPemilik,
      disetujuiPenyewa: current.disetujuiPenyewa,
      disetujuiPemilikPada: current.disetujuiPemilikPada,
      disetujuiPenyewaPada: current.disetujuiPenyewaPada,
    )));
  }

  @override
  Future<HandoverChecklist> approve(
      String bookingId, TahapChecklist tahap, String userId) async {
    await Future<void>.delayed(delay);
    final (booking, ownerId) = _booking(bookingId);
    final sebagaiPemilik = userId == ownerId;
    if (!sebagaiPemilik && userId != booking.penyewaId) {
      throw const ChecklistException('Kamu bukan pihak dalam sewa ini.');
    }
    _assertTahapTerbuka(booking, tahap);

    final current = _current(bookingId, tahap);
    if (current.selesai) return current;
    final masalah = periksaChecklist(current);
    if (masalah.isNotEmpty) throw ChecklistException(masalah.first);

    final updated = _setuju(current, sebagaiPemilik);
    if (!updated.selesai && autoApproveDelay != null) {
      Timer(autoApproveDelay!, () {
        final latest = _store.get(bookingId, tahap);
        if (latest != null && !latest.selesai) _setuju(latest, !sebagaiPemilik);
      });
    }
    return updated;
  }

  HandoverChecklist _setuju(HandoverChecklist c, bool pemilik) {
    final now = _now();
    final updated = _store.put(pemilik
        ? c.copyWith(disetujuiPemilik: true, disetujuiPemilikPada: now)
        : c.copyWith(disetujuiPenyewa: true, disetujuiPenyewaPada: now));
    if (updated.selesai) {
      final booking = _bookings.byId(c.bookingId)!;
      final next = c.tahap == TahapChecklist.awal
          ? StatusBooking.berlangsung
          : StatusBooking.selesai;
      if (booking.status != next) {
        _bookings.update(booking.copyWith(status: next));
      }
    }
    return _emit(updated);
  }
}

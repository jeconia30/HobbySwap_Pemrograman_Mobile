import '../../../core/storage/session_storage.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../../../data/fake/fake_laporan_store.dart';
import '../../../data/fake/fake_notification_store.dart';
import '../../activity/domain/notification_item.dart';
import '../../../core/utils/formatters.dart';
import '../domain/laporan.dart';
import '../domain/laporan_repository.dart';

class FakeLaporanRepository implements LaporanRepository {
  FakeLaporanRepository({
    required this._store,
    required this._storage,
    required this._accounts,
    required this._items,
    required this._bookings,
    required this._now,
    this._notifications,
    this.delay = const Duration(milliseconds: 500),
  });

  final FakeLaporanStore _store;
  final SessionStorage _storage;
  final FakeAccountStore _accounts;
  final FakeItemStore _items;
  final FakeBookingStore _bookings;
  final DateTime Function() _now;
  final FakeNotificationStore? _notifications;
  final Duration delay;

  String get _me {
    final id = _storage.sessionUserId;
    if (id == null) throw const LaporanException('Sesimu habis. Masuk lagi ya.');
    return id;
  }

  LaporanView? _view(Laporan l, String userId) {
    final pelapor = _accounts.byId(l.pelaporId)?.user;
    final terlapor = _accounts.byId(l.terlaporId)?.user;
    if (pelapor == null || terlapor == null) return null;
    final booking = l.bookingId == null ? null : _bookings.byId(l.bookingId!);
    return LaporanView(
      laporan: l,
      viewerId: userId,
      pelapor: pelapor,
      terlapor: terlapor,
      item: booking == null ? null : _items.byId(booking.itemId),
    );
  }

  bool _terlihat(Laporan l, String userId) =>
      l.pelaporId == userId ||
      (l.terlaporId == userId && l.jenis.terkaitSewa);

  Stream<T> _live<T>(T Function() read) async* {
    await Future<void>.delayed(delay);
    yield read();
    yield* _store.changes.map((_) => read());
  }

  @override
  Stream<List<LaporanView>> laporanku(String userId) => _live(() => [
        for (final l in _store.all)
          if (_terlihat(l, userId)) _view(l, userId),
      ].nonNulls.toList()
        ..sort((a, b) => b.laporan.dibuatPada.compareTo(a.laporan.dibuatPada)));

  @override
  Stream<LaporanView?> watch(String id, String userId) => _live(() {
        final l = _store.byId(id);
        return l == null || !_terlihat(l, userId) ? null : _view(l, userId);
      });

  @override
  Future<Laporan> kirim({
    String? bookingId,
    required String terlaporId,
    required JenisLaporan jenis,
    List<String> itemBermasalah = const [],
    required String deskripsi,
    List<String> fotoBukti = const [],
    UsulanPenyelesaian? usulan,
    int? nominal,
  }) async {
    await Future<void>.delayed(delay);
    final me = _me;
    final teks = deskripsi.trim();
    if (terlaporId == me) {
      throw const LaporanException('Kamu tidak bisa melaporkan dirimu sendiri.');
    }
    if (_accounts.byId(terlaporId) == null) {
      throw const LaporanException('Pengguna ini tidak ditemukan.');
    }
    if (teks.length < laporanMin || teks.length > laporanMaks) {
      throw const LaporanException(
          'Ceritakan masalahnya $laporanMin–$laporanMaks karakter, ya.');
    }
    if (jenis == JenisLaporan.kerusakan && itemBermasalah.isEmpty) {
      throw const LaporanException('Pilih item yang bermasalah dulu, ya.');
    }
    if (jenis.terkaitSewa && usulan == null) {
      throw const LaporanException('Pilih usulan penyelesaiannya dulu, ya.');
    }
    if (usulan == UsulanPenyelesaian.gantiRugi && (nominal ?? 0) <= 0) {
      throw const LaporanException('Isi nominal ganti ruginya, ya.');
    }
    final now = _now();
    final laporan = _store.put(Laporan(
      id: _store.nextId(),
      bookingId: bookingId,
      pelaporId: me,
      terlaporId: terlaporId,
      jenis: jenis,
      itemChecklistBermasalah: itemBermasalah,
      deskripsi: teks,
      fotoBukti: fotoBukti,
      usulan: jenis.terkaitSewa ? usulan : null,
      nominal: usulan == UsulanPenyelesaian.gantiRugi ? nominal : null,
      riwayat: [
        RiwayatLaporan(waktu: now, judul: 'Laporan dikirim', olehUserId: me),
        if (!jenis.terkaitSewa)
          RiwayatLaporan(
            waktu: now,
            judul: 'Diteruskan ke tim HobbySwap untuk ditinjau',
          ),
      ],
      dibuatPada: now,
    ));
    if (jenis.terkaitSewa) {
      final nama = _accounts.byId(me)?.user.nama ?? 'Pemilik';
      _notifications?.kirim(
        userId: terlaporId,
        tipe: TipeNotifikasi.laporanBaru,
        judul: 'Ada laporan ${jenis.label.toLowerCase()} untukmu',
        isi: '$nama mengusulkan: ${_usulanTeks(laporan)}. Tanggapi, ya.',
        tautan: '/laporan/${laporan.id}',
      );
    }
    return laporan;
  }

  static String _usulanTeks(Laporan l) => switch (l.usulan) {
        UsulanPenyelesaian.gantiRugi =>
          'ganti rugi ${formatRupiah(l.nominal ?? 0)}',
        final u? => u.label.toLowerCase(),
        null => 'ditinjau tim HobbySwap',
      };

  Laporan _milikTerlapor(String id) {
    final l = _store.byId(id);
    if (l == null) throw const LaporanException('Laporan tidak ditemukan.');
    if (l.terlaporId != _me) {
      throw const LaporanException('Hanya pihak terlapor yang bisa menanggapi.');
    }
    if (l.status != StatusLaporan.menungguTanggapan || l.usulan == null) {
      throw const LaporanException('Laporan ini sudah ditanggapi.');
    }
    return l;
  }

  Laporan _catat(Laporan l, StatusLaporan status, String judul,
      {String? isi}) {
    final updated = _store.put(l.copyWith(
      status: status,
      riwayat: [
        ...l.riwayat,
        RiwayatLaporan(waktu: _now(), judul: judul, isi: isi, olehUserId: _me),
      ],
    ));
    final penerima = _me == l.pelaporId ? l.terlaporId : l.pelaporId;
    _notifications?.kirim(
      userId: penerima,
      tipe: TipeNotifikasi.laporanDitanggapi,
      judul: judul,
      isi: 'Laporan ${l.jenis.label.toLowerCase()}: ${status.label}.',
      tautan: '/laporan/${l.id}',
    );
    return updated;
  }

  @override
  Future<Laporan> terimaUsulan(String id) async {
    await Future<void>.delayed(delay);
    return _catat(_milikTerlapor(id), StatusLaporan.diterima, 'Usulan diterima');
  }

  @override
  Future<Laporan> ajukanBanding(String id) async {
    await Future<void>.delayed(delay);
    return _catat(_milikTerlapor(id), StatusLaporan.dibanding,
        'Banding diajukan',
        isi: 'Diteruskan ke tim HobbySwap untuk ditinjau.');
  }

  @override
  Future<Laporan> tandaiSelesai(String id) async {
    await Future<void>.delayed(delay);
    final l = _store.byId(id);
    if (l == null) throw const LaporanException('Laporan tidak ditemukan.');
    if (l.pelaporId != _me || l.status != StatusLaporan.diterima) {
      throw const LaporanException('Laporan ini belum bisa diselesaikan.');
    }
    return _catat(l, StatusLaporan.selesai, 'Laporan selesai');
  }
}

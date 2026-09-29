import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/clock.dart';
import '../../core/utils/dates.dart';
import '../../features/laporan/domain/laporan.dart';
import 'fake_persistence.dart';
import 'sample_data.dart';

/// Laporan di memori (+ tersimpan di perangkat).
class FakeLaporanStore {
  FakeLaporanStore(List<Laporan> seed,
      [this._db = const FakePersistence.none()])
      : _list = [...seed];

  static const storageKey = 'laporan';

  final List<Laporan> _list;
  final FakePersistence _db;
  final _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  List<Laporan> get all => List.unmodifiable(_list);

  Laporan? byId(String id) => _list.where((l) => l.id == id).firstOrNull;

  String nextId() => 'lpr-${(_list.length + 1).toString().padLeft(3, '0')}';

  Laporan put(Laporan l) {
    final i = _list.indexWhere((x) => x.id == l.id);
    if (i < 0) {
      _list.add(l);
    } else {
      _list[i] = l;
    }
    _db.save(storageKey, _list, (l) => l.toJson());
    _changes.add(null);
    return l;
  }
}

/// Laporan contoh: Sarah melaporkan kerusakan kecil tenda yang disewa
/// Gregorian (menunggu tanggapan Gregorian).
List<Laporan> sampleLaporanFor(DateTime today) {
  final dibuat = addDays(dateOnly(today), -7).add(const Duration(hours: 10));
  return [
    Laporan(
      id: 'lpr-001',
      bookingId: sewaBelumDinilaiPenyewa,
      pelaporId: 'usr-004',
      terlaporId: gregorian,
      jenis: JenisLaporan.kerusakan,
      itemChecklistBermasalah: const ['Frame, pasak, atau tali lengkap'],
      deskripsi: 'Dua pasak tenda tidak ikut dikembalikan dan satu tali '
          'penahan putus. Pasak & tali pengganti sekitar Rp20.000.',
      fotoBukti: const ['simulasi://laporan/lpr-001/0'],
      usulan: UsulanPenyelesaian.gantiRugi,
      nominal: 20000,
      riwayat: [
        RiwayatLaporan(
          waktu: dibuat,
          judul: 'Laporan dikirim',
          olehUserId: 'usr-004',
        ),
      ],
      dibuatPada: dibuat,
    ),
  ];
}

final fakeLaporanStoreProvider = Provider<FakeLaporanStore>((ref) {
  final db = ref.watch(fakePersistenceProvider);
  return FakeLaporanStore(
    db.load(FakeLaporanStore.storageKey, Laporan.fromJson) ??
        sampleLaporanFor(ref.watch(clockProvider)()),
    db,
  );
});

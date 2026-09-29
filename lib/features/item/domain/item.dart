import 'package:freezed_annotation/freezed_annotation.dart';

import '../../auth/domain/user.dart';
import 'kategori.dart';
import '../../../core/constants/app_strings.dart';

part 'item.freezed.dart';
part 'item.g.dart';

@freezed
abstract class RentangTanggal with _$RentangTanggal {
  const factory RentangTanggal({
    required DateTime mulai,
    required DateTime selesai,
  }) = _RentangTanggal;

  factory RentangTanggal.fromJson(Map<String, dynamic> json) =>
      _$RentangTanggalFromJson(json);
}

@freezed
abstract class Item with _$Item {
  const factory Item({
    required String id,
    required String ownerId,
    required String judul,
    required String deskripsi,
    required Kategori kategori,
    required int hargaPerHari,
    @Default(<String>[]) List<String> daftarFoto,
    required String lokasiKampus,
    @Default(<RentangTanggal>[]) List<RentangTanggal> rentangTidakTersedia,
    @Default(0) int jumlahDisewa,

    /// Diatur pemilik; `false` = tidak tampil di Beranda & tidak bisa disewa.
    @Default(true) bool aktif,

    /// Denda keterlambatan per hari (Rp); 0 = tanpa denda (M10).
    @Default(0) int dendaPerHari,

    /// Pemilik menerima tawaran barter (tukar pinjam sementara, M11).
    @Default(false) bool bisaBarter,

    /// Kategori barang yang dicari pemilik untuk barter.
    @Default(<Kategori>[]) List<Kategori> minatBarter,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}

/// Status tampil barang, diturunkan dari [Item.aktif] + sewa berlangsung.
enum ItemStatus {
  tersedia(AppTeks.statusTersedia),
  disewa(AppTeks.statusDisewa),
  dibarter(AppTeks.statusDibarter),
  nonaktif(AppTeks.statusNonaktif);

  const ItemStatus(this.label);

  final String label;
}

/// Isian form tambah/ubah barang.
@immutable
class ItemInput {
  const ItemInput({
    required this.judul,
    required this.deskripsi,
    required this.kategori,
    required this.hargaPerHari,
    required this.lokasiKampus,
    this.daftarFoto = const [],
    this.dendaPerHari = 0,
    this.bisaBarter = false,
    this.minatBarter = const [],
  });

  final String judul;
  final String deskripsi;
  final Kategori kategori;
  final int hargaPerHari;
  final String lokasiKampus;
  final List<String> daftarFoto;
  final int dendaPerHari;
  final bool bisaBarter;
  final List<Kategori> minatBarter;
}

/// Barang beserta pemilik & status tampilnya (rating di kartu = rating pemilik).
@immutable
class ItemListing {
  const ItemListing({
    required this.item,
    required this.owner,
    this.status = ItemStatus.tersedia,
    this.disewaSampai,
  });

  final Item item;
  final User owner;
  final ItemStatus status;

  /// Tanggal kembali sewa yang sedang berlangsung (bila [ItemStatus.disewa]).
  final DateTime? disewaSampai;
}

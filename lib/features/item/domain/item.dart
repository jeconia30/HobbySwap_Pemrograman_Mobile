import 'package:freezed_annotation/freezed_annotation.dart';

import '../../auth/domain/user.dart';
import 'kategori.dart';

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
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}

/// Status tampil barang, diturunkan dari [Item.aktif] + sewa berlangsung.
enum ItemStatus {
  tersedia('Tersedia'),
  disewa('Disewa'),
  nonaktif('Nonaktif');

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
  });

  final String judul;
  final String deskripsi;
  final Kategori kategori;
  final int hargaPerHari;
  final String lokasiKampus;
  final List<String> daftarFoto;
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

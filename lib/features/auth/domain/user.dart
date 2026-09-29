import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum StatusVerifikasi { belum, menunggu, terverifikasi }

/// 6 warna preset avatar inisial (warna ada di `AppPalette`).
enum WarnaAvatar { hijau, pinus, biru, ungu, coklat, bata }

const maksBio = 120;

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String nama,
    required String nim,
    required String email,
    String? fotoProfil,
    String? fakultas,
    String? prodi,

    /// Maksimal [maksBio] karakter.
    String? bio,
    @Default(WarnaAvatar.hijau) WarnaAvatar warnaAvatar,
    @Default(StatusVerifikasi.belum) StatusVerifikasi statusVerifikasi,
    @Default(0) double rating,
    @Default(0) int jumlahUlasan,

    /// Pembatalan di hari H setelah disetujui (M10).
    @Default(0) int jumlahBatalMendadak,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

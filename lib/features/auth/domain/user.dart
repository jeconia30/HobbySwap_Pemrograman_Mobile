import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum StatusVerifikasi { belum, menunggu, terverifikasi }

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String nama,
    required String nim,
    required String email,
    String? fotoProfil,
    String? fakultas,
    @Default(StatusVerifikasi.belum) StatusVerifikasi statusVerifikasi,
    @Default(0) double rating,
    @Default(0) int jumlahUlasan,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

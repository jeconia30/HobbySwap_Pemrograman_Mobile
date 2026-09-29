import 'user.dart';

/// Field form yang menjadi penyebab error, supaya pesan bisa tampil inline.
enum AuthField { nim, email }

class AuthException implements Exception {
  const AuthException(this.message, {this.field});

  final String message;
  final AuthField? field;

  @override
  String toString() => 'AuthException: $message';
}

/// Kontrak autentikasi. Implementasi palsu sekarang, API Spring Boot nanti.
abstract interface class AuthRepository {
  User? get currentUser;

  /// [identifier] berupa email kampus atau NIM. Melempar [AuthException].
  Future<User> login(String identifier, String password);

  Future<User> register({
    required String nama,
    required String nim,
    required String email,
    required String password,
  });

  /// Memulihkan sesi tersimpan saat app dibuka; `null` jika tidak ada/kedaluwarsa.
  Future<User?> restoreSession();

  Future<void> logout();

  /// Memperbarui profil user yang sedang masuk. NIM & email tidak bisa diubah.
  Future<User> updateProfile({
    required String nama,
    String? bio,
    required WarnaAvatar warnaAvatar,
  });

  /// Kirim tautan reset ke email kampus (simulasi). Tidak memberi tahu
  /// apakah email terdaftar, supaya tidak bisa dipakai menebak akun.
  Future<void> kirimTautanReset(String email);

  /// Setel password baru dari tautan reset (simulasi).
  Future<void> resetPassword({required String email, required String passwordBaru});

  /// Akun Google kampus di perangkat (simulasi pemilih akun Google).
  Future<List<User>> akunGoogle();

  /// Masuk dengan akun Google kampus (simulasi: pilih akun terdaftar).
  Future<User> loginDenganGoogle(String email);

  /// Hapus akun user yang sedang masuk lalu keluar (simulasi).
  Future<void> hapusAkun();
}

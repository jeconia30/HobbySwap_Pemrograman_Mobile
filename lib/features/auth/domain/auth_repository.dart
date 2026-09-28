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
}

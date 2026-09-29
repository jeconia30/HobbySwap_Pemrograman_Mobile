import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_providers.dart';
import '../domain/user.dart';

/// Sesi pengguna yang sedang masuk (`null` = belum masuk). Satu-satunya sumber
/// `currentUser` untuk UI; panggil [refresh] setelah data user berubah.
final authControllerProvider =
    NotifierProvider<AuthController, User?>(AuthController.new);

class AuthController extends Notifier<User?> {
  @override
  User? build() => ref.read(authRepositoryProvider).currentUser;

  Future<User?> restoreSession() async =>
      state = await ref.read(authRepositoryProvider).restoreSession();

  Future<User> login(String identifier, String password) async {
    final user =
        await ref.read(authRepositoryProvider).login(identifier, password);
    state = user;
    return user;
  }

  Future<void> register({
    required String nama,
    required String nim,
    required String email,
    required String password,
  }) async {
    state = await ref.read(authRepositoryProvider).register(
          nama: nama,
          nim: nim,
          email: email,
          password: password,
        );
  }

  Future<void> updateProfile({
    required String nama,
    String? bio,
    required WarnaAvatar warnaAvatar,
  }) async {
    state = await ref
        .read(authRepositoryProvider)
        .updateProfile(nama: nama, bio: bio, warnaAvatar: warnaAvatar);
  }

  Future<User> loginDenganGoogle(String email) async {
    final user = await ref.read(authRepositoryProvider).loginDenganGoogle(email);
    state = user;
    return user;
  }

  Future<void> hapusAkun() async {
    await ref.read(authRepositoryProvider).hapusAkun();
    state = null;
  }

  /// Menyalin ulang user terbaru dari repository (mis. setelah status berubah).
  void refresh() => state = ref.read(authRepositoryProvider).currentUser;

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = null;
  }
}

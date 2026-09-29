import '../../../core/storage/session_storage.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../../data/fake/sample_data.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    required this._storage,
    FakeAccountStore? store,
    this.delay = const Duration(milliseconds: 800),
  }) : _store = store ?? FakeAccountStore();

  static const invalidCredentialsMessage = 'Email/NIM atau password salah';
  static const accountTakenMessage =
      'NIM/email ini sudah punya akun. Coba masuk.';

  final SessionStorage _storage;
  final FakeAccountStore _store;
  final Duration delay;
  String? _currentUserId;

  /// Selalu dibaca dari store, jadi perubahan status langsung terlihat.
  @override
  User? get currentUser =>
      _currentUserId == null ? null : _store.byId(_currentUserId!)?.user;

  Future<User> _startSession(User user) async {
    await _storage.saveSession(user.id);
    _currentUserId = user.id;
    return user;
  }

  @override
  Future<User> login(String identifier, String password) async {
    await Future<void>.delayed(delay);
    final account = _store.byIdentifier(identifier);
    if (account == null || account.password != password) {
      throw const AuthException(invalidCredentialsMessage);
    }
    return _startSession(account.user);
  }

  @override
  Future<User> register({
    required String nama,
    required String nim,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    if (_store.nimTaken(nim)) {
      throw const AuthException(accountTakenMessage, field: AuthField.nim);
    }
    if (_store.emailTaken(email)) {
      throw const AuthException(accountTakenMessage, field: AuthField.email);
    }
    final user = User(
      id: 'usr-${(_store.length + 1).toString().padLeft(3, '0')}',
      nama: nama.trim(),
      nim: nim.trim(),
      email: email.trim().toLowerCase(),
    );
    _store.add(SampleAccount(user: user, password: password));
    return _startSession(user);
  }

  @override
  Future<User?> restoreSession() async {
    final id = _storage.sessionUserId;
    if (id == null) return null;
    final account = _store.byId(id);
    if (account == null) {
      // Akun hasil daftar hanya hidup di memori; sesinya tidak bisa dipulihkan.
      await _storage.clearSession();
      return null;
    }
    _currentUserId = id;
    return account.user;
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(delay ~/ 4);
    await _storage.clearSession();
    _currentUserId = null;
  }

  @override
  Future<void> kirimTautanReset(String email) async {
    await Future<void>.delayed(delay);
    if (AuthValidators.campusEmail(email) != null) {
      throw const AuthException('Pakai email @students.usu.ac.id',
          field: AuthField.email);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String passwordBaru,
  }) async {
    await Future<void>.delayed(delay);
    final masalah = AuthValidators.newPassword(passwordBaru);
    if (masalah != null) throw AuthException(masalah);
    final account = _store.byIdentifier(email);
    if (account == null) {
      throw const AuthException(
          'Tautan reset ini tidak berlaku. Minta tautan baru, ya.');
    }
    _store.updatePassword(account.user.id, passwordBaru);
  }

  @override
  Future<List<User>> akunGoogle() async => [
        for (final id in const ['usr-001', 'usr-002', 'usr-003'])
          ?_store.byId(id)?.user,
      ];

  @override
  Future<User> loginDenganGoogle(String email) async {
    await Future<void>.delayed(delay);
    final account = _store.byIdentifier(email);
    if (account == null) {
      throw const AuthException('Akun Google ini belum terdaftar. Daftar dulu, ya.');
    }
    return _startSession(account.user);
  }

  @override
  Future<void> hapusAkun() async {
    await Future<void>.delayed(delay);
    final id = _currentUserId;
    if (id == null) throw const AuthException(AppTeks.sesiHabis);
    _store.remove(id);
    await _storage.clearSession();
    _currentUserId = null;
  }

  @override
  Future<User> updateProfile({
    required String nama,
    String? bio,
    required WarnaAvatar warnaAvatar,
  }) async {
    await Future<void>.delayed(delay);
    final user = currentUser;
    if (user == null) throw const AuthException(AppTeks.sesiHabis);
    final namaBersih = nama.trim();
    if (namaBersih.length < 3 || namaBersih.length > 40) {
      throw const AuthException('Nama 3–40 karakter, ya.');
    }
    final bioBersih = bio?.trim() ?? '';
    if (bioBersih.length > maksBio) {
      throw const AuthException('Bio maksimal $maksBio karakter.');
    }
    return _store.updateUser(user.copyWith(
      nama: namaBersih,
      bio: bioBersih.isEmpty ? null : bioBersih,
      warnaAvatar: warnaAvatar,
    ));
  }
}

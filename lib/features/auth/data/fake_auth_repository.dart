import '../../../core/storage/session_storage.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../../data/fake/sample_data.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';

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
}

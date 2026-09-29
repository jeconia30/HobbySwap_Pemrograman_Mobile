import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/user.dart';
import 'fake_persistence.dart';
import 'sample_data.dart';

/// "Database" akun di memori, dipakai bersama oleh semua repository palsu
/// supaya perubahan (mis. status verifikasi) punya satu sumber kebenaran.
class FakeAccountStore {
  FakeAccountStore([
    List<SampleAccount> seed = sampleAccounts,
    this._db = const FakePersistence.none(),
  ]) : _accounts = [...seed];

  static const storageKey = 'accounts';

  final List<SampleAccount> _accounts;
  final FakePersistence _db;

  static SampleAccount fromJson(Map<String, dynamic> j) => SampleAccount(
        user: User.fromJson(Map<String, dynamic>.from(j['user'] as Map)),
        password: j['password'] as String,
      );

  void _simpan() => _db.save(storageKey, _accounts,
      (a) => {'user': a.user.toJson(), 'password': a.password});

  int get length => _accounts.length;

  SampleAccount? byId(String id) =>
      _accounts.where((a) => a.user.id == id).firstOrNull;

  /// [identifier] = email (tidak peka huruf besar) atau NIM.
  SampleAccount? byIdentifier(String identifier) {
    final id = identifier.trim().toLowerCase();
    return _accounts
        .where((a) => a.user.email.toLowerCase() == id || a.user.nim == id)
        .firstOrNull;
  }

  bool nimTaken(String nim) => _accounts.any((a) => a.user.nim == nim.trim());

  bool emailTaken(String email) => _accounts
      .any((a) => a.user.email.toLowerCase() == email.trim().toLowerCase());

  void add(SampleAccount account) {
    _accounts.add(account);
    _simpan();
  }

  User updateUser(User user) {
    final i = _accounts.indexWhere((a) => a.user.id == user.id);
    if (i < 0) throw StateError('User ${user.id} tidak ada');
    _accounts[i] = SampleAccount(user: user, password: _accounts[i].password);
    _simpan();
    return user;
  }

  void updatePassword(String userId, String password) {
    final i = _accounts.indexWhere((a) => a.user.id == userId);
    if (i < 0) throw StateError('User $userId tidak ada');
    _accounts[i] = SampleAccount(user: _accounts[i].user, password: password);
    _simpan();
  }

  /// Hapus akun (simulasi "Hapus akun").
  void remove(String userId) {
    _accounts.removeWhere((a) => a.user.id == userId);
    _simpan();
  }
}

final fakeAccountStoreProvider = Provider<FakeAccountStore>((ref) {
  final db = ref.watch(fakePersistenceProvider);
  return FakeAccountStore(
    db.load(FakeAccountStore.storageKey, FakeAccountStore.fromJson) ??
        sampleAccounts,
    db,
  );
});

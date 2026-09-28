import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/user.dart';
import 'sample_data.dart';

/// "Database" akun di memori, dipakai bersama oleh semua repository palsu
/// supaya perubahan (mis. status verifikasi) punya satu sumber kebenaran.
class FakeAccountStore {
  FakeAccountStore([List<SampleAccount> seed = sampleAccounts])
      : _accounts = [...seed];

  final List<SampleAccount> _accounts;

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

  void add(SampleAccount account) => _accounts.add(account);

  User updateUser(User user) {
    final i = _accounts.indexWhere((a) => a.user.id == user.id);
    if (i < 0) throw StateError('User ${user.id} tidak ada');
    _accounts[i] = SampleAccount(user: user, password: _accounts[i].password);
    return user;
  }
}

final fakeAccountStoreProvider = Provider<FakeAccountStore>(
  (ref) => FakeAccountStore(),
);

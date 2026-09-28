import 'package:flutter/foundation.dart';

import '../../../core/storage/session_storage.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../auth/domain/user.dart';
import '../domain/verification_repository.dart';

class FakeVerificationRepository implements VerificationRepository {
  FakeVerificationRepository({
    required this._storage,
    required this._store,
    this.delay = const Duration(milliseconds: 1200),
  });

  final SessionStorage _storage;
  final FakeAccountStore _store;
  final Duration delay;

  User _sessionUser() {
    final id = _storage.sessionUserId;
    final account = id == null ? null : _store.byId(id);
    if (account == null) {
      throw const VerificationException('Sesimu habis. Masuk lagi ya.');
    }
    return account.user;
  }

  @override
  Future<StatusVerifikasi> submit(
      VerificationPhoto ktmPhoto, VerificationPhoto selfiePhoto) async {
    await Future<void>.delayed(delay);
    final user = _sessionUser();
    if (user.statusVerifikasi == StatusVerifikasi.terverifikasi) {
      return user.statusVerifikasi;
    }
    return _store
        .updateUser(user.copyWith(statusVerifikasi: StatusVerifikasi.menunggu))
        .statusVerifikasi;
  }

  @override
  Future<StatusVerifikasi> statusFor(String userId) async =>
      _store.byId(userId)?.user.statusVerifikasi ?? StatusVerifikasi.belum;

  @override
  Future<StatusVerifikasi> debugApprove() async {
    if (!kDebugMode) throw UnsupportedError('debugApprove hanya untuk debug');
    final user = _sessionUser();
    return _store
        .updateUser(
            user.copyWith(statusVerifikasi: StatusVerifikasi.terverifikasi))
        .statusVerifikasi;
  }
}

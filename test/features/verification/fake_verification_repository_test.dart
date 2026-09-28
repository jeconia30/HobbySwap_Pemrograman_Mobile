import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/storage/session_storage.dart';
import 'package:hobby_swab/data/fake/fake_account_store.dart';
import 'package:hobby_swab/features/auth/data/fake_auth_repository.dart';
import 'package:hobby_swab/features/auth/domain/user.dart';
import 'package:hobby_swab/features/verification/data/fake_verification_repository.dart';
import 'package:hobby_swab/features/verification/domain/verification_repository.dart';

import '../../helpers/pump_app.dart';

const photo = VerificationPhoto(source: PhotoSource.camera);

void main() {
  late SessionStorage storage;
  late FakeAccountStore store;
  late FakeAuthRepository auth;
  late FakeVerificationRepository verification;

  setUp(() async {
    storage = await mockStorage();
    store = FakeAccountStore();
    auth = FakeAuthRepository(storage: storage, store: store, delay: Duration.zero);
    verification = FakeVerificationRepository(
        storage: storage, store: store, delay: Duration.zero);
  });

  test('akun contoh Aulia berstatus belum', () async {
    final aulia = await auth.login('aulia@students.usu.ac.id', 'hobbyswap2026');
    expect(aulia.nama, 'Aulia Putri');
    expect(aulia.nim, '220402011');
    expect(aulia.statusVerifikasi, StatusVerifikasi.belum);
  });

  test('submit mengubah status belum → menunggu, terlihat di currentUser',
      () async {
    await auth.login('220402011', 'hobbyswap2026');
    expect(await verification.statusFor('usr-002'), StatusVerifikasi.belum);

    final status = await verification.submit(photo, photo);

    expect(status, StatusVerifikasi.menunggu);
    expect(await verification.statusFor('usr-002'), StatusVerifikasi.menunggu);
    expect(auth.currentUser?.statusVerifikasi, StatusVerifikasi.menunggu,
        reason: 'satu sumber kebenaran, tanpa login ulang');
  });

  test('debugApprove mengubah status jadi terverifikasi', () async {
    await auth.login('220402011', 'hobbyswap2026');
    await verification.submit(photo, photo);
    expect(await verification.debugApprove(), StatusVerifikasi.terverifikasi);
    expect(auth.currentUser?.statusVerifikasi, StatusVerifikasi.terverifikasi);
  });

  test('submit tanpa sesi melempar VerificationException', () async {
    await expectLater(
        verification.submit(photo, photo), throwsA(isA<VerificationException>()));
  });

  test('akun terverifikasi tidak turun status saat submit ulang', () async {
    await auth.login('220401087', 'hobbyswap2026');
    expect(await verification.submit(photo, photo),
        StatusVerifikasi.terverifikasi);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/storage/session_storage.dart';
import 'package:hobby_swab/features/auth/data/fake_auth_repository.dart';
import 'package:hobby_swab/features/auth/domain/auth_repository.dart';
import 'package:hobby_swab/features/auth/domain/user.dart';

import '../../helpers/pump_app.dart';

void main() {
  late SessionStorage storage;
  late FakeAuthRepository repo;

  setUp(() async {
    storage = await mockStorage();
    repo = FakeAuthRepository(storage: storage, delay: Duration.zero);
  });

  test('login & register menyimpan sesi, logout menghapusnya', () async {
    await repo.login('220401087', 'hobbyswap2026');
    expect(storage.sessionUserId, 'usr-001');
    await repo.logout();
    expect(storage.sessionUserId, isNull);

    final user = await repo.register(
        nama: 'Ani', nim: '230401009', email: 'ani@students.usu.ac.id', password: 'hobby2026');
    expect(storage.sessionUserId, user.id);
  });

  test('restoreSession memulihkan user dari data contoh', () async {
    await storage.saveSession('usr-001');
    final fresh = FakeAuthRepository(storage: storage, delay: Duration.zero);
    final user = await fresh.restoreSession();
    expect(user?.nim, '220401087');
    expect(fresh.currentUser, user);
  });

  test('restoreSession tanpa sesi / id tak dikenal mengembalikan null', () async {
    expect(await repo.restoreSession(), isNull);

    await storage.saveSession('usr-hilang');
    expect(await repo.restoreSession(), isNull);
    expect(storage.sessionUserId, isNull, reason: 'id basi dibersihkan');
  });

  test('login dengan email atau NIM akun contoh', () async {
    final byEmail = await repo.login('Gregorian@students.usu.ac.id', 'hobbyswap2026');
    expect(byEmail.statusVerifikasi, StatusVerifikasi.terverifikasi);
    expect(repo.currentUser, byEmail);

    await repo.logout();
    expect(repo.currentUser, isNull);

    final byNim = await repo.login('220401087', 'hobbyswap2026');
    expect(byNim.id, byEmail.id);
  });

  test('password salah atau akun tidak ada melempar AuthException', () async {
    final matcher = throwsA(isA<AuthException>().having(
        (e) => e.message, 'message', 'Email/NIM atau password salah'));
    await expectLater(repo.login('220401087', 'salah'), matcher);
    await expectLater(repo.login('999999999', 'hobbyswap2026'), matcher);
    expect(repo.currentUser, isNull);
  });

  test('register membuat user belum terverifikasi dan bisa login', () async {
    final user = await repo.register(
      nama: ' Siti Nurhaliza ',
      nim: '230401001',
      email: 'Siti@students.usu.ac.id',
      password: 'hobby2026',
    );
    expect(user.nama, 'Siti Nurhaliza');
    expect(user.email, 'siti@students.usu.ac.id');
    expect(user.statusVerifikasi, StatusVerifikasi.belum);
    expect(repo.currentUser, user);

    await repo.logout();
    expect(await repo.login('230401001', 'hobby2026'), user);
  });

  test('register dengan NIM/email yang sudah ada ditolak per field', () async {
    Matcher taken(AuthField field) => throwsA(isA<AuthException>()
        .having((e) => e.field, 'field', field)
        .having((e) => e.message, 'message',
            'NIM/email ini sudah punya akun. Coba masuk.'));

    await expectLater(
      repo.register(
          nama: 'Ani', nim: '220401087', email: 'ani@students.usu.ac.id', password: 'x'),
      taken(AuthField.nim),
    );
    await expectLater(
      repo.register(
          nama: 'Ani',
          nim: '230401002',
          email: 'GREGORIAN@students.usu.ac.id',
          password: 'x'),
      taken(AuthField.email),
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/features/auth/presentation/login_page.dart';
import 'package:hobby_swab/features/auth/presentation/register_page.dart';
import 'package:hobby_swab/features/verification/presentation/verifikasi_page.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> openRegisterFromLogin(WidgetTester tester) async {
    final link = find.widgetWithText(TextButton, 'Daftar');
    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPage), findsOneWidget);
  }

  Future<void> pumpRegister(WidgetTester tester) async {
    await pumpApp(tester);
    await openRegisterFromLogin(tester);
  }

  Finder field(String key) => find.descendant(
      of: find.byKey(Key(key)), matching: find.byType(EditableText));

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pump();
  }

  Future<void> fillValid(WidgetTester tester, {String nim = '230401001'}) async {
    await tester.enterText(field('register-nama'), 'Siti Nurhaliza');
    await tester.enterText(field('register-nim'), nim);
    await tester.enterText(field('register-email'), 'siti@students.usu.ac.id');
    await tester.enterText(field('register-password'), 'hobby2026');
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
  }

  testWidgets('Form kosong menampilkan semua pesan error inline',
      (tester) async {
    await pumpRegister(tester);
    await submit(tester);

    expect(find.text('Isi nama lengkap'), findsOneWidget);
    expect(find.text('Isi NIM'), findsOneWidget);
    expect(find.text('Isi email kampus'), findsOneWidget);
    expect(find.text('Isi password'), findsOneWidget);
    expect(find.text('Centang persetujuan dulu ya'), findsOneWidget);
  });

  testWidgets('Format salah menampilkan pesan spesifik', (tester) async {
    await pumpRegister(tester);
    await tester.enterText(field('register-nama'), 'Al');
    await tester.enterText(field('register-nim'), '1234');
    await tester.enterText(field('register-email'), 'al@gmail.com');
    await tester.enterText(field('register-password'), 'abcdefgh');
    await submit(tester);

    expect(find.text('Nama minimal 3 huruf'), findsOneWidget);
    expect(find.text('NIM harus 9 digit angka'), findsOneWidget);
    expect(find.text('Pakai email @students.usu.ac.id'), findsOneWidget);
    expect(find.text('Password harus ada huruf dan angka'), findsOneWidget);
  });

  testWidgets('Field NIM hanya menerima 9 angka', (tester) async {
    await pumpRegister(tester);
    await tester.enterText(field('register-nim'), '22a0401087999');
    await tester.pump();
    final editable = tester.widget<EditableText>(field('register-nim'));
    expect(editable.controller.text, '220401087');
  });

  testWidgets('Ikon centang muncul saat email kampus valid', (tester) async {
    await pumpRegister(tester);
    expect(find.byKey(const Key('register-email-valid')), findsNothing);
    await tester.enterText(field('register-email'), 'siti@students.usu.ac.id');
    await tester.pump();
    expect(find.byKey(const Key('register-email-valid')), findsOneWidget);
  });

  testWidgets('NIM yang sudah terdaftar tampil inline, hilang saat diubah',
      (tester) async {
    await pumpRegister(tester);
    await fillValid(tester, nim: '220401087');
    await submit(tester);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('NIM/email ini sudah punya akun. Coba masuk.'),
        findsOneWidget);
    expect(find.byType(VerifikasiPage), findsNothing);

    await tester.enterText(field('register-nim'), '230401001');
    await tester.pump();
    expect(find.text('NIM/email ini sudah punya akun. Coba masuk.'),
        findsNothing);
  });

  testWidgets('Daftar berhasil menuju placeholder verifikasi', (tester) async {
    await pumpRegister(tester);
    await fillValid(tester);
    await submit(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(find.byType(VerifikasiPage), findsOneWidget);
    expect(find.textContaining('Siti Nurhaliza · 230401001', findRichText: true),
        findsOneWidget);
  });

  testWidgets('Tombol kembali dan "Masuk" menuju login', (tester) async {
    await pumpRegister(tester);
    await tester.tap(find.byTooltip('Kembali ke halaman masuk'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    await openRegisterFromLogin(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Masuk'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });
}

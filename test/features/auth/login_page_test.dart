import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/features/auth/presentation/login_page.dart';
import 'package:hobby_swab/features/home/presentation/home_page.dart';

import '../../helpers/pump_app.dart';

void main() {
  Finder field(String key) => find.descendant(
      of: find.byKey(Key(key)), matching: find.byType(EditableText));

  testWidgets('Masuk dengan field kosong memunculkan pesan error',
      (tester) async {
    await pumpApp(tester);
    expect(find.byType(LoginPage), findsOneWidget);

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.text('Isi email kampus atau NIM'), findsOneWidget);
    expect(find.text('Isi password'), findsOneWidget);
  });

  testWidgets('Format identifier salah memunculkan pesan format',
      (tester) async {
    await pumpApp(tester);
    await tester.enterText(field('login-identifier'), 'greg@gmail.com');
    await tester.enterText(field('login-password'), 'apa saja');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.text('Pakai email @students.usu.ac.id atau NIM 9 digit'),
        findsOneWidget);
  });

  testWidgets('Password salah menampilkan kotak error dari repository',
      (tester) async {
    await pumpApp(tester);
    await tester.enterText(field('login-identifier'), '220401087');
    await tester.enterText(field('login-password'), 'salah');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('Email/NIM atau password salah'), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });

  testWidgets('Login berhasil ke Beranda, Keluar kembali ke Login',
      (tester) async {
    await pumpApp(tester);
    await tester.enterText(
        field('login-identifier'), 'gregorian@students.usu.ac.id');
    await tester.enterText(field('login-password'), 'hobbyswap2026');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Halo, Gregorian'), findsOneWidget);

    await logoutViaProfil(tester);
    expect(find.byType(LoginPage), findsOneWidget);
  });
}

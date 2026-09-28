import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/features/auth/presentation/login_page.dart';
import 'package:hobby_swab/features/home/presentation/home_page.dart';
import 'package:hobby_swab/features/onboarding/presentation/onboarding_page.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('Splash → Onboarding saat pertama kali dibuka', (tester) async {
    await pumpApp(tester, onboardingSeen: false);
    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.text('Pinjam alat hobi, tanpa harus beli.'), findsOneWidget);
  });

  testWidgets('Menekan "Lewati" menandai onboarding lalu ke /login',
      (tester) async {
    final storage = await pumpApp(tester, onboardingSeen: false);
    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(storage.onboardingSeen, isTrue);
  });

  testWidgets('"Lanjut" berpindah halaman, "Mulai" di akhir ke /login',
      (tester) async {
    final storage = await pumpApp(tester, onboardingSeen: false);
    final next = find.byKey(const Key('onboarding-next'));

    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.text('Semua penggunanya mahasiswa terverifikasi.'),
        findsOneWidget);

    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.text('Mulai'), findsOneWidget);
    expect(storage.onboardingSeen, isFalse);

    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(storage.onboardingSeen, isTrue);
  });

  testWidgets('Sesi tersimpan langsung ke Beranda; Keluar menghapus sesi',
      (tester) async {
    final storage = await pumpApp(tester, sessionUserId: 'usr-001');
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Halo, Gregorian'), findsOneWidget);

    await logoutViaProfil(tester);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(storage.sessionUserId, isNull);
  });

  testWidgets('Tanpa sesi setelah onboarding → Login', (tester) async {
    await pumpApp(tester);
    expect(find.byType(LoginPage), findsOneWidget);
  });
}

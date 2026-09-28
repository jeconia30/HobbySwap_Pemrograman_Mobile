import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hobby_swab/app.dart';
import 'package:hobby_swab/core/router/app_router.dart';
import 'package:hobby_swab/core/storage/session_storage.dart';
import 'package:hobby_swab/core/theme/app_spacing.dart';
import 'package:hobby_swab/core/utils/clock.dart';
import 'package:hobby_swab/core/utils/dates.dart';
import 'package:hobby_swab/features/handover/data/checklist_providers.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "Hari ini" tetap untuk semua test: Senin, 5 Oktober 2026.
final testToday = DateTime(2026, 10, 5);

/// Hari ini + [n] hari.
DateTime hPlus(int n) => addDays(testToday, n);

Future<SessionStorage> mockStorage([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
  return SessionStorage.create();
}

/// Menjalankan app penuh (mulai dari Splash) di layar ponsel 360×780,
/// lalu menunggu Splash selesai mengarahkan.
Future<SessionStorage> pumpApp(
  WidgetTester tester, {
  bool onboardingSeen = true,
  String? sessionUserId,
}) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await initializeDateFormatting(appLocale);
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final storage = await mockStorage({
    if (onboardingSeen) SessionStorage.onboardingSeenKey: true,
    SessionStorage.sessionUserIdKey: ?sessionUserId,
  });

  await tester.pumpWidget(ProviderScope(
    overrides: [
      sessionStorageProvider.overrideWithValue(storage),
      clockProvider.overrideWithValue(() => testToday),
      // Pihak lawan tidak menyetujui checklist otomatis di test.
      checklistAutoApproveDelayProvider.overrideWithValue(null),
    ],
    child: const HobbySwapApp(),
  ));
  await tester.pump(AppDurations.splashMinimum);
  await tester.pumpAndSettle();
  // Biarkan muatan awal layar tujuan (Beranda, badge pengajuan) selesai.
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
  return storage;
}

/// Menunggu repository palsu (jeda ≤ 900 ms, bisa berantai dua kali).
/// Dipompa bertahap: permintaan yang baru dimulai di tengah (mis. setelah
/// animasi tutup sheet) tetap kebagian waktu.
Future<void> waitRepo(WidgetTester tester) async {
  for (var i = 0; i < 25; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}

/// Container Riverpod milik app yang sedang berjalan.
ProviderContainer appContainer(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(HobbySwapApp)));

/// Membuka [location] seperti `context.push`, lalu menunggu muat selesai.
Future<void> pushRoute(WidgetTester tester, String location) async {
  appContainer(tester).read(appRouterProvider).push(location);
  await tester.pumpAndSettle();
}

/// Pindah ke tab bawah berdasarkan labelnya (Beranda/Sewaan/Barang/Profil).
Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

/// Keluar lewat tab Profil.
Future<void> logoutViaProfil(WidgetTester tester) async {
  await openTab(tester, 'Profil');
  final keluar = find.text('Keluar');
  await tester.ensureVisible(keluar);
  await tester.pumpAndSettle();
  await tester.tap(keluar);
  await tester.pumpAndSettle();
}

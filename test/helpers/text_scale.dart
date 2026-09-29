import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/router/app_router.dart';

import 'pump_app.dart';

/// Skala font sistem yang wajib aman (DESIGN §7).
const skalaTeksDiuji = [1.3, 2.0];

/// Menyetel ukuran font sistem untuk satu test (dikembalikan otomatis).
void setSkalaTeks(WidgetTester tester, double skala) {
  tester.platformDispatcher.textScaleFactorTestValue = skala;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// Pindah ke [location] seperti `context.go`, lalu tunggu repository palsu.
Future<void> goRoute(WidgetTester tester, String location) async {
  appContainer(tester).read(appRouterProvider).go(location);
  await tester.pumpAndSettle();
  await waitRepo(tester);
}

/// Menggulir setiap daftar vertikal yang terlihat sampai ujung, bertahap,
/// supaya item yang dibangun malas ikut di-layout (dan overflow-nya ketahuan).
Future<void> gulirSampaiBawah(WidgetTester tester) async {
  for (var putaran = 0; putaran < 2; putaran++) {
    final daftar = tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .where((s) => s.position.axis == Axis.vertical)
        .toList();
    for (final s in daftar) {
      var langkah = 0;
      while (s.mounted &&
          s.position.pixels < s.position.maxScrollExtent &&
          langkah++ < 40) {
        s.position.jumpTo(math.min(
          s.position.pixels + s.position.viewportDimension * 0.8,
          s.position.maxScrollExtent,
        ));
        await tester.pump();
      }
    }
  }
  await tester.pumpAndSettle();
}

/// Me-render layar pada [skala] lalu memastikan tidak ada overflow/exception.
/// [buka] membawa app ke layar yang diuji (app sudah di-pump oleh [pumpApp]).
Future<void> cekLayarTanpaOverflow(
  WidgetTester tester, {
  required double skala,
  String? sessionUserId,
  bool onboardingSeen = true,
  Future<void> Function(WidgetTester tester)? buka,
}) async {
  setSkalaTeks(tester, skala);
  await pumpApp(tester,
      sessionUserId: sessionUserId, onboardingSeen: onboardingSeen);
  if (buka != null) await buka(tester);
  await gulirSampaiBawah(tester);
  expect(tester.takeException(), isNull);
  // Biarkan timer (SnackBar, jeda repo) selesai sebelum test ditutup.
  await tester.pump(const Duration(seconds: 5));
}

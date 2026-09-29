import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/router/app_router.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/text_scale.dart';

const gregorian = 'usr-001';

void main() {
  Key hari(DateTime d) => Key('day-${d.year}-${d.month}-${d.day}');

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testWidgets('"Tawarkan barter" hanya untuk barang bisaBarter milik orang lain',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    final tombol = find.byKey(const Key('detail-tawar-barter'));

    // Sony A6400 (Rizky) menerima barter.
    await goRoute(tester, AppRoutes.barangDetail('itm-001'));
    expect(tombol, findsOneWidget);
    expect(find.byKey(const Key('detail-barter')), findsOneWidget);

    // Canon EOS M50 tidak menerima barter.
    await goRoute(tester, AppRoutes.barangDetail('itm-002'));
    expect(tombol, findsNothing);

    // Carrier Eiger menerima barter, tapi milik sendiri.
    await goRoute(tester, AppRoutes.barangDetail('itm-013'));
    expect(tombol, findsNothing);
  });

  testWidgets('label "Dicari pemilik" & langkah 3 menampilkan kedua barang',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    // Tenda Dome (Sarah) mencari kamera & game.
    await goRoute(tester, AppRoutes.tawarBarter('itm-004'));
    expect(find.text('Pilih barangmu'), findsWidgets);
    expect(find.byKey(const Key('dicari-itm-014')), findsOneWidget,
        reason: 'Switch OLED = game');
    expect(find.byKey(const Key('dicari-itm-013')), findsNothing,
        reason: 'Carrier = camping');

    await tap(tester, find.byKey(const Key('pilih-itm-014')));
    await tap(tester, find.byKey(const Key('barter-lanjut')));
    expect(find.byKey(const Key('barter-ket-tanggal')), findsOneWidget);

    await tap(tester, find.byKey(hari(hPlus(7))));
    await tap(tester, find.byKey(hari(hPlus(8))));
    await tap(tester, find.byKey(const Key('barter-lanjut')));

    final tinjau = find.byKey(const Key('barter-tinjau'));
    expect(tinjau, findsOneWidget);
    expect(find.descendant(of: tinjau, matching: find.text('Kamu pinjam')),
        findsOneWidget);
    expect(
        find.descendant(of: tinjau, matching: find.text('Kamu pinjamkan')),
        findsOneWidget);
    expect(
        find.descendant(
            of: tinjau, matching: find.textContaining('Tenda Dome')),
        findsOneWidget);
    expect(
        find.descendant(
            of: tinjau, matching: find.textContaining('Switch OLED')),
        findsOneWidget);
    expect(find.byKey(const Key('nilai-setara')), findsOneWidget);
  });
}

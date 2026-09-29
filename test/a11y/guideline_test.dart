import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import 'layar_utama.dart';

/// DESIGN §7: tap target ≥ 48×48 dan setiap elemen yang bisa ditekan
/// (termasuk tombol ikon) punya label untuk pembaca layar.
void main() {
  Future<void> cek(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  }

  testWidgets('Onboarding', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester, onboardingSeen: false);
    await cek(tester);
    semantics.dispose();
  });

  for (final (nama, sesi, buka) in layarUtama) {
    testWidgets(nama, (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester, sessionUserId: sesi);
      if (buka != null) await buka(tester);
      await cek(tester);
      semantics.dispose();
      await tester.pump(const Duration(seconds: 5));
    });
  }
}

import 'package:flutter_test/flutter_test.dart';

import '../helpers/text_scale.dart';
import 'layar_utama.dart';

void main() {
  for (final skala in skalaTeksDiuji) {
    group('Font sistem $skala×: tanpa overflow', () {
      testWidgets('Onboarding', (tester) async {
        await cekLayarTanpaOverflow(tester,
            skala: skala, onboardingSeen: false);
      });

      for (final (nama, sesi, buka) in layarUtama) {
        testWidgets(nama, (tester) async {
          await cekLayarTanpaOverflow(tester,
              skala: skala, sessionUserId: sesi, buka: buka);
        });
      }
    });
  }
}

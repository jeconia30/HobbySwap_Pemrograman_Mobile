import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/router/app_routes.dart';
import 'package:hobby_swab/core/widgets/app_text_field.dart';

import '../helpers/pump_app.dart';
import '../helpers/text_scale.dart';

/// Tombol "Lanjut" di keyboard memindahkan fokus ke field berikutnya sesuai
/// urutan baca form.
void main() {
  Finder field(String label) => find.descendant(
        of: find.widgetWithText(AppTextField, label),
        matching: find.byType(EditableText),
      );

  bool fokus(WidgetTester tester, String label) =>
      tester.widget<EditableText>(field(label)).focusNode.hasFocus;

  Future<void> cekUrutan(WidgetTester tester, List<String> urutan) async {
    await tester.ensureVisible(field(urutan.first));
    await tester.pumpAndSettle();
    await tester.tap(field(urutan.first));
    await tester.pumpAndSettle();
    expect(fokus(tester, urutan.first), isTrue);
    for (final label in urutan.skip(1)) {
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      expect(fokus(tester, label), isTrue, reason: 'fokus harus di "$label"');
    }
  }

  testWidgets('Login: email/NIM → password', (tester) async {
    await pumpApp(tester);
    await cekUrutan(tester, ['Email kampus / NIM', 'Password']);
  });

  testWidgets('Daftar: nama → NIM → email → password', (tester) async {
    await pumpApp(tester);
    await goRoute(tester, AppRoutes.daftar);
    await cekUrutan(
        tester, ['Nama lengkap', 'NIM', 'Email kampus', 'Password']);
  });

  testWidgets('Tambah barang: nama → harga → denda → lokasi → deskripsi',
      (tester) async {
    await pumpApp(tester, sessionUserId: 'usr-001');
    await goRoute(tester, AppRoutes.barangTambah);
    await cekUrutan(tester,
        [
          'Nama barang',
          'Harga sewa per hari',
          'Denda telat per hari',
          'Lokasi ambil',
          'Deskripsi',
        ]);
  });
}

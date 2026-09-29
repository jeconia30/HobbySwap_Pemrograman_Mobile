import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/router/app_routes.dart';
import 'package:hobby_swab/core/widgets/app_button.dart';
import 'package:hobby_swab/data/fake/fake_notification_store.dart';
import 'package:hobby_swab/features/activity/presentation/aktivitas_page.dart';
import 'package:hobby_swab/features/profile/presentation/edit_profil_page.dart';
import 'package:hobby_swab/features/profile/presentation/profil_page.dart';

import '../../helpers/pump_app.dart';

const gregorian = 'usr-001';

void main() {
  Future<void> bukaProfil(WidgetTester tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await openTab(tester, 'Profil');
    expect(find.byType(ProfilPage), findsOneWidget);
  }

  Future<void> bukaEditProfil(WidgetTester tester) async {
    await bukaProfil(tester);
    final menu = find.byKey(const Key('menu-edit-profil'));
    await scrollProfilTo(tester, menu);
    await tester.tap(menu);
    await tester.pumpAndSettle();
    expect(find.byType(EditProfilPage), findsOneWidget);
  }

  bool simpanAktif(WidgetTester tester) =>
      tester.widget<AppButton>(find.byKey(const Key('edit-simpan'))).onPressed !=
      null;

  testWidgets('memilih Gelap langsung mengganti tema', (tester) async {
    await bukaProfil(tester);
    Brightness kecerahan() =>
        Theme.of(tester.element(find.byType(ProfilPage))).brightness;
    expect(kecerahan(), Brightness.light);

    final menu = find.byKey(const Key('menu-tema'));
    await scrollProfilTo(tester, menu);
    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tema-dark')));
    await tester.pumpAndSettle();

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark);
    expect(kecerahan(), Brightness.dark);
  });

  testWidgets('Simpan nonaktif selama belum ada perubahan', (tester) async {
    await bukaEditProfil(tester);
    expect(simpanAktif(tester), isFalse);

    await tester.enterText(find.byKey(const Key('edit-nama')), 'Gregorian S');
    await tester.pump();
    expect(simpanAktif(tester), isTrue);

    // Kembali ke nilai awal → tidak dianggap berubah lagi.
    await tester.enterText(find.byKey(const Key('edit-nama')), 'Gregorian');
    await tester.pump();
    expect(simpanAktif(tester), isFalse);
  });

  testWidgets('Simpan di Edit profil memperbarui nama di Profil',
      (tester) async {
    await bukaEditProfil(tester);
    await tester.enterText(
        find.byKey(const Key('edit-nama')), 'Gregorian Sinaga');
    await tester.pump();
    await tester.tap(find.byKey(const Key('edit-simpan')));
    await waitRepo(tester);

    expect(find.text('Profil diperbarui'), findsOneWidget);
    expect(find.byType(EditProfilPage), findsNothing);
    final nama = find.byKey(const Key('profil-nama'));
    await scrollProfilTo(tester, nama, delta: -200);
    expect(tester.widget<Text>(nama).data, 'Gregorian Sinaga');
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('geser untuk hapus, lalu Urungkan mengembalikan notifikasi',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await pushRoute(tester, AppRoutes.aktivitas);
    await waitRepo(tester);
    expect(find.byType(AktivitasPage), findsOneWidget);

    const id = 'ntf-contoh-1';
    final row = find.byKey(const Key('notif-row-$id'));
    expect(row, findsOneWidget);
    final store = appContainer(tester).read(fakeNotificationStoreProvider);
    final jumlahAwal = store.all.length;

    await tester.drag(row, const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(row, findsNothing);
    expect(find.text('Dihapus'), findsOneWidget);
    expect(store.all.length, jumlahAwal - 1);

    await tester.tap(find.text('Urungkan'));
    await waitRepo(tester);
    expect(find.byKey(const Key('notif-row-$id')), findsOneWidget);
    expect(store.all.length, jumlahAwal);
  });
}

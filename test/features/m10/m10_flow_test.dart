import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/router/app_router.dart';
import 'package:hobby_swab/core/widgets/app_button.dart';
import 'package:hobby_swab/data/fake/fake_booking_store.dart';
import 'package:hobby_swab/features/booking/data/booking_providers.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/text_scale.dart';

const email = 'gregorian@students.usu.ac.id';
const gregorian = 'usr-001';

void main() {
  AppButton tombol(WidgetTester tester, String key) =>
      tester.widget<AppButton>(find.byKey(Key(key)));

  testWidgets('Kirim ulang nonaktif selama hitung mundur 60 detik',
      (tester) async {
    await pumpApp(tester);
    // Tanpa waitRepo supaya hitung mundur belum berjalan.
    appContainer(tester).read(appRouterProvider).go(AppRoutes.cekEmail(email));
    await tester.pumpAndSettle();
    expect(find.text('Cek email kampusmu'), findsOneWidget);
    expect(tombol(tester, 'kirim-ulang').onPressed, isNull);
    expect(find.text('Kirim ulang (1:00)'), findsOneWidget);

    await tester.pump(const Duration(seconds: 30));
    expect(tombol(tester, 'kirim-ulang').onPressed, isNull);
    expect(find.text('Kirim ulang (0:30)'), findsOneWidget);

    await tester.pump(const Duration(seconds: 31));
    expect(tombol(tester, 'kirim-ulang').onPressed, isNotNull);
    expect(find.text('Kirim ulang'), findsOneWidget);

    // Buka tautan simulasi → form password baru.
    await tester.tap(find.byKey(const Key('buka-tautan-reset')));
    await tester.pumpAndSettle();
    expect(find.text('Buat password baru'), findsOneWidget);
  });

  testWidgets('Indikator kekuatan password: Lemah, Sedang, Kuat',
      (tester) async {
    await pumpApp(tester);
    await goRoute(tester, AppRoutes.resetPasswordUntuk(email));
    String label() =>
        tester.widget<Text>(find.byKey(const Key('kekuatan-label'))).data!;
    final field = find.byKey(const Key('reset-baru'));

    expect(label(), '');
    await tester.enterText(field, 'abc');
    await tester.pump();
    expect(label(), 'Lemah');
    await tester.enterText(field, 'hobby2026');
    await tester.pump();
    expect(label(), 'Sedang');
    await tester.enterText(field, 'Hobby2026!');
    await tester.pump();
    expect(label(), 'Kuat');

    // Simpan → sukses → Login dengan email terisi.
    await tester.enterText(find.byKey(const Key('reset-ulang')), 'Hobby2026!');
    await tester.tap(find.byKey(const Key('reset-simpan')));
    await waitRepo(tester);
    expect(find.text('Password berhasil diganti'), findsOneWidget);
    await tester.tap(find.byKey(const Key('reset-ke-login')));
    await tester.pumpAndSettle();
    expect(find.text(email), findsOneWidget);
  });

  testWidgets('Sheet pembatalan: peringatan hanya di hari H', (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await openTab(tester, 'Sewaan');
    await waitRepo(tester);

    Future<void> bukaSheet() async {
      final batal = find.byKey(const Key('batalkan-sewa-bkg-022'));
      await tester.scrollUntilVisible(batal, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      await tester.tap(batal);
      await tester.pumpAndSettle();
      expect(find.text('Batalkan sewa?'), findsOneWidget);
    }

    // GoPro mulai besok (H-1): bebas, tanpa peringatan.
    await bukaSheet();
    expect(find.byKey(const Key('peringatan-hari-h')), findsNothing);
    await tester.tap(find.text('Tidak jadi'));
    await tester.pumpAndSettle();

    // Jadikan mulai hari ini → peringatan pembatalan mendadak.
    final container = appContainer(tester);
    final store = container.read(fakeBookingStoreProvider);
    store.update(store
        .byId('bkg-022')!
        .copyWith(tanggalMulai: testToday, tanggalKembali: hPlus(1)));
    container.invalidate(myBookingsProvider);
    await waitRepo(tester);
    await bukaSheet();
    expect(find.byKey(const Key('peringatan-hari-h')), findsOneWidget);
    expect(
        find.textContaining('tercatat di profilmu sebagai pembatalan mendadak'),
        findsOneWidget);

    // Alasan wajib, lalu batalkan.
    final konfirmasi = find.byKey(const Key('batal-sewa-konfirmasi'));
    await tester.ensureVisible(konfirmasi);
    await tester.pumpAndSettle();
    await tester.tap(konfirmasi);
    await tester.pumpAndSettle();
    expect(find.text('Pilih alasannya dulu, ya.'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('alasan-batal-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('alasan-batal-0')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(konfirmasi);
    await tester.pumpAndSettle();
    await tester.tap(konfirmasi);
    await waitRepo(tester);
    expect(find.text('Sewa dibatalkan.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });
}

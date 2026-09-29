import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/router/app_routes.dart';
import 'package:hobby_swab/core/widgets/app_button.dart';
import 'package:hobby_swab/data/fake/fake_account_store.dart';
import 'package:hobby_swab/features/auth/domain/user.dart';
import 'package:hobby_swab/features/auth/presentation/auth_controller.dart';
import 'package:hobby_swab/features/booking/presentation/konfirmasi_sewa_page.dart';
import 'package:hobby_swab/features/booking/presentation/pengajuan_terkirim_page.dart';
import 'package:hobby_swab/features/booking/presentation/sewaan_page.dart';
import 'package:hobby_swab/features/item/presentation/item_detail_page.dart';

import '../../helpers/pump_app.dart';

const gregorian = 'usr-001';
const aulia = 'usr-002';
const sony = 'itm-001'; // Rizky, Rp45.000, blokir h+2..h+3 & h+9..h+10

Finder dayCell(DateTime x) => find.byKey(Key('day-${x.year}-${x.month}-${x.day}'));

void main() {
  Future<void> openSony(WidgetTester tester) =>
      pushRoute(tester, AppRoutes.barangDetail(sony));

  Future<void> tapDay(WidgetTester tester, DateTime x) async {
    await tester.ensureVisible(dayCell(x));
    await tester.pumpAndSettle();
    await tester.tap(dayCell(x));
    await tester.pumpAndSettle();
  }

  AppButton button(WidgetTester tester, String label) =>
      tester.widget<AppButton>(find.widgetWithText(AppButton, label));

  testWidgets('Detail menampilkan info barang, pemilik, dan harga',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await openSony(tester);

    expect(find.byType(ItemDetailPage), findsOneWidget);
    expect(find.text('KAMERA'), findsOneWidget);
    expect(find.text('Sony A6400 + Lensa Kit 16–50mm'), findsOneWidget);
    expect(find.text('Disewa 58×'), findsOneWidget);
    expect(find.text('Rizky Nugraha'), findsOneWidget);
    expect(find.text('Terverifikasi'), findsOneWidget);
    expect(find.text('Teknik · biasa balas < 1 jam'), findsOneWidget);
    expect(find.text('Pilih tanggal'), findsOneWidget);
    expect(find.textContaining('Rp45.000', findRichText: true), findsWidgets);
  });

  testWidgets('Memilih 2 tanggal memperbarui ringkasan di bar bawah',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await openSony(tester);

    await tapDay(tester, hPlus(5));
    expect(find.byKey(const Key('detail-summary')), findsNothing);
    await tapDay(tester, hPlus(7));

    expect(find.text('3 hari × Rp45.000'), findsOneWidget);
    expect(find.text('Rp135.000'), findsOneWidget);
    expect(find.text('Ajukan Sewa'), findsOneWidget);
  });

  testWidgets('Tanggal terblokir tidak bisa dipilih', (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await openSony(tester);

    await tapDay(tester, hPlus(2));
    await tapDay(tester, hPlus(3));
    expect(find.byKey(const Key('detail-summary')), findsNothing);
    expect(find.text('Pilih tanggal'), findsOneWidget);
  });

  testWidgets('Rentang melewati tanggal terblokir memunculkan pesan',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await openSony(tester);

    await tapDay(tester, hPlus(5));
    await tapDay(tester, hPlus(11));
    expect(find.text('Rentang ini melewati tanggal yang sudah disewa'),
        findsOneWidget);
    expect(find.byKey(const Key('detail-summary')), findsNothing);
  });

  testWidgets('"Pilih tanggal" menggulir ke kalender', (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await openSony(tester);
    expect(dayCell(hPlus(5)).hitTestable(), findsNothing);

    await tester.tap(find.text('Pilih tanggal'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih tanggal · Oktober').hitTestable(), findsOneWidget);
  });

  testWidgets('Barang milik sendiri: tombol "Ini barangmu" nonaktif',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await pushRoute(tester, AppRoutes.barangDetail('itm-013'));
    expect(button(tester, 'Ini barangmu').onPressed, isNull);
  });

  testWidgets('Barang tidak ditemukan', (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await pushRoute(tester, AppRoutes.barangDetail('itm-999'));
    expect(find.text('Barang ini sudah tidak tersedia'), findsOneWidget);
    expect(find.text('Ke Beranda'), findsOneWidget);
  });

  testWidgets('"Ajukan Sewa" dengan akun menunggu → sheet requireVerified',
      (tester) async {
    await pumpApp(tester, sessionUserId: aulia);
    final container = appContainer(tester);
    final store = container.read(fakeAccountStoreProvider);
    store.updateUser(store
        .byId(aulia)!
        .user
        .copyWith(statusVerifikasi: StatusVerifikasi.menunggu));
    container.read(authControllerProvider.notifier).refresh();

    await openSony(tester);
    await tapDay(tester, hPlus(5));
    await tapDay(tester, hPlus(6));
    await tester.tap(find.text('Ajukan Sewa'));
    await tester.pumpAndSettle();

    expect(find.text('KTM-mu masih ditinjau'), findsOneWidget);
    expect(find.byType(KonfirmasiSewaPage), findsNothing);
  });

  testWidgets('Deep link konfirmasi oleh akun belum verifikasi → ke detail',
      (tester) async {
    await pumpApp(tester, sessionUserId: aulia);
    await pushRoute(tester, AppRoutes.ajukanSewa(sony, hPlus(5), hPlus(6)));
    expect(find.byType(KonfirmasiSewaPage), findsNothing);
    expect(find.byType(ItemDetailPage), findsOneWidget);
  });

  testWidgets('Alur lengkap: pilih tanggal → konfirmasi → terkirim → Sewaan',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await openSony(tester);
    await tapDay(tester, hPlus(5));
    await tapDay(tester, hPlus(7));
    await tester.tap(find.text('Ajukan Sewa'));
    await tester.pumpAndSettle();

    expect(find.byType(KonfirmasiSewaPage), findsOneWidget);
    expect(find.text('Konfirmasi sewa'), findsOneWidget);
    expect(find.text('Sab, 10 Okt'), findsOneWidget);
    expect(find.text('Sen, 12 Okt'), findsOneWidget);
    expect(find.text('Sewa 3 hari × Rp45.000'), findsOneWidget);
    expect(find.text('Pemilik: Rizky Nugraha'), findsOneWidget);

    final kirim = find.byKey(const Key('konfirmasi-kirim'));
    await tester.tap(kirim);
    await tester.pumpAndSettle();
    expect(find.text('Centang dulu, ya.'), findsOneWidget);

    await tester.enterText(
        find.descendant(
            of: find.byKey(const Key('konfirmasi-pesan')),
            matching: find.byType(EditableText)),
        'Buat liputan acara himpunan');
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(kirim);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.byType(PengajuanTerkirimPage), findsOneWidget);
    expect(find.text('Pengajuan terkirim!'), findsOneWidget);
    expect(find.textContaining('Rizky Nugraha biasanya membalas'),
        findsOneWidget);
    expect(find.text('Menunggu'), findsOneWidget);
    expect(find.text('Rp135.000'), findsOneWidget);

    await tester.tap(find.text('Lihat Sewaan Saya'));
    await tester.pumpAndSettle();
    expect(find.byType(SewaanPage), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Error dari repository tampil di kotak error konfirmasi',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    // Deep link dengan rentang yang menabrak blokir pemilik (h+2..h+3).
    await pushRoute(tester, AppRoutes.ajukanSewa(sony, hPlus(1), hPlus(3)));
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.byKey(const Key('konfirmasi-kirim')));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(
        find.text(
            'Ada tanggal yang sudah disewa orang lain. Pilih tanggal lain, ya.'),
        findsOneWidget);
    expect(find.byType(KonfirmasiSewaPage), findsOneWidget);
  });

  testWidgets('Font sistem besar (2×): detail & konfirmasi tidak overflow',
      (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpApp(tester, sessionUserId: gregorian);
    await openSony(tester);
    await tapDay(tester, hPlus(5));
    await tapDay(tester, hPlus(7));
    await tester.tap(find.text('Ajukan Sewa'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

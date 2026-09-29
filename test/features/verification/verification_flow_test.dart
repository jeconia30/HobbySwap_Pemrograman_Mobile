import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/router/app_routes.dart';
import 'package:hobby_swab/core/widgets/app_button.dart';
import 'package:hobby_swab/features/home/presentation/home_page.dart';
import 'package:hobby_swab/features/item/presentation/item_form_page.dart';
import 'package:hobby_swab/features/verification/presentation/verifikasi_page.dart';
import 'package:hobby_swab/features/verification/presentation/verifikasi_status_page.dart';

import '../../helpers/pump_app.dart';

const aulia = 'usr-002';
const gregorian = 'usr-001';

void main() {
  final submitKey = find.byKey(const Key('verification-submit'));
  final fab = find.byKey(const Key('nav-fab'));

  bool submitEnabled(WidgetTester tester) =>
      tester.widget<AppButton>(submitKey).onPressed != null;

  Future<void> fillSlot(WidgetTester tester, String slotKey,
      {String option = 'Ambil foto'}) async {
    final slot = find.byKey(Key(slotKey));
    await tester.ensureVisible(slot);
    await tester.pumpAndSettle();
    await tester.tap(slot);
    await tester.pumpAndSettle();
    await tester.tap(find.text(option));
    await tester.pumpAndSettle();
  }

  Future<void> submitVerification(WidgetTester tester) async {
    await fillSlot(tester, 'slot-ktm');
    await fillSlot(tester, 'slot-selfie', option: 'Pilih dari galeri');
    await tester.tap(submitKey);
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
  }

  Future<void> openBerandaFromVerification(WidgetTester tester) async {
    final link = find.widgetWithText(TextButton, 'jelajah barang dulu');
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  }

  testWidgets('Sesi user berstatus belum dibuka langsung ke /verifikasi',
      (tester) async {
    await pumpApp(tester, sessionUserId: aulia);
    expect(find.byType(VerifikasiPage), findsOneWidget);
    expect(find.textContaining('Aulia Putri · 220402011', findRichText: true),
        findsOneWidget);
  });

  testWidgets('"Kirim untuk ditinjau" nonaktif sampai dua slot terisi',
      (tester) async {
    await pumpApp(tester, sessionUserId: aulia);
    expect(submitEnabled(tester), isFalse);
    expect(find.text('Lengkapi foto KTM dan selfie dulu, atau'), findsOneWidget);

    await fillSlot(tester, 'slot-ktm');
    expect(find.text('Foto KTM'), findsOneWidget);
    expect(submitEnabled(tester), isFalse);

    await fillSlot(tester, 'slot-selfie', option: 'Pilih dari galeri');
    expect(submitEnabled(tester), isTrue);
    expect(find.text('Lengkapi foto KTM dan selfie dulu, atau'), findsNothing);

    // Menghapus salah satu foto menonaktifkan tombol lagi.
    await tester.tap(find.bySemanticsLabel('Ganti Foto KTM'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus foto'));
    await tester.pumpAndSettle();
    expect(submitEnabled(tester), isFalse);
  });

  testWidgets('Kirim → status ditinjau → disetujui (debug) → Mulai jelajah',
      (tester) async {
    await pumpApp(tester, sessionUserId: aulia);
    await submitVerification(tester);

    expect(find.byType(VerifikasiStatusPage), findsOneWidget);
    expect(find.text('KTM-mu sedang ditinjau'), findsOneWidget);
    expect(find.text('Jelajah barang dulu'), findsOneWidget);

    // Persetujuan simulasi ada di Profil → Alat pengembang.
    await tester.tap(find.text('Jelajah barang dulu'));
    await tester.pumpAndSettle();
    await openTab(tester, 'Profil');
    final approve = find.byKey(const Key('debug-setujui-ktm'));
    await scrollProfilTo(tester, approve);
    await tester.tap(approve);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('debug-setujui-ktm')), findsNothing);
    // Tunggu SnackBar konfirmasi hilang supaya tidak menutupi tombol.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await pushRoute(tester, AppRoutes.verifikasiStatus);
    expect(find.text('Akunmu sudah aktif!'), findsOneWidget);

    await tester.tap(find.text('Mulai jelajah'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byKey(const Key('verification-banner')), findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });

  group('requireVerified', () {
    testWidgets('status belum: sheet "Verifikasi KTM dulu, ya" → /verifikasi',
        (tester) async {
      await pumpApp(tester, sessionUserId: aulia);
      await openBerandaFromVerification(tester);
      expect(find.byKey(const Key('verification-banner')), findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();
      expect(find.text('Verifikasi KTM dulu, ya'), findsOneWidget);

      await tester.tap(find.text('Verifikasi sekarang').last);
      await tester.pumpAndSettle();
      expect(find.byType(VerifikasiPage), findsOneWidget);
    });

    testWidgets('status menunggu: sheet "KTM-mu masih ditinjau" → status',
        (tester) async {
      await pumpApp(tester, sessionUserId: aulia);
      await submitVerification(tester);
      await tester.tap(find.text('Jelajah barang dulu'));
      await tester.pumpAndSettle();

      await tester.tap(fab);
      await tester.pumpAndSettle();
      expect(find.text('KTM-mu masih ditinjau'), findsOneWidget);
      expect(find.textContaining('Biasanya kurang dari 1×24 jam'),
          findsWidgets);

      await tester.tap(find.widgetWithText(AppButton, 'Lihat status'));
      await tester.pumpAndSettle();
      expect(find.byType(VerifikasiStatusPage), findsOneWidget);
    });

    testWidgets('"Nanti saja" menutup sheet tanpa pindah halaman',
        (tester) async {
      await pumpApp(tester, sessionUserId: aulia);
      await openBerandaFromVerification(tester);
      await tester.tap(fab);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nanti saja'));
      await tester.pumpAndSettle();
      expect(find.text('Verifikasi KTM dulu, ya'), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('status terverifikasi: aksi langsung dijalankan',
        (tester) async {
      await pumpApp(tester, sessionUserId: gregorian);
      await tester.tap(fab);
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(ItemFormPage), findsOneWidget);
    });
  });
}

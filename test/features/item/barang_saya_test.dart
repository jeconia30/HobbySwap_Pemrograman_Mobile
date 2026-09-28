import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/router/app_router.dart';
import 'package:hobby_swab/core/widgets/app_button.dart';
import 'package:hobby_swab/data/fake/fake_item_store.dart';
import 'package:hobby_swab/features/booking/presentation/pengajuan_masuk_page.dart';
import 'package:hobby_swab/features/home/presentation/home_controller.dart';
import 'package:hobby_swab/features/item/data/item_providers.dart';
import 'package:hobby_swab/features/item/domain/item.dart';
import 'package:hobby_swab/features/item/presentation/barang_saya_page.dart';
import 'package:hobby_swab/features/item/presentation/item_form_page.dart';

import '../../helpers/pump_app.dart';

const gregorian = 'usr-001';

void main() {
  Finder row(String id) => find.byKey(Key('item-row-$id'));

  Future<void> openBarang(WidgetTester tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await openTab(tester, 'Barang');
    await waitRepo(tester);
    expect(find.byType(BarangSayaPage), findsOneWidget);
  }

  /// Gulir sampai [f] terbangun & terlihat (daftar dibangun malas), lalu tap.
  Future<void> tapVisible(WidgetTester tester, Finder f) async {
    if (f.evaluate().isEmpty) {
      await tester.scrollUntilVisible(f, 200,
          scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testWidgets('Statistik, kartu pengajuan, daftar barang & chip status',
      (tester) async {
    await openBarang(tester);

    expect(find.text('Oktober'), findsOneWidget);
    expect(find.text('Rp320rb'), findsOneWidget);
    expect(find.text('12×'), findsOneWidget);
    expect(find.textContaining('4.8', findRichText: true), findsWidgets);
    expect(find.text('Pengajuan baru menunggu'), findsOneWidget);
    expect(find.text('Aulia Putri dan 2 lainnya ingin menyewa barangmu'),
        findsOneWidget);
    expect(find.text('Barangmu · 4'), findsOneWidget);

    await tester.ensureVisible(row('itm-016'));
    await tester.pumpAndSettle();
    expect(
        find.descendant(of: row('itm-014'), matching: find.text('Disewa')),
        findsOneWidget);
    expect(
        find.descendant(
            of: row('itm-014'),
            matching: find.textContaining('kembali Rab, 7 Okt')),
        findsOneWidget);
    expect(
        find.descendant(of: row('itm-016'), matching: find.text('Nonaktif')),
        findsOneWidget);
    expect(
        find.descendant(of: row('itm-013'), matching: find.text('Tersedia')),
        findsOneWidget);
  });

  testWidgets('Badge tab Barang menampilkan jumlah pengajuan menunggu',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Barang, 3 baru'), findsOneWidget);
  });

  testWidgets('Terima Aulia → Sarah otomatis ditolak; tolak Dimas pakai alasan',
      (tester) async {
    await openBarang(tester);
    await tester.tap(find.byKey(const Key('pending-card')));
    await tester.pumpAndSettle();
    expect(find.byType(PengajuanMasukPage), findsOneWidget);
    expect(find.text('Menunggu (3)'), findsOneWidget);
    expect(find.textContaining('Buat pendakian Sibayak'), findsOneWidget);

    await tapVisible(tester, find.byKey(const Key('terima-bkg-005')));
    expect(find.text('1 pengajuan lain di tanggal yang sama akan otomatis '
        'ditolak.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('terima-konfirmasi')));
    await waitRepo(tester);
    expect(find.text('Pengajuan diterima. 1 pengajuan lain otomatis ditolak.'),
        findsOneWidget);
    expect(find.text('Menunggu (1)'), findsOneWidget);

    await tapVisible(tester, find.byKey(const Key('tolak-bkg-006')));
    await tester.tap(find.byKey(const Key('tolak-konfirmasi')));
    await tester.pump();
    expect(find.text('Pilih atau tulis alasannya dulu, ya.'), findsOneWidget);
    await tester.tap(find.text('Barangnya lagi dipakai'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('tolak-konfirmasi')));
    await waitRepo(tester);
    expect(find.text('Menunggu (0)'), findsOneWidget);
    expect(find.text('Belum ada pengajuan masuk.'), findsOneWidget);

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Alasan: Barangnya lagi dipakai'), findsOneWidget);
    expect(find.text('Alasan: Tanggal sudah diambil penyewa lain'),
        findsOneWidget);
    expect(find.text('Disetujui'), findsWidgets);

    await tester.tap(find.byTooltip('Kembali'));
    await waitRepo(tester);
    expect(find.text('Pengajuan baru menunggu'), findsNothing);
    expect(find.bySemanticsLabel(RegExp(r'^Barang, \d+ baru$')), findsNothing);
  });

  testWidgets('Hapus: ditolak kalau ada sewa aktif, berhasil kalau tidak',
      (tester) async {
    await openBarang(tester);

    await tapVisible(tester, row('itm-013'));
    await tester.tap(find.text('Hapus barang'));
    await tester.pumpAndSettle();
    expect(find.text('Hapus Carrier Eiger Rhinos 45L?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('hapus-konfirmasi')));
    await waitRepo(tester);
    expect(find.text('Masih ada sewa aktif untuk barang ini'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tapVisible(tester, row('itm-016'));
    await tester.tap(find.text('Hapus barang'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hapus-konfirmasi')));
    await waitRepo(tester);
    expect(find.text('Barang dihapus.'), findsOneWidget);
    expect(find.text('Barangmu · 3'), findsOneWidget);
    expect(row('itm-016'), findsNothing);
  });

  testWidgets('Aktifkan lagi barang nonaktif', (tester) async {
    await openBarang(tester);
    await tapVisible(tester, row('itm-016'));
    await tester.tap(find.text('Aktifkan lagi'));
    await waitRepo(tester);
    expect(find.text('Barang aktif lagi.'), findsOneWidget);
    await tester.ensureVisible(row('itm-016'));
    await tester.pumpAndSettle();
    expect(
        find.descendant(of: row('itm-016'), matching: find.text('Tersedia')),
        findsOneWidget);
  });

  testWidgets('Tambah barang: validasi lalu pasang, muncul di daftar',
      (tester) async {
    await openBarang(tester);
    await tester.tap(find.byKey(const Key('barang-saya-tambah')));
    await tester.pumpAndSettle();
    expect(find.byType(ItemFormPage), findsOneWidget);
    expect(find.text('Sewakan barang'), findsOneWidget);

    final simpan = find.byKey(const Key('form-barang-simpan'));
    await tester.tap(simpan);
    await tester.pumpAndSettle();
    expect(find.text('Isi nama barangnya dulu'), findsOneWidget);
    expect(find.text('Pilih kategori dulu'), findsOneWidget);
    expect(find.text('Isi harga sewa per hari'), findsOneWidget);

    Finder field(String key) => find.descendant(
        of: find.byKey(Key(key)), matching: find.byType(EditableText));
    await tester.enterText(field('form-barang-judul'), 'Drone DJI Mini 2');
    await tester.tap(find.byKey(const Key('form-kategori-kamera')));
    await tester.enterText(field('form-barang-harga'), '3000');
    await tester.enterText(field('form-barang-deskripsi'),
        'Termasuk 3 baterai, remote, dan tas. Kondisi mulus.');
    await tester.tap(simpan);
    await tester.pumpAndSettle();
    expect(find.text('Minimal Rp5.000 per hari'), findsOneWidget);

    await tester.enterText(field('form-barang-harga'), '60000');
    await tester.tap(simpan);
    await waitRepo(tester);

    expect(find.byType(BarangSayaPage), findsOneWidget);
    expect(find.text('Barangmu sudah tayang di HobbySwap!'), findsOneWidget);
    expect(find.text('Barangmu · 5'), findsOneWidget);
    expect(find.text('Drone DJI Mini 2'), findsOneWidget);
  });

  testWidgets('Ubah barang: form terisi, simpan memperbarui harga',
      (tester) async {
    await openBarang(tester);
    await tapVisible(tester, row('itm-015'));
    await tester.tap(find.text('Ubah barang'));
    await waitRepo(tester);

    expect(find.byType(ItemFormPage), findsOneWidget);
    expect(find.text('Ubah barang'), findsOneWidget);
    final judul = find.descendant(
        of: find.byKey(const Key('form-barang-judul')),
        matching: find.byType(EditableText));
    expect(tester.widget<EditableText>(judul).controller.text,
        'Raket Yonex Astrox 88');
    final harga = find.descendant(
        of: find.byKey(const Key('form-barang-harga')),
        matching: find.byType(EditableText));
    expect(tester.widget<EditableText>(harga).controller.text, '15000');

    await tester.enterText(harga, '18000');
    await tester.tap(find.byKey(const Key('form-barang-simpan')));
    await waitRepo(tester);

    expect(find.text('Perubahan disimpan.'), findsOneWidget);
    expect(find.textContaining('Rp18.000/hari'), findsOneWidget);
  });

  testWidgets('State kosong saat belum punya barang', (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    final container = appContainer(tester);
    final store = container.read(fakeItemStoreProvider);
    for (final id in ['itm-013', 'itm-014', 'itm-015', 'itm-016']) {
      store.remove(id);
    }
    container.invalidate(myItemsProvider);
    await openTab(tester, 'Barang');
    await waitRepo(tester);

    expect(find.text('Belum ada barang.'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Sewakan barang'), findsOneWidget);
  });

  testWidgets('Beranda: Sepatu tetap "Sedang disewa", Hammock tidak tampil',
      (tester) async {
    await pumpApp(tester, sessionUserId: 'usr-003');
    final shown = appContainer(tester).read(homeItemsProvider).requireValue;
    expect(shown.map((l) => l.item.id), isNot(contains('itm-016')));
    expect(shown.firstWhere((l) => l.item.id == 'itm-008').status,
        ItemStatus.disewa);
  });

  testWidgets('Font sistem besar (2×): Barang Saya, pengajuan, form',
      (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await openBarang(tester);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.byKey(const Key('pending-card')));
    await waitRepo(tester);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    appContainer(tester).read(appRouterProvider).pop();
    await waitRepo(tester);

    await tapVisible(tester, find.byKey(const Key('barang-saya-tambah')));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

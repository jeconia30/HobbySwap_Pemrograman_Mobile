import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/widgets/item_card.dart';
import 'package:hobby_swab/features/booking/presentation/sewaan_page.dart';
import 'package:hobby_swab/features/home/presentation/home_controller.dart';
import 'package:hobby_swab/features/home/presentation/home_page.dart';
import 'package:hobby_swab/features/item/domain/item.dart';
import 'package:hobby_swab/features/item/data/fake_item_repository.dart';
import 'package:hobby_swab/features/item/data/item_providers.dart';
import 'package:hobby_swab/features/item/domain/kategori.dart';
import 'package:hobby_swab/features/item/presentation/item_detail_page.dart';

import '../../helpers/pump_app.dart';

const gregorian = 'usr-001';

void main() {
  /// Kartu yang sedang terbangun (SliverList lazy: hanya yang dekat layar).
  List<ItemCard> cards(WidgetTester tester) =>
      tester.widgetList<ItemCard>(find.byType(ItemCard)).toList();

  /// Semua barang hasil filter yang sedang ditampilkan Beranda.
  List<ItemListing> shown(WidgetTester tester) => ProviderScope.containerOf(
          tester.element(find.byType(HomePage)))
      .read(homeItemsProvider)
      .requireValue;

  Future<void> typeSearch(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(const Key('home-search')), text);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  testWidgets('Beranda: header, bagian Populer & Baru, tanpa barang sendiri',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Halo, Gregorian'), findsOneWidget);
    expect(find.text('Kampus USU · Medan'), findsOneWidget);
    expect(find.text('Populer di kampus'), findsOneWidget);
    expect(find.text('Musim camping! Tenda & carrier mulai Rp25rb/hari'),
        findsOneWidget);
    expect(find.byKey(const Key('verification-banner')), findsNothing);

    final all = shown(tester);
    expect(all, hasLength(12));
    expect(all.any((l) => l.item.ownerId == gregorian), isFalse);
    expect(cards(tester).first.listing.item.judul,
        'Sony A6400 + Lensa Kit 16–50mm');

    await tester.drag(
        find.byKey(const Key('home-scroll')), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Baru ditambahkan'), findsOneWidget);
  });

  testWidgets('Chip "Kamera" hanya menampilkan barang kamera', (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await tester.tap(find.byKey(const Key('chip-kamera')));
    await tester.pumpAndSettle();

    expect(shown(tester), hasLength(3));
    expect(shown(tester).every((l) => l.item.kategori == Kategori.kamera),
        isTrue);
    expect(cards(tester).every((c) => c.listing.item.kategori == Kategori.kamera),
        isTrue);
    expect(find.text('3 barang ditemukan'), findsOneWidget);
    expect(find.text('MINGGU INI'), findsNothing, reason: 'promo disembunyikan');
  });

  testWidgets('Kartu promo memilih chip Camping', (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await tester.tap(find.text('MINGGU INI'));
    await tester.pumpAndSettle();
    expect(shown(tester).every((l) => l.item.kategori == Kategori.camping),
        isTrue);
    expect(find.text('3 barang ditemukan'), findsOneWidget);
  });

  testWidgets('Pencarian (debounce, tak peka huruf) & state kosong',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);

    await typeSearch(tester, 'GOPRO');
    expect(shown(tester).map((l) => l.item.judul),
        ['GoPro Hero 11 + Mounting']);

    await typeSearch(tester, 'sepeda');
    expect(find.byKey(const Key('home-empty')), findsOneWidget);
    expect(find.text('Belum ada barang yang cocok'), findsOneWidget);

    await tester.tap(find.text('Hapus filter'));
    await tester.pumpAndSettle();
    expect(shown(tester), hasLength(12));
    expect(find.text('Populer di kampus'), findsOneWidget);
  });

  testWidgets('Filter sheet: termurah + hanya tersedia, angka di tombol filter',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await tester.tap(find.byKey(const Key('home-filter')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Termurah'));
    await tester.tap(find.text('Hanya yang tersedia'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('filter-apply')));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Filter, 2 aktif'), findsOneWidget);
    expect(shown(tester).every((l) => l.status == ItemStatus.tersedia), isTrue);
    expect(shown(tester).first.item.judul, 'Ukulele Soprano Mahoni');

    await tester.tap(find.byKey(const Key('home-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Atur ulang'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Filter'), findsOneWidget);
    expect(find.text('Populer di kampus'), findsOneWidget);
  });

  testWidgets('Pindah tab lalu kembali menyimpan posisi scroll Beranda',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    ScrollPosition position() => tester
        .state<ScrollableState>(find
            .descendant(
                of: find.byKey(const Key('home-scroll')),
                matching: find.byType(Scrollable))
            .first)
        .position;

    await tester.drag(find.byKey(const Key('home-scroll')), const Offset(0, -600));
    await tester.pumpAndSettle();
    final offset = position().pixels;
    expect(offset, greaterThan(300));

    await openTab(tester, 'Sewaan');
    expect(find.byType(SewaanPage), findsOneWidget);
    await openTab(tester, 'Beranda');
    expect(position().pixels, offset);
  });

  testWidgets('Menekan kartu membuka /barang/{id}', (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await tester.tap(find.byType(ItemCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(ItemDetailPage), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('Sony A6400 + Lensa Kit 16–50mm'), findsOneWidget);
  });

  testWidgets('State error lalu "Coba lagi" memuat ulang', (tester) async {
    final storage = await pumpApp(tester, sessionUserId: gregorian);
    final container = ProviderScope.containerOf(
        tester.element(find.byType(HomePage)));
    (container.read(itemRepositoryProvider) as FakeItemRepository)
        .debugFailNext = true;
    expect(storage.sessionUserId, gregorian);

    await tester.fling(
        find.byKey(const Key('home-scroll')), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Koneksi lagi putus. Coba lagi ya.'), findsOneWidget);

    final retry = find.text('Coba lagi');
    await tester.ensureVisible(retry);
    await tester.pumpAndSettle();
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(shown(tester), hasLength(12));
  });

  testWidgets('Font sistem besar (2×) tidak overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpApp(tester, sessionUserId: 'usr-002');
    // Aulia (belum verifikasi) → ke /verifikasi dulu, lalu jelajah.
    final link = find.text('jelajah barang dulu');
    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byKey(const Key('verification-banner')), findsOneWidget);

    await tester.drag(
        find.byKey(const Key('home-scroll')), const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

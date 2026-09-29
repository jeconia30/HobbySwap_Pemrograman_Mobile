import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/router/app_routes.dart';
import 'package:hobby_swab/core/widgets/app_button.dart';
import 'package:hobby_swab/data/fake/fake_booking_store.dart';
import 'package:hobby_swab/features/booking/domain/booking.dart';
import 'package:hobby_swab/features/booking/presentation/sewaan_page.dart';
import 'package:hobby_swab/features/handover/data/checklist_providers.dart';
import 'package:hobby_swab/features/handover/domain/handover_checklist.dart';
import 'package:hobby_swab/features/handover/presentation/checklist_page.dart';
import 'package:hobby_swab/features/review/presentation/rating_page.dart';

import '../../helpers/pump_app.dart';

const gregorian = 'usr-001';
const gopro = 'bkg-022'; // disetujui, dari Dimas
const sony = 'bkg-021'; // berlangsung, dari Rizky
const stik = 'bkg-023'; // menunggu
const tenda = 'bkg-024'; // selesai, belum dirating

void main() {
  Future<void> openSewaan(WidgetTester tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await openTab(tester, 'Sewaan');
    await waitRepo(tester);
    expect(find.byType(SewaanPage), findsOneWidget);
  }

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

  AppButton button(WidgetTester tester, Key key) =>
      tester.widget<AppButton>(find.byKey(key));

  group('Sewaan Saya', () {
    testWidgets('Segmen Aktif/Menunggu/Riwayat dan kartu sesuai status', (
      tester,
    ) async {
      await openSewaan(tester);

      expect(find.text('Aktif · 3'), findsOneWidget);
      expect(find.text('Menunggu · 1'), findsOneWidget);
      expect(find.text('Kembalikan dalam 1 hari'), findsOneWidget);
      // Sony (sewa) + Keyboard (barter, M11) sedang berlangsung.
      expect(find.text('Checklist pengembalian'), findsWidgets);
      await tester.scrollUntilVisible(find.text('Checklist ambil barang'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('Checklist ambil barang'), findsOneWidget);
      expect(find.textContaining('dari Rizky N.'), findsOneWidget);

      await tester.scrollUntilVisible(
          find.byKey(const Key('segmen-riwayat')), -200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(find.byKey(const Key('segmen-riwayat')));
      await tester.pumpAndSettle();
      expect(
        find.text('Alasan pemilik: Barang sedang dipakai'),
        findsOneWidget,
      );
    });

    testWidgets(
      'Kartu "Beri rating" hanya untuk sewa selesai yang belum dirating',
      (tester) async {
        await openSewaan(tester);
        await tester.tap(find.byKey(const Key('segmen-riwayat')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('rating-prompt-$tenda')), findsOneWidget);
        expect(find.textContaining('Beri rating untuk'), findsOneWidget);
        expect(
          find.text('Beri rating untuk Tenda Dome 4 Orang'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Batalkan pengajuan menunggu lewat bottom sheet', (
      tester,
    ) async {
      await openSewaan(tester);
      await tester.tap(find.byKey(const Key('segmen-menunggu')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('batalkan-$stik')));
      await tester.pumpAndSettle();
      expect(find.text('Batalkan pengajuan?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('batalkan-konfirmasi')));
      await waitRepo(tester);

      expect(find.text('Pengajuan dibatalkan.'), findsOneWidget);
      expect(find.text('Menunggu · 0'), findsOneWidget);
      await tester.tap(find.byKey(const Key('segmen-riwayat')));
      await tester.pumpAndSettle();
      expect(find.text('Dibatalkan'), findsOneWidget);
    });
  });

  group('Checklist serah terima', () {
    testWidgets('Segmen Akhir nonaktif sebelum tahap awal selesai', (
      tester,
    ) async {
      await openSewaan(tester);
      await tapVisible(tester, find.byKey(const Key('checklist-$gopro')));
      await waitRepo(tester);
      expect(find.byType(ChecklistPage), findsOneWidget);

      bool akhirEnabled() => tester
          .widget<Semantics>(find.byKey(const Key('tahap-akhir')))
          .properties
          .enabled!;
      expect(akhirEnabled(), isFalse);
      await tester.tap(find.text('Akhir · saat kembali'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Setujui serah terima'), findsOneWidget);
    });

    testWidgets(
      'Aturan foto, lalu kedua pihak setuju → berlangsung & kembali ke Sewaan',
      (tester) async {
        await openSewaan(tester);
        await tapVisible(tester, find.byKey(const Key('checklist-$gopro')));
        await waitRepo(tester);
        expect(
          find.textContaining('0 dari 5 dicek', findRichText: true),
          findsOneWidget,
        );

        final setujui = find.byKey(const Key('checklist-setujui'));
        await tapVisible(tester, setujui);
        expect(
          find.textContaining('Tambahkan minimal 2 foto bukti.'),
          findsOneWidget,
        );

        for (var i = 0; i < 5; i++) {
          await tapVisible(tester, find.byKey(Key('kondisi-$i')));
        }
        await tapVisible(tester, find.byKey(const Key('foto-0')));
        await tapVisible(tester, find.byKey(const Key('foto-1')));
        expect(
          find.textContaining('5 dari 5 dicek', findRichText: true),
          findsOneWidget,
        );

        await tapVisible(tester, setujui);
        await waitRepo(tester);
        expect(find.text('Menunggu Dimas menyetujui…'), findsOneWidget);

        // M10: Dimas mencatat pembayaran COD, lalu menyetujui dari perangkatnya.
        final store = appContainer(tester).read(fakeBookingStoreProvider);
        store.update(
          store
              .byId(gopro)!
              .copyWith(
                statusBayar: StatusBayar.lunas,
                metodeBayar: MetodeBayar.tunai,
              ),
        );
        // Jangan di-await langsung: jeda repo hanya berjalan saat dipompa.
        final dimasSetuju = appContainer(tester)
            .read(checklistRepositoryProvider)
            .approve(gopro, TahapChecklist.awal, 'usr-005');
        await waitRepo(tester);
        await dimasSetuju;

        expect(
          find.text('Serah terima beres. Selamat memakai!'),
          findsOneWidget,
        );
        await waitRepo(tester);
        expect(find.byType(SewaanPage), findsOneWidget);
        expect(find.text('Checklist ambil barang'), findsNothing);
        expect(find.text('Checklist pengembalian'), findsWidgets);
        expect(find.byKey(const Key('checklist-$gopro')), findsOneWidget);
      },
    );

    testWidgets('Pengembalian disetujui kedua pihak → layar rating', (
      tester,
    ) async {
      await openSewaan(tester);
      await tapVisible(tester, find.byKey(const Key('checklist-$sony')));
      await waitRepo(tester);
      expect(find.text('Setujui pengembalian'), findsOneWidget);
      // Ada item belum dicentang: tombol laporan kerusakan tersedia.
      expect(find.byKey(const Key('laporkan-kerusakan')), findsOneWidget);

      for (var i = 0; i < 5; i++) {
        await tapVisible(tester, find.byKey(Key('kondisi-$i')));
      }
      expect(find.byKey(const Key('laporkan-kerusakan')), findsNothing);
      await tapVisible(tester, find.byKey(const Key('foto-0')));
      await tapVisible(tester, find.byKey(const Key('foto-2')));
      await tapVisible(tester, find.byKey(const Key('checklist-setujui')));
      await waitRepo(tester);

      final rizkySetuju = appContainer(tester)
          .read(checklistRepositoryProvider)
          .approve(sony, TahapChecklist.akhir, 'usr-003');
      await waitRepo(tester);
      await rizkySetuju;
      await waitRepo(tester);
      expect(find.byType(RatingPage), findsOneWidget);
      expect(find.text('Gimana sewanya?'), findsOneWidget);
    });
  });

  group('Rating', () {
    Future<void> openRating(WidgetTester tester) async {
      await openSewaan(tester);
      await tester.tap(find.byKey(const Key('segmen-riwayat')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('rating-prompt-$tenda')));
      await waitRepo(tester);
      expect(find.byType(RatingPage), findsOneWidget);
    }

    testWidgets('"Kirim ulasan" nonaktif sebelum bintang dipilih', (
      tester,
    ) async {
      await openRating(tester);
      expect(find.textContaining('disewakan Sarah Manurung'), findsOneWidget);
      expect(button(tester, const Key('rating-kirim')).onPressed, isNull);

      await tester.tap(find.byKey(const Key('bintang-4')));
      await tester.pump();
      expect(button(tester, const Key('rating-kirim')).onPressed, isNotNull);
      expect(find.textContaining('Bagus', findRichText: true), findsOneWidget);
    });

    testWidgets('Bintang 2 tanpa cerita memunculkan pesan; lalu terkirim', (
      tester,
    ) async {
      await openRating(tester);
      await tester.tap(find.byKey(const Key('bintang-2')));
      await tester.pump();
      await tapVisible(tester, find.byKey(const Key('rating-kirim')));
      expect(find.byKey(const Key('rating-cerita-error')), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('rating-cerita')),
          matching: find.byType(EditableText),
        ),
        'Tendanya bocor sedikit di sudut.',
      );
      await tester.tap(find.text('Tepat waktu'));
      await tapVisible(tester, find.byKey(const Key('rating-kirim')));
      await waitRepo(tester);

      expect(
        find.text('Makasih! Ulasanmu membantu mahasiswa lain.'),
        findsOneWidget,
      );
      expect(find.byType(SewaanPage), findsOneWidget);
      expect(find.byKey(const Key('rating-prompt-$tenda')), findsNothing);
    });
  });

  testWidgets('Barang Saya: aksi checklist & beri rating penyewa', (
    tester,
  ) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await openTab(tester, 'Barang');
    await waitRepo(tester);

    Future<void> openRow(String id) async {
      final row = find.byKey(Key('item-row-$id'));
      if (row.evaluate().isEmpty) {
        await tester.scrollUntilVisible(
          row,
          200,
          scrollable: find.byType(Scrollable).first,
        );
      }
      await tapVisible(tester, row);
    }

    await openRow('itm-014'); // Switch OLED, sedang disewa Sarah
    expect(find.text('Checklist serah terima'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await openRow('itm-013'); // Carrier, bkg-009 belum dinilai pemilik
    expect(find.text('Beri rating penyewa'), findsOneWidget);
    expect(find.text('Checklist serah terima'), findsNothing);
    await tester.tap(find.text('Beri rating penyewa'));
    await waitRepo(tester);
    expect(find.byType(RatingPage), findsOneWidget);
    expect(find.textContaining('disewa Rizky Nugraha'), findsOneWidget);
    expect(find.text('Barang dijaga baik'), findsOneWidget);
  });

  testWidgets('Detail Barang: bagian ulasan & halaman semua ulasan', (
    tester,
  ) async {
    await pumpApp(tester, sessionUserId: 'usr-004');
    await pushRoute(tester, AppRoutes.barangDetail('itm-001'));
    await waitRepo(tester);

    final section = find.byKey(const Key('ulasan-section'));
    await tester.ensureVisible(section);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: section, matching: find.text('Ulasan')),
      findsOneWidget,
    );
    expect(
      find.textContaining('ulasan untuk Rizky Nugraha', findRichText: true),
      findsWidgets,
    );

    await tester.tap(find.text('Lihat semua'));
    await waitRepo(tester);
    expect(find.text('Dimas Ramadhan'), findsOneWidget);
    expect(find.text('Sarah Manurung'), findsWidgets);
  });

  testWidgets('Font sistem besar (2×): Sewaan, checklist, rating', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await openSewaan(tester);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    await pushRoute(tester, AppRoutes.checklist(gopro));
    await waitRepo(tester);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    await pushRoute(tester, AppRoutes.rating(tenda));
    await waitRepo(tester);
    await tapVisible(tester, find.byKey(const Key('bintang-5')));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

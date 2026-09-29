import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/router/app_routes.dart';
import 'package:hobby_swab/data/fake/fake_chat_store.dart';
import 'package:hobby_swab/features/chat/domain/chat_message.dart';
import 'package:hobby_swab/features/chat/presentation/pesan_page.dart';
import 'package:hobby_swab/features/chat/presentation/ruang_obrolan_page.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/text_scale.dart';

const gregorian = 'usr-001', rizky = 'usr-003';

void main() {
  Future<void> bukaThread(WidgetTester tester, String id) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await goRoute(tester, AppRoutes.pesanThread(id));
    expect(find.byType(RuangObrolanPage), findsOneWidget);
  }

  FakeChatStore store(WidgetTester tester) =>
      appContainer(tester).read(fakeChatStoreProvider);

  IconButton tombolKirim(WidgetTester tester) =>
      tester.widget<IconButton>(find.byKey(const Key('chat-kirim')));

  String labelAksi(WidgetTester tester) => tester
      .widget<Text>(find.descendant(
          of: find.byKey(const Key('chat-aksi')), matching: find.byType(Text)))
      .data!;

  testWidgets('tombol kirim nonaktif saat kolom ketik kosong', (tester) async {
    await bukaThread(tester, 'thr-003');
    expect(tombolKirim(tester).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('chat-input')), 'Halo Kak');
    await tester.pump();
    expect(tombolKirim(tester).onPressed, isNotNull);

    await tester.enterText(find.byKey(const Key('chat-input')), '   ');
    await tester.pump();
    expect(tombolKirim(tester).onPressed, isNull);
  });

  testWidgets('mengirim pesan menambah gelembung di kanan', (tester) async {
    await bukaThread(tester, 'thr-003');
    const teks = 'Oke Kak, aku ambil jam 4 ya';
    await tester.enterText(find.byKey(const Key('chat-input')), teks);
    await tester.pump();
    await tester.tap(find.byKey(const Key('chat-kirim')));
    await waitRepo(tester);

    final gelembung = find.text(teks);
    expect(gelembung, findsOneWidget);
    final lebar = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(tester.getCenter(gelembung).dx, greaterThan(lebar / 2));
    expect(tester.getTopRight(gelembung).dx,
        greaterThan(lebar - AppSpacingTest.pinggir));
    // Kolom ketik kosong lagi & pesan berstatus terkirim (belum dibaca).
    expect(tombolKirim(tester).onPressed, isNull);
    final baru = store(tester).lastOf('thr-003')!;
    expect(baru.isi, teks);
    expect(find.byKey(Key('centang-${baru.id}')), findsOneWidget);
    // Pesan terakhir dariku: balasan cepat disembunyikan.
    expect(find.byKey(const Key('balasan-cepat')), findsNothing);
  });

  testWidgets('kartu COD: tombol Setuju hanya untuk penerima', (tester) async {
    await bukaThread(tester, 'thr-001');
    final s = store(tester);
    final dariRizky = s.add(
      threadId: 'thr-001',
      senderId: rizky,
      tipe: TipePesan.lokasiCod,
      isi: 'Usulan titik COD',
      payload: UsulanCod(lokasi: 'FT USU', waktu: hPlus(1)).toPayload(),
    );
    final dariku = s.add(
      threadId: 'thr-001',
      senderId: gregorian,
      tipe: TipePesan.lokasiCod,
      isi: 'Usulan titik COD',
      payload: UsulanCod(lokasi: 'Pintu 4', waktu: hPlus(1)).toPayload(),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(Key('cod-setuju-${dariRizky.id}')), findsOneWidget);
    expect(find.byKey(Key('cod-usul-${dariRizky.id}')), findsOneWidget);
    expect(find.byKey(Key('cod-setuju-${dariku.id}')), findsNothing);
    expect(find.text('Menunggu jawaban…'), findsOneWidget);

    await tester.ensureVisible(find.byKey(Key('cod-setuju-${dariRizky.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('cod-setuju-${dariRizky.id}')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('cod-setuju-${dariRizky.id}')), findsNothing);
    expect(find.byKey(Key('cod-disetujui-${dariRizky.id}')), findsOneWidget);
    expect(s.message(dariRizky.id)!.cod!.status, StatusCod.disetujui);
  });

  testWidgets('tombol di kartu transaksi mengikuti status sewa',
      (tester) async {
    await bukaThread(tester, 'thr-001'); // penyewa, berlangsung
    expect(labelAksi(tester), 'Checklist kembali');

    await goRoute(tester, AppRoutes.pesanThread('thr-003')); // disetujui
    expect(labelAksi(tester), 'Checklist ambil');

    await goRoute(tester, AppRoutes.pesanThread('thr-002')); // pemilik, menunggu
    expect(labelAksi(tester), 'Tinjau');

    await goRoute(tester, AppRoutes.pesanThread('thr-004')); // selesai
    await waitRepo(tester);
    expect(labelAksi(tester), 'Beri rating');

    final baru = store(tester).findOrCreate(gregorian, 'usr-004', 'itm-002');
    await goRoute(tester, AppRoutes.pesanThread(baru.id)); // tanpa sewa
    expect(labelAksi(tester), 'Lihat barang');
    expect(find.byKey(const Key('banner-keamanan')), findsOneWidget);
    expect(find.text('Masih tersedia?'), findsOneWidget);
  });

  testWidgets('Beranda → Pesan: badge unread hilang setelah thread dibuka',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    final badge = find.descendant(
        of: find.byKey(const Key('ikon-pesan')), matching: find.text('2'));
    expect(badge, findsOneWidget);

    await tester.tap(find.byKey(const Key('ikon-pesan')));
    await waitRepo(tester);
    expect(find.byType(PesanPage), findsOneWidget);
    expect(find.byKey(const Key('unread-thr-002')), findsOneWidget);
    expect(find.byKey(const Key('thread-row-thr-004')), findsOneWidget);

    await tester.tap(find.byKey(const Key('thread-row-thr-002')));
    await waitRepo(tester);
    expect(find.text('Aulia Putri'), findsOneWidget);
    expect(store(tester).thread('thr-002')!.unreadUntuk(gregorian), 0);

    await tester.tap(find.byTooltip('Kembali'));
    await waitRepo(tester);
    expect(find.byKey(const Key('unread-thr-002')), findsNothing);
    await tester.tap(find.byTooltip('Kembali'));
    await waitRepo(tester);
    expect(badge, findsNothing);
  });

  testWidgets('Detail barang → Chat pemilik membuka ruang obrolan baru',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await goRoute(tester, AppRoutes.barangDetail('itm-002'));
    final tombol = find.byKey(const Key('chat-pemilik'));
    await tester.ensureVisible(tombol);
    await tester.pumpAndSettle();
    await tester.tap(tombol);
    await waitRepo(tester);
    expect(find.byType(RuangObrolanPage), findsOneWidget);
    expect(find.text('Sarah Manurung'), findsOneWidget);
    expect(find.byKey(const Key('banner-keamanan')), findsOneWidget);
  });

  testWidgets('cari di kotak masuk menyaring nama atau barang',
      (tester) async {
    await pumpApp(tester, sessionUserId: gregorian);
    await goRoute(tester, AppRoutes.pesan);
    await tester.enterText(find.byKey(const Key('pesan-cari')), 'tenda');
    await tester.pump();
    expect(find.byKey(const Key('thread-row-thr-004')), findsOneWidget);
    expect(find.byKey(const Key('thread-row-thr-001')), findsNothing);
    await tester.enterText(find.byKey(const Key('pesan-cari')), 'zzz');
    await tester.pump();
    expect(find.text('Tidak ada obrolan yang cocok.'), findsOneWidget);
  });
}

/// Gelembung milikku menempel ke sisi kanan (dalam padding halaman).
abstract final class AppSpacingTest {
  static const pinggir = 40.0;
}

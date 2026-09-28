import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hobby_swab/core/theme/app_theme.dart';
import 'package:hobby_swab/core/utils/dates.dart';
import 'package:hobby_swab/core/widgets/availability_calendar.dart';
import 'package:hobby_swab/features/booking/domain/booking_rules.dart';
import 'package:hobby_swab/features/item/domain/item.dart';
import 'package:intl/date_symbol_data_local.dart';

final today = DateTime(2026, 10, 5); // Senin
DateTime d(int day, [int month = 10]) => DateTime(2026, month, day);
Key day(DateTime x) => Key('day-${x.year}-${x.month}-${x.day}');

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting(appLocale);
  });

  group('nextSelection', () {
    test('tap pertama mulai, tap kedua kembali', () {
      var s = nextSelection(DateSelection.empty, d(9));
      expect((s.start, s.end), (d(9), null));
      s = nextSelection(s, d(11));
      expect((s.start, s.end), (d(9), d(11)));
    });

    test('tap kedua lebih awal → urutan ditukar', () {
      final s = nextSelection(DateSelection(start: d(11)), d(9));
      expect((s.start, s.end), (d(9), d(11)));
    });

    test('tap tanggal yang sama = sewa 1 hari; tap ketiga mulai ulang', () {
      var s = nextSelection(DateSelection(start: d(9)), d(9));
      expect((s.start, s.end), (d(9), d(9)));
      s = nextSelection(s, d(20));
      expect((s.start, s.end), (d(20), null));
    });
  });

  /// Kalender dengan blokir 12–13 Okt, memakai aturan sewa sesungguhnya.
  Future<List<DateSelection>> pumpCalendar(WidgetTester tester) async {
    final changes = <DateSelection>[];
    final blocked = [RentangTanggal(mulai: d(12), selesai: d(13))];
    var selection = DateSelection.empty;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => AvailabilityCalendar(
              today: today,
              selection: selection,
              onChanged: (s) {
                changes.add(s);
                setState(() => selection = s);
              },
              isBlocked: (x) => tanggalTerblokir(x, blocked),
              validateRange: (s, e) => periksaRentang(
                      mulai: s, kembali: e, hariIni: today, terblokir: blocked)
                  ?.pesan,
            ),
          ),
        ),
      ),
    ));
    return changes;
  }

  testWidgets('judul bulan & label hari mulai Senin', (tester) async {
    await pumpCalendar(tester);
    expect(find.text('Pilih tanggal · Oktober'), findsOneWidget);
    expect(find.text('Coret = sudah disewa'), findsOneWidget);
    expect(find.text('Sen'), findsOneWidget);
  });

  testWidgets('tanggal terblokir & lampau tidak bisa dipilih', (tester) async {
    final changes = await pumpCalendar(tester);
    await tester.tap(find.byKey(day(d(12))));
    await tester.tap(find.byKey(day(d(4))));
    await tester.pump();
    expect(changes, isEmpty);
  });

  testWidgets('memilih dua tanggal menghasilkan rentang', (tester) async {
    final changes = await pumpCalendar(tester);
    await tester.tap(find.byKey(day(d(9))));
    await tester.pump();
    await tester.tap(find.byKey(day(d(7))));
    await tester.pump();
    expect((changes.last.start, changes.last.end), (d(7), d(9)));
    expect(find.byKey(const Key('calendar-error')), findsNothing);
  });

  testWidgets('rentang melewati tanggal terblokir ditolak dengan pesan',
      (tester) async {
    final changes = await pumpCalendar(tester);
    await tester.tap(find.byKey(day(d(10))));
    await tester.pump();
    await tester.tap(find.byKey(day(d(15))));
    await tester.pump();

    expect(find.text('Rentang ini melewati tanggal yang sudah disewa'),
        findsOneWidget);
    expect(changes.last.end, isNull, reason: 'rentang tidak diterima');
    expect(changes.last.start, d(10));
  });

  testWidgets('lebih dari 14 hari ditolak dengan pesan', (tester) async {
    await pumpCalendar(tester);
    await tester.tap(find.byKey(day(d(14))));
    await tester.pump();
    await tester.tap(find.byTooltip('Bulan berikutnya'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(day(d(2, 11))));
    await tester.pump();
    expect(find.text('Maksimal 14 hari sekali sewa'), findsOneWidget);
  });

  testWidgets('navigasi bulan: tidak bisa mundur, maju maksimal 3 bulan',
      (tester) async {
    await pumpCalendar(tester);
    IconButton button(String tooltip) => tester.widget<IconButton>(
        find.ancestor(
            of: find.byTooltip(tooltip), matching: find.byType(IconButton)));

    expect(button('Bulan sebelumnya').onPressed, isNull);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byTooltip('Bulan berikutnya'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Pilih tanggal · Januari'), findsOneWidget);
    expect(button('Bulan berikutnya').onPressed, isNull);
    expect(button('Bulan sebelumnya').onPressed, isNotNull);
  });
}

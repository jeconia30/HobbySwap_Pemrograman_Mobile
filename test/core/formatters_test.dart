import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/utils/dates.dart';
import 'package:hobby_swab/core/utils/formatters.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  test('formatRupiah memakai titik ribuan tanpa spasi', () {
    expect(formatRupiah(45000), 'Rp45.000');
    expect(formatRupiah(135000), 'Rp135.000');
    expect(formatRupiah(1250000), 'Rp1.250.000');
    expect(formatRupiah(0), 'Rp0');
  });

  test('tanggal Indonesia', () {
    final d = DateTime(2026, 10, 10); // Sabtu
    expect(formatTanggalPendek(d), 'Sab, 10 Okt');
    expect(formatBulan(d), 'Oktober');
    expect(formatBulanTahun(d), 'Oktober 2026');
    expect(namaHariPendek(), ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']);
  });

  test('daysBetween & addDays melintasi bulan', () {
    expect(daysBetween(DateTime(2026, 10, 30), DateTime(2026, 11, 2)), 3);
    expect(addDays(DateTime(2026, 12, 31), 1), DateTime(2027, 1, 1));
  });
}

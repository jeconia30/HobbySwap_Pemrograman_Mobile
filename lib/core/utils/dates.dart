import 'package:intl/intl.dart';

/// Locale tanggal & uang aplikasi. `initializeDateFormatting` dipanggil di main.
const appLocale = 'id_ID';

/// Tanggal tanpa jam (zona lokal). Semua logika sewa bekerja per hari.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Selisih hari kalender, aman terhadap pergantian jam musim panas.
int daysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;

/// "Sab, 11 Okt"
String formatTanggalPendek(DateTime d) =>
    DateFormat('EEE, d MMM', appLocale).format(d);

/// "9–11 Okt" (bulan sama) atau "30 Okt – 2 Nov".
String formatRentangPendek(DateTime mulai, DateTime kembali) {
  final bulan = DateFormat('MMM', appLocale);
  if (isSameDay(mulai, kembali)) return '${mulai.day} ${bulan.format(mulai)}';
  if (mulai.year == kembali.year && mulai.month == kembali.month) {
    return '${mulai.day}–${kembali.day} ${bulan.format(kembali)}';
  }
  return '${mulai.day} ${bulan.format(mulai)} – '
      '${kembali.day} ${bulan.format(kembali)}';
}

/// "09.12"
String formatJam(DateTime d) => DateFormat('HH.mm', appLocale).format(d);

/// "Oktober"
String formatBulan(DateTime d) => DateFormat('MMMM', appLocale).format(d);

/// "Oktober 2026"
String formatBulanTahun(DateTime d) =>
    DateFormat('MMMM yyyy', appLocale).format(d);

/// "Sabtu, 11 Oktober 2026" (untuk pembaca layar).
String formatTanggalPanjang(DateTime d) =>
    DateFormat('EEEE, d MMMM yyyy', appLocale).format(d);

/// Label kolom kalender, mulai Senin: Sen, Sel, …, Min.
List<String> namaHariPendek() {
  final f = DateFormat('EEE', appLocale);
  // 2024-01-01 adalah hari Senin.
  return [for (var i = 0; i < 7; i++) f.format(DateTime(2024, 1, 1 + i))];
}

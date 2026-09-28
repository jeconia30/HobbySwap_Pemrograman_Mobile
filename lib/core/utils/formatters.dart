import 'package:intl/intl.dart';

import 'dates.dart';

final _rupiah =
    NumberFormat.currency(locale: appLocale, symbol: 'Rp', decimalDigits: 0);

/// "Rp45.000" (pemisah ribuan titik, tanpa desimal, tanpa spasi).
String formatRupiah(int value) => _rupiah.format(value).replaceAll(' ', '');

final _ringkas = NumberFormat('#,##0.#', appLocale);

/// Uang ringkas untuk statistik: "Rp420rb", "Rp12,5rb", "Rp1,3jt".
String formatRupiahRingkas(int value) {
  if (value.abs() >= 1000000) return 'Rp${_ringkas.format(value / 1000000)}jt';
  if (value.abs() >= 1000) return 'Rp${_ringkas.format(value / 1000)}rb';
  return formatRupiah(value);
}

/// "4.9" untuk rating (satu desimal).
String formatRating(double value) => value.toStringAsFixed(1);

/// Nama depan untuk sapaan.
String firstName(String fullName) => fullName.trim().split(RegExp(r'\s+')).first;

/// "Rizky Nugraha" → "Rizky N."; satu kata dibiarkan.
String namaPendek(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  return parts.length < 2 ? parts.first : '${parts.first} ${parts[1][0]}.';
}

/// Inisial maksimal dua huruf untuk avatar.
String initials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}

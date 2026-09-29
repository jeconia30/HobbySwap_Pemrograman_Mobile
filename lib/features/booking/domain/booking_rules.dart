import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';
import '../../item/domain/item.dart';

/// Batas lama sewa sekali pengajuan.
const maxHariSewa = 14;

/// Jumlah hari inklusif: 9–11 Okt = 3 hari.
int hitungHari(DateTime mulai, DateTime kembali) =>
    daysBetween(mulai, kembali) + 1;

int hitungTotal(int hargaPerHari, DateTime mulai, DateTime kembali) =>
    hargaPerHari * hitungHari(mulai, kembali);

/// Dua rentang inklusif bertumpuk bila berbagi minimal satu hari.
/// Bersebelahan (11 Okt selesai, 12 Okt mulai) tidak bentrok.
bool rentangBertumpuk(
  DateTime aMulai,
  DateTime aKembali,
  DateTime bMulai,
  DateTime bKembali,
) =>
    daysBetween(aMulai, bKembali) >= 0 && daysBetween(bMulai, aKembali) >= 0;

bool tanggalTerblokir(DateTime hari, Iterable<RentangTanggal> terblokir) =>
    terblokir.any((r) => rentangBertumpuk(hari, hari, r.mulai, r.selesai));

bool rentangMelewatiBlokir(
  DateTime mulai,
  DateTime kembali,
  Iterable<RentangTanggal> terblokir,
) =>
    terblokir.any((r) => rentangBertumpuk(mulai, kembali, r.mulai, r.selesai));

/// Hari tersisa sampai tanggal kembali (0 = hari ini, negatif = terlambat).
int sisaHariSewa(DateTime kembali, DateTime hariIni) =>
    daysBetween(hariIni, kembali);

/// Hari berjalan / total hari (0–1) untuk progress sewa berlangsung.
double progresSewa(DateTime mulai, DateTime kembali, DateTime hariIni) {
  final total = hitungHari(mulai, kembali);
  final berjalan = daysBetween(mulai, hariIni) + 1;
  return (berjalan / total).clamp(0.0, 1.0);
}

/// "Kembalikan dalam 2 hari" / "Kembalikan hari ini" /
/// "Terlambat 1 hari, segera kembalikan".
String teksSisaHari(int sisa) {
  if (sisa > 0) return 'Kembalikan dalam $sisa hari';
  if (sisa == 0) return 'Kembalikan hari ini';
  return 'Terlambat ${-sisa} hari, segera kembalikan';
}

enum MasalahRentang {
  lampau('Tanggal mulai sudah lewat. Pilih mulai hari ini atau setelahnya.'),
  terbalik('Tanggal kembali harus sama atau setelah tanggal mulai.'),
  terlaluLama('Maksimal $maxHariSewa hari sekali sewa'),
  melewatiBlokir('Rentang ini melewati tanggal yang sudah disewa');

  const MasalahRentang(this.pesan);

  final String pesan;
}

/// `null` = rentang valid.
MasalahRentang? periksaRentang({
  required DateTime mulai,
  required DateTime kembali,
  required DateTime hariIni,
  Iterable<RentangTanggal> terblokir = const [],
}) {
  if (daysBetween(hariIni, mulai) < 0) return MasalahRentang.lampau;
  if (daysBetween(mulai, kembali) < 0) return MasalahRentang.terbalik;
  if (hitungHari(mulai, kembali) > maxHariSewa) {
    return MasalahRentang.terlaluLama;
  }
  if (rentangMelewatiBlokir(mulai, kembali, terblokir)) {
    return MasalahRentang.melewatiBlokir;
  }
  return null;
}

/// Denda keterlambatan: hari lewat tanggal kembali × denda per hari.
/// Dihitung terhadap [hariKembali] (hari ini untuk "denda sementara",
/// atau hari checklist pengembalian).
({int hari, int total}) hitungDenda({
  required DateTime tanggalKembali,
  required DateTime hariKembali,
  required int dendaPerHari,
}) {
  final hari = daysBetween(tanggalKembali, hariKembali);
  if (hari <= 0) return (hari: 0, total: 0);
  return (hari: hari, total: hari * dendaPerHari);
}

/// Saran denda di form barang: 50% harga sewa, dibulatkan ke Rp500.
int saranDenda(int hargaPerHari) => (hargaPerHari * 0.5 / 500).round() * 500;

/// Aturan pembatalan sewa yang sudah disetujui (README "Aturan transaksi").
enum AturanBatal {
  /// Paling lambat H-1 sebelum tanggal ambil: bebas.
  bebas,

  /// Hari H (atau lewat) sebelum serah terima: boleh, tercatat di profil.
  mendadak,

  /// Sudah berlangsung/selesai/ditolak: tidak bisa dibatalkan.
  tidakBisa,
}


/// "Denda telat Rp22.500/hari" atau "Tanpa denda keterlambatan".
String teksDenda(int dendaPerHari) => dendaPerHari > 0
    ? 'Denda telat ${formatRupiah(dendaPerHari)}/hari'
    : 'Tanpa denda keterlambatan';

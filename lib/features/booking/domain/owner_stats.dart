import 'booking.dart';

/// Ringkasan untuk kartu statistik Barang Saya.
typedef OwnerStats = ({int pendapatanBulanIni, int jumlahDisewakan});

/// Pendapatan = sewa selesai/berlangsung/disetujui yang mulai di bulan
/// berjalan. Disewakan = semua sewa selesai sepanjang waktu.
OwnerStats hitungStatistikPemilik(Iterable<Booking> bookings, DateTime today) {
  var pendapatan = 0;
  var selesai = 0;
  for (final b in bookings) {
    if (b.status == StatusBooking.selesai) selesai++;
    final dihitung = b.status == StatusBooking.selesai ||
        b.status == StatusBooking.berlangsung ||
        b.status == StatusBooking.disetujui;
    if (dihitung &&
        b.tanggalMulai.year == today.year &&
        b.tanggalMulai.month == today.month) {
      pendapatan += b.totalHarga;
    }
  }
  return (pendapatanBulanIni: pendapatan, jumlahDisewakan: selesai);
}

/// "Aulia Putri ingin …", "A dan B ingin …", "A dan 2 lainnya ingin …".
String ringkasPeminta(List<String> namaUnik) => switch (namaUnik) {
      [] => '',
      [final a] => '$a ingin menyewa barangmu',
      [final a, final b] => '$a dan $b ingin menyewa barangmu',
      [final a, ...final rest] =>
        '$a dan ${rest.length} lainnya ingin menyewa barangmu',
    };

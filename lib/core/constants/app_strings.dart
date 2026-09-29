/// Teks UI yang dipakai berulang: label status & pesan umum. Teks khusus satu
/// layar tetap di layarnya.
abstract final class AppTeks {
  // Pesan & aksi umum.
  static const koneksiPutus = 'Koneksi lagi putus. Coba lagi ya.';
  static const cobaLagi = 'Coba lagi';
  static const sesiHabis = 'Sesimu habis. Masuk lagi ya.';
  static const sewaTidakDitemukan = 'Sewa ini tidak ditemukan.';
  static const verifikasiDulu = 'Verifikasi KTM dulu, ya.';
  static const kembali = 'Kembali';
  static const batal = 'Batal';
  static const keBeranda = 'Ke Beranda';

  // Layar error ramah (release build).
  static const errorJudul = 'Ada yang tidak beres';
  static const errorPesan = 'Coba buka ulang halaman ini';
  static const kembaliKeBeranda = 'Kembali ke Beranda';

  // Label status sewa.
  static const statusMenunggu = 'Menunggu';
  static const statusDisetujui = 'Disetujui';
  static const statusDitolak = 'Ditolak';
  static const statusBerlangsung = 'Berlangsung';
  static const statusSelesai = 'Selesai';
  static const statusDibatalkan = 'Dibatalkan';

  // Label status barang.
  static const statusTersedia = 'Tersedia';
  static const statusDisewa = 'Disewa';
  static const statusDibarter = 'Dibarter';
  static const statusNonaktif = 'Nonaktif';

  // Label status akun.
  static const terverifikasi = 'Terverifikasi';
  static const akunAktif = 'Aktif';
  static const akunDitinjau = 'Ditinjau';
  static const akunBelum = 'Belum';
}

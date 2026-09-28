abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const daftar = '/daftar';
  static const verifikasi = '/verifikasi';
  static const verifikasiStatus = '/verifikasi/status';

  // Tab shell
  static const beranda = '/beranda';
  static const sewaan = '/sewaan';
  static const barangSaya = '/barang-saya';
  static const profil = '/profil';

  static const aktivitas = '/aktivitas';
  static const barangTambah = '/barang/tambah';
  static String barangDetail(String id) => '/barang/$id';
  static String barangUbah(String id) => '/barang/$id/ubah';
  static const pengajuanMasuk = '/pengajuan';
  static String ulasanBarang(String itemId) => '/barang/$itemId/ulasan';

  /// Tab Sewaan Saya dengan segmen tertentu (`aktif`/`menunggu`/`riwayat`).
  static String sewaanTab(String tab) => '$sewaan?tab=$tab';

  static String checklist(String bookingId, {bool akhir = false}) =>
      '/sewa/$bookingId/checklist${akhir ? '?tahap=akhir' : ''}';

  static String rating(String bookingId) => '/sewa/$bookingId/rating';

  /// Form tambah/ubah barang; grup 1 = id barang (null untuk tambah).
  static final formBarangPattern =
      RegExp(r'^/barang/(?:tambah|([^/]+)/ubah)$');

  /// Konfirmasi sewa; tanggal dibawa lewat query (tahan deep link).
  static String ajukanSewa(String itemId, DateTime mulai, DateTime kembali) =>
      Uri(path: '/barang/$itemId/ajukan', queryParameters: {
        'mulai': _ymd(mulai),
        'kembali': _ymd(kembali),
      }).toString();

  static String pengajuanTerkirim(String bookingId) =>
      '/pengajuan-terkirim/$bookingId';

  /// Cocok dengan `/barang/:id/ajukan`; grup 1 = id barang.
  static final ajukanPattern = RegExp(r'^/barang/([^/]+)/ajukan$');

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}'
      '-${d.day.toString().padLeft(2, '0')}';

  /// Bisa dibuka tanpa masuk. Rute lain wajib masuk.
  static const public = {splash, onboarding, login, daftar};

  /// Tidak perlu dibuka lagi kalau sudah masuk.
  static const guestOnly = {login, daftar};
}

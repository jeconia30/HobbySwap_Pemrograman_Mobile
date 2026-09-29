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
  static const profilUbah = '/profil/ubah';
  static const profilUlasan = '/profil/ulasan';
  static const bantuan = '/bantuan';
  static const tentang = '/tentang';

  // Lupa password (M10). Email dibawa lewat query.
  static const lupaPassword = '/lupa-password';
  static const lupaPasswordCek = '/lupa-password/cek';
  static const resetPassword = '/reset-password';
  static String cekEmail(String email) =>
      Uri(path: lupaPasswordCek, queryParameters: {'email': email}).toString();
  static String resetPasswordUntuk(String email) =>
      Uri(path: resetPassword, queryParameters: {'email': email}).toString();
  static String loginDengan(String email) =>
      Uri(path: login, queryParameters: {'email': email}).toString();

  // Dokumen & akun (M10)
  static const syarat = '/syarat';
  static const privasi = '/privasi';
  static const hapusAkun = '/profil/hapus-akun';
  static const favoritku = '/profil/favorit';

  // Laporan (M10)
  static const laporanku = '/laporan';
  static const laporanBaruPath = '/laporan/baru';
  static String laporanBaru({
    String? bookingId,
    String? terlaporId,
    String? barangId,
  }) =>
      Uri(path: laporanBaruPath, queryParameters: {
        'booking': ?bookingId,
        'terlapor': ?terlaporId,
        'barang': ?barangId,
      }).toString();
  static String laporanDetail(String id) => '/laporan/$id';

  // Pesan (M9)
  static const pesan = '/pesan';
  static String pesanThread(String threadId) => '/pesan/$threadId';

  /// Rute tab shell: dibuka dengan `go` (pindah tab), bukan `push`.
  static bool isTab(String location) {
    final path = Uri.parse(location).path;
    return const {beranda, sewaan, barangSaya, profil}.contains(path);
  }
  static const barangTambah = '/barang/tambah';
  static String barangDetail(String id) => '/barang/$id';
  static String barangUbah(String id) => '/barang/$id/ubah';
  static String tawarBarter(String id) => '/barang/$id/barter';
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

  /// Tawarkan barter; grup 1 = id barang pemilik.
  static final barterPattern = RegExp(r'^/barang/([^/]+)/barter$');

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}'
      '-${d.day.toString().padLeft(2, '0')}';

  /// Bisa dibuka tanpa masuk. Rute lain wajib masuk.
  static const public = {
    splash,
    onboarding,
    login,
    daftar,
    lupaPassword,
    lupaPasswordCek,
    resetPassword,
    syarat,
    privasi,
  };

  /// Tidak perlu dibuka lagi kalau sudah masuk.
  static const guestOnly = {
    login,
    daftar,
    lupaPassword,
    lupaPasswordCek,
    resetPassword,
  };
}

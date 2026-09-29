enum KategoriLaporan {
  akun('Akun'),
  sewa('Sewa'),
  barang('Barang'),
  aplikasiError('Aplikasi error'),
  lainnya('Lainnya');

  const KategoriLaporan(this.label);

  final String label;
}

/// Kontrak laporan masalah ke tim HobbySwap.
abstract interface class SupportRepository {
  Future<void> kirimLaporan(KategoriLaporan kategori, String deskripsi);
}

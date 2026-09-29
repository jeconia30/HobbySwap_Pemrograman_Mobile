/// Isi dokumen Syarat Layanan & Kebijakan Privasi (DRAF, belum ditinjau ahli
/// hukum). Disimpan sebagai data supaya nanti bisa diambil dari server.
class BagianDokumen {
  const BagianDokumen(this.judul, this.paragraf);

  final String judul;
  final List<String> paragraf;
}

class DokumenHukum {
  const DokumenHukum({
    required this.judul,
    required this.berlakuSejak,
    required this.bagian,
  });

  final String judul;
  final DateTime berlakuSejak;
  final List<BagianDokumen> bagian;
}

final syaratLayanan = DokumenHukum(
  judul: 'Syarat Layanan',
  berlakuSejak: DateTime(2026, 10, 1),
  bagian: const [
    BagianDokumen('Tentang HobbySwap', [
      'HobbySwap adalah tempat mahasiswa Universitas Sumatera Utara saling '
          'menyewa dan menyewakan barang hobi. Kami mempertemukan penyewa dan '
          'pemilik; barang tetap milik pemiliknya.',
      'Dengan membuat akun, kamu setuju mengikuti syarat ini. Kalau tidak '
          'setuju, jangan pakai HobbySwap.',
    ]),
    BagianDokumen('Akun & verifikasi KTM', [
      'Satu orang satu akun, memakai email kampus dan NIM milikmu sendiri.',
      'Sebelum bisa menyewa atau menyewakan, kamu wajib verifikasi KTM dan '
          'selfie memegang KTM. Tim kami meninjaunya, biasanya kurang dari '
          '1×24 jam.',
      'Jaga password-mu. Kami tidak pernah meminta password lewat chat.',
    ]),
    BagianDokumen('Menyewa & menyewakan', [
      'Pemilik bertanggung jawab atas kebenaran foto, deskripsi, harga, dan '
          'kondisi barang. Penyewa wajib memakai barang dengan wajar dan '
          'mengembalikannya tepat waktu.',
      'Pengajuan sewa baru mengikat setelah disetujui pemilik. Tanggal yang '
          'sudah disetujui dikunci untuk penyewa lain.',
    ]),
    BagianDokumen('Pembayaran COD', [
      'Tidak ada pembayaran di dalam aplikasi. Penyewa membayar tunai atau '
          'transfer langsung ke pemilik saat serah terima (COD) di area '
          'kampus.',
      'Pemilik mencatat pembayaran di checklist ambil barang. Serah terima '
          'baru bisa disetujui pemilik setelah pembayaran diterima.',
    ]),
    BagianDokumen('Denda keterlambatan', [
      'Pemilik boleh menetapkan denda per hari keterlambatan. Besarnya '
          'tertulis di halaman barang sebelum kamu mengajukan sewa.',
      'Denda = jumlah hari terlambat × denda per hari, dibayar ke pemilik '
          'saat pengembalian dan dicatat di checklist pengembalian.',
    ]),
    BagianDokumen('Pembatalan', [
      'Pengajuan yang belum disetujui bisa dibatalkan kapan saja.',
      'Sewa yang sudah disetujui bisa dibatalkan penyewa atau pemilik '
          'dengan alasan. Sampai H-1 sebelum tanggal ambil, pembatalan bebas.',
      'Pembatalan di hari H tetap boleh, tetapi tercatat di profil sebagai '
          'pembatalan mendadak dan terlihat oleh pengguna lain. Sewa yang '
          'sedang berlangsung tidak bisa dibatalkan.',
    ]),
    BagianDokumen('Checklist, laporan & sengketa', [
      'Kondisi barang dicatat bersama di checklist serah terima dan '
          'pengembalian, lengkap dengan foto. Checklist ini jadi acuan kalau '
          'ada masalah.',
      'Kalau ada kerusakan, pemilik bisa membuat laporan dengan usulan '
          'penyelesaian. Penyewa boleh menerima usulan atau mengajukan '
          'banding; banding ditinjau tim HobbySwap.',
    ]),
    BagianDokumen('Barter', [
      'Tukar pinjam barang antar pengguna (barter) sedang disiapkan. '
          'Aturannya akan dirinci saat fiturnya dirilis.',
    ]),
    BagianDokumen('Yang tidak boleh', [
      'Menyewakan barang ilegal, berbahaya, atau bukan milikmu; memakai '
          'identitas orang lain; mengajak transaksi di luar area kampus yang '
          'aman; dan melecehkan pengguna lain.',
      'Pelanggaran bisa berujung pembatasan atau penutupan akun.',
    ]),
    BagianDokumen('Perubahan & kontak', [
      'Syarat ini bisa berubah. Perubahan penting akan kami umumkan di '
          'aplikasi sebelum berlaku.',
      'Ada pertanyaan? Hubungi kami lewat menu Bantuan & laporkan masalah '
          'di tab Profil.',
    ]),
  ],
);

final kebijakanPrivasi = DokumenHukum(
  judul: 'Kebijakan Privasi',
  berlakuSejak: DateTime(2026, 10, 1),
  bagian: const [
    BagianDokumen('Data yang kami kumpulkan', [
      'Data akun: nama, NIM, email kampus, fakultas/prodi, foto profil, dan '
          'bio yang kamu isi sendiri.',
      'Data transaksi: barang, pengajuan, checklist, pesan, ulasan, dan '
          'laporan yang kamu buat di HobbySwap.',
    ]),
    BagianDokumen('KTM & selfie hanya untuk verifikasi', [
      'Foto KTM dan selfie hanya dipakai tim peninjau untuk memastikan kamu '
          'mahasiswa aktif. Keduanya tidak pernah ditampilkan ke pengguna '
          'lain dan tidak dipakai untuk keperluan lain.',
    ]),
    BagianDokumen('Cara kami memakai data', [
      'Untuk menjalankan fitur sewa, menjaga keamanan, menindaklanjuti '
          'laporan, dan mengirim notifikasi terkait sewamu.',
      'Kami tidak menjual datamu ke pihak lain.',
    ]),
    BagianDokumen('Siapa yang bisa melihat datamu', [
      'Pengguna lain melihat nama, fakultas/prodi, avatar, rating, ulasan, '
          'dan jumlah pembatalan mendadak. NIM, email, dan KTM tidak '
          'ditampilkan.',
      'Isi chat hanya bisa dilihat kedua pihak, kecuali ditinjau tim saat '
          'ada laporan.',
    ]),
    BagianDokumen('Penyimpanan & keamanan', [
      'Data disimpan selama akunmu aktif. Setelah akun dihapus, data '
          'pribadi dihapus, kecuali catatan transaksi yang wajib disimpan '
          'untuk penyelesaian sengketa.',
    ]),
    BagianDokumen('Hak kamu', [
      'Kamu berhak melihat, mengubah, dan menghapus datamu. Ubah profil lewat '
          'Profil → Edit profil; hapus akun lewat Profil → Hapus akun.',
    ]),
    BagianDokumen('Kontak', [
      'Pertanyaan soal privasi bisa dikirim lewat menu Bantuan & laporkan '
          'masalah di tab Profil.',
    ]),
  ],
);

import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/router/app_routes.dart';

import '../helpers/pump_app.dart';
import '../helpers/text_scale.dart';

const gregorian = 'usr-001';
const aulia = 'usr-002';

typedef BukaLayar = Future<void> Function(WidgetTester tester);

BukaLayar ke(String route) =>
    (tester) => goRoute(tester, route);

/// Layar utama: (nama, sesi, cara membuka). Sesi `null` = belum masuk;
/// `buka` null = layar pertama setelah Splash.
final layarUtama = <(String, String?, BukaLayar?)>[
  ('Login', null, null),
  ('Daftar', null, ke(AppRoutes.daftar)),
  ('Verifikasi KTM', aulia, null),
  ('Status verifikasi', gregorian, ke(AppRoutes.verifikasiStatus)),
  ('Beranda', gregorian, null),
  ('Detail barang', gregorian, ke(AppRoutes.barangDetail('itm-001'))),
  (
    'Konfirmasi sewa',
    gregorian,
    ke(AppRoutes.ajukanSewa('itm-001', hPlus(4), hPlus(6))),
  ),
  ('Tawarkan barter', gregorian, ke(AppRoutes.tawarBarter('itm-004'))),
  ('Checklist barter', gregorian, ke(AppRoutes.checklist('bkg-027'))),
  ('Pengajuan terkirim', gregorian, ke(AppRoutes.pengajuanTerkirim('bkg-023'))),
  ('Sewaan Saya', gregorian, ke(AppRoutes.sewaan)),
  ('Sewaan Saya · riwayat', gregorian, ke(AppRoutes.sewaanTab('riwayat'))),
  ('Barang Saya', gregorian, ke(AppRoutes.barangSaya)),
  ('Tambah barang', gregorian, ke(AppRoutes.barangTambah)),
  ('Ubah barang', gregorian, ke(AppRoutes.barangUbah('itm-013'))),
  ('Pengajuan masuk', gregorian, ke(AppRoutes.pengajuanMasuk)),
  ('Checklist', gregorian, ke(AppRoutes.checklist('bkg-022'))),
  ('Rating', gregorian, ke(AppRoutes.rating('bkg-024'))),
  ('Ulasan barang', gregorian, ke(AppRoutes.ulasanBarang('itm-001'))),
  ('Profil', gregorian, ke(AppRoutes.profil)),
  ('Edit profil', gregorian, ke(AppRoutes.profilUbah)),
  ('Ulasan tentangku', gregorian, ke(AppRoutes.profilUlasan)),
  ('Aktivitas', gregorian, ke(AppRoutes.aktivitas)),
  ('Bantuan', gregorian, ke(AppRoutes.bantuan)),
  ('Tentang', gregorian, ke(AppRoutes.tentang)),
  ('Lupa password', null, ke(AppRoutes.lupaPassword)),
  (
    'Reset password',
    null,
    ke(AppRoutes.resetPasswordUntuk('a@students.usu.ac.id')),
  ),
  ('Syarat Layanan', null, ke(AppRoutes.syarat)),
  ('Kebijakan Privasi', gregorian, ke(AppRoutes.privasi)),
  ('Hapus akun', gregorian, ke(AppRoutes.hapusAkun)),
  ('Favoritku', gregorian, ke(AppRoutes.favoritku)),
  ('Laporanku', gregorian, ke(AppRoutes.laporanku)),
  ('Detail laporan', gregorian, ke(AppRoutes.laporanDetail('lpr-001'))),
  (
    'Laporan kerusakan',
    gregorian,
    ke(AppRoutes.laporanBaru(bookingId: 'bkg-024')),
  ),
  (
    'Laporkan pengguna',
    gregorian,
    ke(AppRoutes.laporanBaru(terlaporId: 'usr-003')),
  ),
  ('Pesan', gregorian, ke(AppRoutes.pesan)),
  ('Ruang obrolan', gregorian, ke(AppRoutes.pesanThread('thr-001'))),
  ('Ruang obrolan · pemilik', gregorian, ke(AppRoutes.pesanThread('thr-002'))),
];

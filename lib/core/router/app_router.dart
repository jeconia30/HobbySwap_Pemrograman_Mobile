import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/presentation/aktivitas_page.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/lupa_password_pages.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/booking/presentation/konfirmasi_sewa_page.dart';
import '../../features/booking/presentation/pengajuan_masuk_page.dart';
import '../../features/booking/presentation/pengajuan_terkirim_page.dart';
import '../../features/booking/presentation/sewaan_page.dart';
import '../../features/booking/presentation/tawar_barter_page.dart';
import '../../features/chat/presentation/pesan_page.dart';
import '../../features/chat/presentation/ruang_obrolan_page.dart';
import '../../features/favorit/presentation/favoritku_page.dart';
import '../../features/handover/domain/handover_checklist.dart';
import '../../features/handover/presentation/checklist_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/item/domain/item.dart';
import '../../features/item/presentation/barang_saya_page.dart';
import '../../features/item/presentation/item_detail_page.dart';
import '../../features/item/presentation/item_form_page.dart';
import '../../features/laporan/presentation/laporan_form_page.dart';
import '../../features/laporan/presentation/laporan_pages.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/onboarding/presentation/splash_page.dart';
import '../../features/profile/presentation/edit_profil_page.dart';
import '../../features/profile/presentation/hapus_akun_page.dart';
import '../../features/profile/presentation/profil_page.dart';
import '../../features/support/presentation/bantuan_page.dart';
import '../../features/support/domain/dokumen_hukum.dart';
import '../../features/support/presentation/dokumen_page.dart';
import '../../features/support/presentation/tentang_page.dart';
import '../../features/review/presentation/rating_page.dart';
import '../../features/review/presentation/ulasan_section.dart';
import '../../features/verification/presentation/verifikasi_page.dart';
import '../../features/verification/presentation/verifikasi_status_page.dart';
import '../utils/dates.dart';
import 'app_redirect.dart';
import 'app_routes.dart';
import 'app_shell.dart';

export 'app_routes.dart';

GoRoute _page(String path, GoRouterWidgetBuilder builder) =>
    GoRoute(path: path, builder: builder);

DateTime? _date(String? ymd) {
  final d = ymd == null ? null : DateTime.tryParse(ymd);
  return d == null ? null : dateOnly(d);
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) => authRedirect(
      location: state.matchedLocation,
      status: ref.read(authControllerProvider)?.statusVerifikasi,
    ),
    routes: [
      _page(AppRoutes.splash, (_, _) => const SplashPage()),
      _page(AppRoutes.onboarding, (_, _) => const OnboardingPage()),
      _page(
        AppRoutes.login,
        (_, state) => LoginPage(emailAwal: state.uri.queryParameters['email']),
      ),
      _page(AppRoutes.lupaPassword, (_, _) => const LupaPasswordPage()),
      _page(
        AppRoutes.lupaPasswordCek,
        (_, state) =>
            CekEmailPage(email: state.uri.queryParameters['email'] ?? ''),
      ),
      _page(
        AppRoutes.resetPassword,
        (_, state) =>
            ResetPasswordPage(email: state.uri.queryParameters['email'] ?? ''),
      ),
      _page(AppRoutes.syarat, (_, _) => DokumenPage(dokumen: syaratLayanan)),
      _page(
        AppRoutes.privasi,
        (_, _) => DokumenPage(dokumen: kebijakanPrivasi),
      ),
      _page(AppRoutes.daftar, (_, _) => const RegisterPage()),
      _page(AppRoutes.verifikasi, (_, _) => const VerifikasiPage()),
      _page(AppRoutes.verifikasiStatus, (_, _) => const VerifikasiStatusPage()),
      StatefulShellRoute(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        navigatorContainerBuilder: (context, shell, children) =>
            AnimatedBranchContainer(
                currentIndex: shell.currentIndex, children: children),
        branches: [
          StatefulShellBranch(
            routes: [_page(AppRoutes.beranda, (_, _) => const HomePage())],
          ),
          StatefulShellBranch(
            routes: [
              _page(
                AppRoutes.sewaan,
                (_, state) =>
                    SewaanPage(initialTab: state.uri.queryParameters['tab']),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              _page(AppRoutes.barangSaya, (_, _) => const BarangSayaPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [_page(AppRoutes.profil, (_, _) => const ProfilPage())],
          ),
        ],
      ),
      _page(AppRoutes.aktivitas, (_, _) => const AktivitasPage()),
      _page(AppRoutes.profilUbah, (_, _) => const EditProfilPage()),
      _page(AppRoutes.profilUlasan, (_, _) => const UlasanTentangkuPage()),
      _page(AppRoutes.bantuan, (_, _) => const BantuanPage()),
      _page(AppRoutes.tentang, (_, _) => const TentangPage()),
      _page(AppRoutes.hapusAkun, (_, _) => const HapusAkunPage()),
      _page(AppRoutes.favoritku, (_, _) => const FavoritkuPage()),
      _page(AppRoutes.laporanku, (_, _) => const LaporankuPage()),
      // Harus sebelum /laporan/:id supaya "baru" tidak dianggap id.
      _page(
        AppRoutes.laporanBaruPath,
        (_, state) => LaporanFormPage(
          bookingId: state.uri.queryParameters['booking'],
          terlaporId: state.uri.queryParameters['terlapor'],
          barangId: state.uri.queryParameters['barang'],
        ),
      ),
      _page(
        '/laporan/:id',
        (_, state) => LaporanDetailPage(laporanId: state.pathParameters['id']!),
      ),
      _page(AppRoutes.pesan, (_, _) => const PesanPage()),
      _page(
        '/pesan/:id',
        (_, state) => RuangObrolanPage(threadId: state.pathParameters['id']!),
      ),
      // Harus sebelum /barang/:id supaya "tambah" tidak dianggap id.
      _page(AppRoutes.barangTambah, (_, _) => const ItemFormPage()),
      _page(
        '/barang/:id/ubah',
        (_, state) => ItemFormPage(itemId: state.pathParameters['id']!),
      ),
      _page(AppRoutes.pengajuanMasuk, (_, _) => const PengajuanMasukPage()),
      _page(
        '/barang/:id',
        (_, state) => ItemDetailPage(
          itemId: state.pathParameters['id']!,
          preview: switch (state.extra) {
            final ItemListing l => l,
            _ => null,
          },
        ),
      ),
      _page(
        '/barang/:id/barter',
        (_, state) => TawarBarterPage(itemId: state.pathParameters['id']!),
      ),
      _page(
        '/barang/:id/ajukan',
        (_, state) => KonfirmasiSewaPage(
          itemId: state.pathParameters['id']!,
          mulai: _date(state.uri.queryParameters['mulai']),
          kembali: _date(state.uri.queryParameters['kembali']),
        ),
      ),
      _page(
        '/barang/:id/ulasan',
        (_, state) => UlasanPage(itemId: state.pathParameters['id']!),
      ),
      _page(
        '/sewa/:id/checklist',
        (_, state) => ChecklistPage(
          bookingId: state.pathParameters['id']!,
          initialTahap: state.uri.queryParameters['tahap'] == 'akhir'
              ? TahapChecklist.akhir
              : TahapChecklist.awal,
        ),
      ),
      _page(
        '/sewa/:id/rating',
        (_, state) => RatingPage(bookingId: state.pathParameters['id']!),
      ),
      _page(
        '/pengajuan-terkirim/:id',
        (_, state) =>
            PengajuanTerkirimPage(bookingId: state.pathParameters['id']!),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

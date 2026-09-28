import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/router/app_redirect.dart';
import 'package:hobby_swab/core/router/app_routes.dart';
import 'package:hobby_swab/features/auth/domain/user.dart';

const belum = StatusVerifikasi.belum;
const menunggu = StatusVerifikasi.menunggu;
const aktif = StatusVerifikasi.terverifikasi;

void main() {
  group('authRedirect', () {
    test('belum login ke rute terlindung → /login', () {
      for (final loc in [
        AppRoutes.verifikasi,
        AppRoutes.verifikasiStatus,
        AppRoutes.beranda,
        AppRoutes.sewaan,
        AppRoutes.barangSaya,
        AppRoutes.profil,
        AppRoutes.aktivitas,
        AppRoutes.barangTambah,
        AppRoutes.barangDetail('itm-001'),
      ]) {
        expect(authRedirect(location: loc, status: null), AppRoutes.login,
            reason: loc);
      }
    });

    test('belum login ke login/daftar/splash/onboarding tidak dialihkan', () {
      for (final loc in [
        AppRoutes.login,
        AppRoutes.daftar,
        AppRoutes.splash,
        AppRoutes.onboarding,
      ]) {
        expect(authRedirect(location: loc, status: null), isNull, reason: loc);
      }
    });

    test('sudah login ke /login atau /daftar: belum → /verifikasi', () {
      expect(authRedirect(location: AppRoutes.login, status: belum),
          AppRoutes.verifikasi);
      expect(authRedirect(location: AppRoutes.daftar, status: belum),
          AppRoutes.verifikasi);
    });

    test('sudah login ke /login atau /daftar: menunggu/aktif → /beranda', () {
      for (final s in [menunggu, aktif]) {
        expect(authRedirect(location: AppRoutes.login, status: s),
            AppRoutes.beranda);
        expect(authRedirect(location: AppRoutes.daftar, status: s),
            AppRoutes.beranda);
      }
    });

    test('user belum tetap boleh ke /beranda (jelajah dulu)', () {
      expect(authRedirect(location: AppRoutes.beranda, status: belum), isNull);
      expect(authRedirect(location: AppRoutes.verifikasi, status: belum), isNull);
    });

    test('form & status verifikasi mengikuti status', () {
      expect(authRedirect(location: AppRoutes.verifikasiStatus, status: belum),
          AppRoutes.verifikasi);
      for (final s in [menunggu, aktif]) {
        expect(authRedirect(location: AppRoutes.verifikasi, status: s),
            AppRoutes.verifikasiStatus);
        expect(
            authRedirect(location: AppRoutes.verifikasiStatus, status: s), isNull);
        expect(authRedirect(location: AppRoutes.beranda, status: s), isNull);
      }
    });
  });

  group('postAuthDestination', () {
    test('belum → /verifikasi, lainnya → /beranda', () {
      expect(postAuthDestination(belum), AppRoutes.verifikasi);
      expect(postAuthDestination(menunggu), AppRoutes.beranda);
      expect(postAuthDestination(aktif), AppRoutes.beranda);
    });
  });

  group('splashDestination', () {
    test('belum onboarding selalu ke /onboarding', () {
      for (final s in [null, belum, menunggu, aktif]) {
        expect(splashDestination(onboardingSeen: false, status: s),
            AppRoutes.onboarding);
      }
    });

    test('setelah onboarding: tanpa sesi → /login, lalu sesuai status', () {
      expect(splashDestination(onboardingSeen: true, status: null),
          AppRoutes.login);
      expect(splashDestination(onboardingSeen: true, status: belum),
          AppRoutes.verifikasi);
      expect(splashDestination(onboardingSeen: true, status: menunggu),
          AppRoutes.beranda);
      expect(splashDestination(onboardingSeen: true, status: aktif),
          AppRoutes.beranda);
    });
  });
}

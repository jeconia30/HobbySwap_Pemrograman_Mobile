import '../../features/auth/domain/user.dart';
import 'app_routes.dart';

/// Tujuan setelah masuk/sesi pulih: yang belum verifikasi diarahkan ke form KTM.
String postAuthDestination(StatusVerifikasi status) =>
    status == StatusVerifikasi.belum ? AppRoutes.verifikasi : AppRoutes.beranda;

/// Aturan akses rute; `null` = boleh lanjut ke [location].
/// [status] `null` berarti belum masuk.
String? authRedirect({required String location, required StatusVerifikasi? status}) {
  if (status == null) {
    return AppRoutes.public.contains(location) ? null : AppRoutes.login;
  }
  if (AppRoutes.guestOnly.contains(location)) return postAuthDestination(status);
  final submitted = status != StatusVerifikasi.belum;
  if (location == AppRoutes.verifikasi && submitted) {
    return AppRoutes.verifikasiStatus;
  }
  if (location == AppRoutes.verifikasiStatus && !submitted) {
    return AppRoutes.verifikasi;
  }
  // Konfirmasi sewa hanya untuk akun terverifikasi (UI memakai requireVerified;
  // ini pengaman untuk deep link).
  final ajukan = AppRoutes.ajukanPattern.firstMatch(location);
  if (ajukan != null && status != StatusVerifikasi.terverifikasi) {
    return AppRoutes.barangDetail(ajukan.group(1)!);
  }
  if (AppRoutes.formBarangPattern.hasMatch(location) &&
      status != StatusVerifikasi.terverifikasi) {
    return AppRoutes.barangSaya;
  }
  return null;
}

/// Tujuan setelah Splash selesai memulihkan sesi.
String splashDestination({
  required bool onboardingSeen,
  required StatusVerifikasi? status,
}) {
  if (!onboardingSeen) return AppRoutes.onboarding;
  return status == null ? AppRoutes.login : postAuthDestination(status);
}

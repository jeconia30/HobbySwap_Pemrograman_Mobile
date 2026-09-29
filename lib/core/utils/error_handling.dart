import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../widgets/app_error_screen.dart';

/// Menangkap semua error yang tidak tertangani. Untuk sekarang hanya dicatat
/// lewat [debugPrint] (nanti diteruskan ke layanan pelaporan crash).
///
/// [layarRamah] mengganti layar merah bawaan dengan [AppErrorScreen]; default
/// hanya di release build supaya detail error tetap terlihat saat debug.
void pasangPenangananError({bool layarRamah = kReleaseMode}) {
  if (layarRamah) {
    ErrorWidget.builder = (details) => const AppErrorScreen();
  }
  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exceptionAsString()}\n${details.stack}');
    if (kDebugMode) FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Error tak tertangani: $error\n$stack');
    return true;
  };
}

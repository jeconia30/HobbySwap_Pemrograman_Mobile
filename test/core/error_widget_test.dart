import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hobby_swab/core/router/app_routes.dart';
import 'package:hobby_swab/core/theme/app_theme.dart';
import 'package:hobby_swab/core/utils/error_handling.dart';
import 'package:hobby_swab/core/widgets/app_error_screen.dart';

class _Rusak extends StatelessWidget {
  const _Rusak();

  @override
  Widget build(BuildContext context) => throw StateError('sengaja rusak');
}

void main() {
  testWidgets('ErrorWidget kustom muncul saat widget melempar error',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final builderAwal = ErrorWidget.builder;
    final onErrorAwal = FlutterError.onError;
    final platformAwal = PlatformDispatcher.instance.onError;
    final tertangkap = <FlutterErrorDetails>[];

    try {
      pasangPenangananError(layarRamah: true);
      // Catat juga di sini supaya error yang disengaja tidak menggagalkan test.
      final handler = FlutterError.onError!;
      FlutterError.onError = (d) {
        tertangkap.add(d);
        handler(d);
      };

      final router = GoRouter(
        initialLocation: '/rusak',
        routes: [
          GoRoute(path: '/rusak', builder: (_, _) => const _Rusak()),
          GoRoute(
            path: AppRoutes.beranda,
            builder: (_, _) => const Scaffold(body: Text('Beranda aman')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light(), routerConfig: router));
      await tester.pumpAndSettle();

      expect(tertangkap.single.exception, isA<StateError>());
      expect(find.byType(AppErrorScreen), findsOneWidget);
      expect(find.text('Ada yang tidak beres'), findsOneWidget);
      expect(find.text('Coba buka ulang halaman ini'), findsOneWidget);

      await tester.tap(find.text('Kembali ke Beranda'));
      await tester.pumpAndSettle();
      expect(find.text('Beranda aman'), findsOneWidget);
    } finally {
      ErrorWidget.builder = builderAwal;
      FlutterError.onError = onErrorAwal;
      PlatformDispatcher.instance.onError = platformAwal;
    }
  });

  test('tanpa layar ramah (debug), ErrorWidget bawaan tidak diganti', () {
    final builderAwal = ErrorWidget.builder;
    final onErrorAwal = FlutterError.onError;
    final platformAwal = PlatformDispatcher.instance.onError;
    try {
      pasangPenangananError(layarRamah: false);
      expect(ErrorWidget.builder, same(builderAwal));
    } finally {
      FlutterError.onError = onErrorAwal;
      PlatformDispatcher.instance.onError = platformAwal;
    }
  });
}

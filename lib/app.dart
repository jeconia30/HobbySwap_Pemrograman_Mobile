import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'core/router/app_router.dart';
import 'core/storage/settings_storage.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

class HobbySwapApp extends ConsumerWidget {
  const HobbySwapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'HobbySwap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(settingsControllerProvider.select((s) => s.themeMode)),
      routerConfig: ref.watch(appRouterProvider),
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => _SkeletonTheme(child: child!),
    );
  }
}

/// Warna skeleton dari token; kilau dimatikan saat animasi sistem dimatikan.
class _SkeletonTheme extends StatelessWidget {
  const _SkeletonTheme({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final diam = MediaQuery.disableAnimationsOf(context);
    return SkeletonizerConfig(
      data: SkeletonizerConfigData(
        effectResolver: (brightness) {
          final gelap = brightness == Brightness.dark;
          final dasar = gelap ? AppPalette.darkSurfaceAlt : AppPalette.lightSurfaceAlt;
          if (diam) return SolidColorEffect(color: dasar);
          return ShimmerEffect(
            baseColor: dasar,
            highlightColor: gelap ? AppPalette.darkSurface : AppPalette.lightSurface,
          );
        },
      ),
      child: child,
    );
  }
}

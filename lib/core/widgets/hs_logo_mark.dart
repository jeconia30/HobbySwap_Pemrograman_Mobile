import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Logo HobbySwap: tile [AppAssets.logoTile], atau logo lengkap
/// [AppAssets.logoSplash] untuk Splash.
class HsLogoMark extends StatelessWidget {
  const HsLogoMark({super.key, this.size = AppSizes.logoMark})
      : _onSplash = false;

  /// Logo lengkap (tile + tulisan) dengan ukuran & posisi sama seperti splash
  /// native, tanpa bayangan karena latar Splash selalu gelap.
  const HsLogoMark.splash({super.key})
      : size = AppSizes.splashLogo,
        _onSplash = true;

  final double size;
  final bool _onSplash;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return Semantics(
      label: 'Logo HobbySwap',
      image: true,
      child: DecoratedBox(
        // Tile krem perlu bayangan halus supaya tidak tenggelam di latar krem.
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(size * AppSizes.logoTileCornerRatio),
          boxShadow: light && !_onSplash
              ? const [
                  BoxShadow(
                    color: AppPalette.logoShadow,
                    blurRadius: AppSizes.logoShadowBlur,
                    offset: Offset(0, AppSizes.logoShadowOffset),
                  ),
                ]
              : null,
        ),
        child: Image.asset(
          _onSplash ? AppAssets.logoSplash : AppAssets.logoTile,
          width: size,
          height: size,
          cacheWidth: (size * dpr).round(),
          filterQuality: FilterQuality.medium,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}

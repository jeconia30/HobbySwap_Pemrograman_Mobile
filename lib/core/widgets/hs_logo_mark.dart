import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class HsLogoMark extends StatelessWidget {
  const HsLogoMark({
    super.key,
    this.size = AppSizes.logoMark,
    this.radius = AppRadius.logoMark,
    this.background,
    this.hColor,
    this.sColor,
  });

  /// Versi besar untuk Splash: tile krem, warna tetap di kedua mode.
  const HsLogoMark.splash({super.key})
      : size = AppSizes.logoMarkLarge,
        radius = AppRadius.logoMarkLarge,
        background = AppPalette.lightBg,
        hColor = AppPalette.lightAccent,
        sColor = AppPalette.brandMid;

  final double size;
  final double radius;

  /// Default: accent, on-accent, dan brandLeaf dari tema.
  final Color? background;
  final Color? hColor;
  final Color? sColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    final base = Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontSize: size * 0.42,
          height: 1,
          letterSpacing: -size * 0.02,
        );

    return Semantics(
      label: 'Logo HobbySwap',
      image: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background ?? scheme.primary,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: ExcludeSemantics(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: 'H',
                  style: base?.copyWith(color: hColor ?? scheme.onPrimary)),
              TextSpan(
                  text: 'S',
                  style: base?.copyWith(color: sColor ?? colors.brandLeaf)),
            ]),
            textScaler: TextScaler.noScaling,
          ),
        ),
      ),
    );
  }
}

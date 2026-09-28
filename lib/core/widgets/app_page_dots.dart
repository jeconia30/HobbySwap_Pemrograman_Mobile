import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Indikator halaman: titik aktif melebar jadi pill.
class AppPageDots extends StatelessWidget {
  const AppPageDots({
    super.key,
    required this.count,
    required this.index,
    this.dotSize = AppSizes.pageDot,
    this.activeWidth = AppSizes.pageDotActive,
    this.activeColor,
    this.inactiveColor,
  });

  const AppPageDots.splash({super.key, required this.count, required this.index})
      : dotSize = AppSizes.splashDot,
        activeWidth = AppSizes.splashDotActive,
        activeColor = AppPalette.brandLeaf,
        inactiveColor = AppPalette.splashDotInactive;

  final int count;
  final int index;
  final double dotSize;
  final double activeWidth;

  /// Default: accent dan border dari tema.
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? Theme.of(context).colorScheme.primary;
    final inactive = inactiveColor ?? AppColors.of(context).border;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppDurations.short;

    return Semantics(
      label: 'Halaman ${index + 1} dari $count',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) SizedBox(width: dotSize * 0.75),
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                width: i == index ? activeWidth : dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: i == index ? active : inactive,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(AppRadius.pill)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Ilustrasi onboarding dari tile membulat (tanpa aset gambar).
/// Geometri di file ini adalah konten ilustrasi, bukan token layout.
enum OnboardingIllustration { rent, verified, lend }

const _canvas = Size(300, 260);
const _circle = 230.0;

class OnboardingArt extends StatelessWidget {
  const OnboardingArt(this.kind, {super.key});

  final OnboardingIllustration kind;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);

    final children = switch (kind) {
      OnboardingIllustration.rent => [
          _place(42, 58, _Tile(118, 118, -6,
              color: scheme.primary,
              icon: Icons.photo_camera_rounded,
              iconColor: scheme.onPrimary)),
          _place(170, 20, _Tile(96, 96, 6,
              color: colors.accentMid,
              icon: Icons.festival_rounded,
              iconColor: scheme.onPrimary)),
          _place(160, 140, _Tile(104, 86, -3,
              color: scheme.surface,
              bordered: true,
              icon: Icons.sports_esports_rounded,
              iconColor: scheme.onSurface)),
          _place(16, 196, const _VerifiedChip()),
        ],
      OnboardingIllustration.verified => [
          _place(30, 70, const _KtmCard()),
          _place(186, 26, _Tile(92, 92, 8,
              color: scheme.primary,
              icon: Icons.verified_user_rounded,
              iconColor: scheme.onPrimary)),
        ],
      OnboardingIllustration.lend => [
          _place(52, 48, _Tile(132, 132, -6,
              color: scheme.primary,
              icon: Icons.backpack_rounded,
              iconColor: scheme.onPrimary)),
          _place(178, 136, _Tile(84, 84, 8,
              color: colors.accentMid,
              icon: Icons.add_rounded,
              iconColor: scheme.onPrimary)),
        ],
    };

    return ExcludeSemantics(
      child: SizedBox.fromSize(
        size: _canvas,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Container(
                width: _circle,
                height: _circle,
                decoration: BoxDecoration(
                    color: colors.accentSoft, shape: BoxShape.circle),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  static Widget _place(double left, double top, Widget child) =>
      Positioned(left: left, top: top, child: child);
}

List<BoxShadow> _softShadow(BuildContext context) {
  final theme = Theme.of(context);
  if (theme.brightness == Brightness.dark) return const [];
  return [
    BoxShadow(
      color: theme.colorScheme.shadow.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}

class _Tile extends StatelessWidget {
  const _Tile(
    this.width,
    this.height,
    this.degrees, {
    required this.color,
    required this.icon,
    required this.iconColor,
    this.bordered = false,
  });

  final double width;
  final double height;
  final double degrees;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: degrees * math.pi / 180,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppRadius.cardAll,
          border: bordered
              ? Border.all(color: AppColors.of(context).border, width: 1.5)
              : null,
          boxShadow: _softShadow(context),
        ),
        child: Icon(icon, color: iconColor, size: math.min(width, height) * 0.44),
      ),
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verified = AppColors.of(context).verified;
    return Transform.rotate(
      angle: -3 * math.pi / 180,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
              verified.withValues(alpha: 0.16), theme.colorScheme.surface),
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
          border: Border.all(color: verified, width: 1.5),
          boxShadow: _softShadow(context),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: verified, size: AppSizes.iconSm),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'KTM terverifikasi',
              textScaler: TextScaler.noScaling,
              style: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _KtmCard extends StatelessWidget {
  const _KtmCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);

    Widget bar(double width, Color color) => Container(
          width: width,
          height: AppSpacing.sm,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: color,
            borderRadius:
                const BorderRadius.all(Radius.circular(AppRadius.pill)),
          ),
        );

    return Transform.rotate(
      angle: -5 * math.pi / 180,
      child: Container(
        width: 206,
        height: 132,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: colors.border, width: 1.5),
          boxShadow: _softShadow(context),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 72,
              decoration: BoxDecoration(
                color: colors.accentSoft,
                borderRadius: AppRadius.inputAll,
              ),
              child: Icon(Icons.person_rounded,
                  color: colors.accentText, size: 36),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KTM',
                    textScaler: TextScaler.noScaling,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.accentText, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  bar(96, scheme.primary),
                  bar(80, colors.surfaceAlt),
                  bar(60, colors.surfaceAlt),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

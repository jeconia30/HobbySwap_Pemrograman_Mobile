import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/app_avatar.dart';
import '../domain/review.dart';

/// Satu ulasan: avatar, nama, bintang, tanggal, teks, dan tag.
class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.detail});

  final ReviewDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final r = detail.review;

    return Semantics(
      label: '${detail.dari.nama}, ${r.bintang} dari 5 bintang, '
          '${formatTanggalPendek(r.tanggal)}. ${r.teks}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                  user: detail.dari,
                  size: AppSizes.avatarReview,
                  showBadge: false),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.dari.nama, style: text.titleMedium),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.sm,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 1; i <= 5; i++)
                              Icon(
                                i <= r.bintang
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: AppSizes.iconXs,
                                color: i <= r.bintang
                                    ? AppPalette.statsStar
                                    : colors.border,
                              ),
                          ],
                        ),
                        Text(formatTanggalPendek(r.tanggal),
                            style: text.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (r.teks.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(r.teks, style: text.bodyMedium),
          ],
          if (r.tag.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final t in r.tag)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs / 2),
                    decoration: BoxDecoration(
                      color: colors.accentSoft,
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: Text(t,
                        style: text.labelSmall?.copyWith(
                            color: colors.accentText,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

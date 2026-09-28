import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'dashed_border.dart';

/// Slot unggah (KTM, selfie, foto barang). Kosong = kotak putus-putus;
/// terisi = kartu dengan [preview], judul, status, dan tombol "Ganti".
class AppUploadSlot extends StatelessWidget {
  const AppUploadSlot({
    super.key,
    required this.icon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.filledTitle,
    required this.filledStatus,
    required this.onTap,
    this.preview,
    this.enabled = true,
  });

  final IconData icon;
  final String emptyTitle;
  final String emptySubtitle;
  final String filledTitle;
  final String filledStatus;

  /// Pratinjau isi slot; `null` = slot kosong.
  final Widget? preview;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) =>
      preview == null ? _empty(context) : _filled(context);

  Widget _empty(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return Semantics(
      button: true,
      enabled: enabled,
      label: '$emptyTitle. $emptySubtitle',
      child: ExcludeSemantics(
        child: DashedBorder(
          radius: AppRadius.card,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: AppRadius.cardAll,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: AppSizes.iconTile,
                      height: AppSizes.iconTile,
                      decoration: BoxDecoration(
                        color: colors.accentSoft,
                        borderRadius: AppRadius.inputAll,
                      ),
                      child: Icon(icon,
                          color: colors.accentText, size: AppSizes.iconLg),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(emptyTitle, style: theme.textTheme.titleMedium),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            emptySubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filled(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardCompact),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.previewAll,
            child: SizedBox(
              width: AppSizes.previewWidth,
              height: AppSizes.previewHeight,
              child: ExcludeSemantics(child: preview),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(filledTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: colors.verified, size: AppSizes.iconXs),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        filledStatus,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.verified,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Semantics(
            label: 'Ganti $filledTitle',
            button: true,
            excludeSemantics: true,
            child: TextButton(
              onPressed: enabled ? onTap : null,
              child: const Text('Ganti'),
            ),
          ),
        ],
      ),
    );
  }
}

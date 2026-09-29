import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Chip pill untuk filter/kategori. Aktif = accent; lainnya = surface + border.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.showCheck = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Pilihan ganda: tampilkan ikon centang saat terpilih.
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);

    // Visual 38 dp, area sentuh tetap 48 dp (padding atas-bawah ikut bisa ditekan).
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: (AppSizes.minTapTarget - AppSizes.chip) / 2,
          ),
          child: Material(
            color: selected ? scheme.primary : scheme.surface,
            shape: StadiumBorder(
              side: BorderSide(
                color: selected ? scheme.primary : colors.border,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppSizes.chip),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showCheck && selected) ...[
                        Icon(
                          Icons.check_rounded,
                          size: AppSizes.iconXs,
                          color: scheme.onPrimary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: selected
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

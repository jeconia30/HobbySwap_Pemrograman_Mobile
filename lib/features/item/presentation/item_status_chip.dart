import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/dates.dart';
import '../domain/item.dart';

/// Chip status barang milik sendiri (Tersedia / Disewa / Dibarter / Nonaktif).
class ItemStatusChip extends StatelessWidget {
  const ItemStatusChip(this.status, {super.key, this.sampai});

  final ItemStatus status;

  /// Tanggal kembali (barang yang sedang dibarter).
  final DateTime? sampai;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final (Color bg, Color fg) = switch (status) {
      ItemStatus.tersedia => (
          colors.verified.withValues(alpha: 0.16),
          colors.verified
        ),
      ItemStatus.disewa || ItemStatus.dibarter => (
          colors.accentSoft,
          colors.accentText
        ),
      ItemStatus.nonaktif => (
          colors.surfaceAlt,
          theme.colorScheme.onSurfaceVariant
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + AppSpacing.xs / 2,
          vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.pillAll),
      child: Text(
        status == ItemStatus.dibarter && sampai != null
            ? '${status.label} · kembali ${formatTanggalPendek(sampai!)}'
            : status.label,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelSmall
            ?.copyWith(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}

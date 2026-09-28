import 'package:flutter/material.dart';

import '../../features/booking/domain/booking.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Pill status sewa: titik + label, latar warna status 16%.
/// Warna mengikuti DESIGN §2.1; label teks selalu ada (bukan warna saja).
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final StatusBooking status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final color = switch (status) {
      StatusBooking.menunggu => colors.warning,
      StatusBooking.disetujui || StatusBooking.berlangsung =>
        theme.colorScheme.primary,
      StatusBooking.selesai => colors.verified,
      StatusBooking.ditolak || StatusBooking.dibatalkan =>
        theme.colorScheme.error,
    };

    return Semantics(
      label: 'Status: ${status.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: AppRadius.pillAll,
        ),
        // Mengecil (bukan overflow) di kolom sempit dengan font besar.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (status == StatusBooking.selesai)
                Icon(Icons.check_rounded, size: AppSizes.iconXs, color: color)
              else
                Container(
                  width: AppSpacing.sm,
                  height: AppSpacing.sm,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              const SizedBox(width: AppSpacing.tight),
              Text(
                status.label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

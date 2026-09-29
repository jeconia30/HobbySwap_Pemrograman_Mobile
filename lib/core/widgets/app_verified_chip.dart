import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../constants/app_strings.dart';

/// Badge "Terverifikasi": ikon centang + teks (bukan warna saja).
class AppVerifiedChip extends StatelessWidget {
  const AppVerifiedChip({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs / 2),
      decoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: AppRadius.pillAll,
      ),
      // Mengecil (bukan overflow) kalau ruang di sebelah nama sangat sempit.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded,
                size: AppSizes.iconXs, color: colors.verified),
            const SizedBox(width: AppSpacing.xs),
            Text(
              AppTeks.terverifikasi,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.verified, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

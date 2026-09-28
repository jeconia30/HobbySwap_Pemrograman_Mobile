import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_back_button.dart';
import 'app_step_progress.dart';

/// Kepala alur bertahap: tombol kembali, "Langkah x dari y", dan progress.
class AppStepHeader extends StatelessWidget {
  const AppStepHeader({
    super.key,
    required this.current,
    required this.total,
    this.onBack,
    this.backTooltip = 'Kembali',
  });

  final int current;
  final int total;

  /// `null` = tanpa tombol kembali.
  final VoidCallback? onBack;
  final String backTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = Flexible(
      child: ExcludeSemantics(
        child: Text(
          'Langkah $current dari $total',
          textAlign: onBack == null ? TextAlign.start : TextAlign.end,
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          child: Row(
            mainAxisAlignment: onBack == null
                ? MainAxisAlignment.start
                : MainAxisAlignment.spaceBetween,
            children: [
              if (onBack != null) ...[
                AppBackButton(tooltip: backTooltip, onPressed: onBack),
                const SizedBox(width: AppSpacing.sm),
              ],
              label,
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppStepProgress(total: total, current: current),
      ],
    );
  }
}

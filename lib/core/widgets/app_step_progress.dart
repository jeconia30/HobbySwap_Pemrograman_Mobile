import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Progress bersegmen untuk alur bertahap. [current] dimulai dari 1.
class AppStepProgress extends StatelessWidget {
  const AppStepProgress({super.key, required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    final active = Theme.of(context).colorScheme.primary;
    final inactive = AppColors.of(context).border;

    return Semantics(
      label: 'Langkah $current dari $total',
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var i = 1; i <= total; i++) ...[
              if (i > 1) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : AppDurations.short,
                  height: AppSizes.progressBar,
                  decoration: BoxDecoration(
                    color: i <= current ? active : inactive,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(AppRadius.pill)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

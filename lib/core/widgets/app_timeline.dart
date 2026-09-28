import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum AppTimelineState { done, current, pending }

@immutable
class AppTimelineStep {
  const AppTimelineStep(this.title, this.state);

  final String title;
  final AppTimelineState state;
}

/// Timeline vertikal. Status disampaikan lewat bentuk + label, bukan warna saja.
class AppTimeline extends StatelessWidget {
  const AppTimeline({super.key, required this.steps});

  final List<AppTimelineStep> steps;

  static String _stateLabel(AppTimelineState s) => switch (s) {
        AppTimelineState.done => 'Selesai',
        AppTimelineState.current => 'Sedang berjalan',
        AppTimelineState.pending => 'Belum',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Semantics(
            label: '${steps[i].title}, ${_stateLabel(steps[i].state)}',
            child: ExcludeSemantics(
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: AppSizes.timelineMarker,
                      child: Column(
                        children: [
                          _Marker(state: steps[i].state),
                          if (i < steps.length - 1)
                            Expanded(
                              child: Container(
                                width: AppSizes.dashedStroke,
                                margin: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.xs),
                                color: steps[i].state == AppTimelineState.done
                                    ? colors.verified
                                    : colors.border,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: i < steps.length - 1 ? AppSpacing.xl : 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              steps[i].title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: steps[i].state == AppTimelineState.pending
                                    ? theme.colorScheme.onSurfaceVariant
                                    : null,
                              ),
                            ),
                            if (steps[i].state == AppTimelineState.current)
                              Text(
                                _stateLabel(steps[i].state),
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.state});

  final AppTimelineState state;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox.square(
      dimension: AppSizes.timelineMarker,
      child: switch (state) {
        AppTimelineState.done => Icon(Icons.check_circle_rounded,
            color: colors.verified, size: AppSizes.timelineMarker),
        AppTimelineState.current => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.warning.withValues(alpha: 0.2),
            ),
            alignment: Alignment.center,
            child: Container(
              width: AppSpacing.md,
              height: AppSpacing.md,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: colors.warning),
            ),
          ),
        AppTimelineState.pending => Container(
            margin: const EdgeInsets.all(AppSpacing.xs / 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: colors.border, width: AppSizes.dashedStroke),
            ),
          ),
      },
    );
  }
}

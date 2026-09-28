import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

@immutable
class AppSegment {
  const AppSegment(this.label, {this.enabled = true, this.key});

  final String label;
  final bool enabled;
  final Key? key;
}

/// Segmented control: latar surfaceAlt radius 16; segmen aktif surface +
/// bayangan halus. Segmen nonaktif redup dan tidak bisa ditekan.
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<AppSegment> segments;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppDurations.short;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: AppRadius.noteAll,
      ),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++)
            Expanded(
              child: Semantics(
                key: segments[i].key,
                button: true,
                selected: i == selected,
                enabled: segments[i].enabled,
                label: segments[i].label,
                excludeSemantics: true,
                child: Opacity(
                  opacity: segments[i].enabled ? 1 : 0.4,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: segments[i].enabled && i != selected
                        ? () => onChanged(i)
                        : null,
                    child: AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      constraints: const BoxConstraints(
                          minHeight: AppSizes.minTapTarget - AppSpacing.xs * 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == selected ? scheme.surface : null,
                        borderRadius: AppRadius.inputAll,
                        boxShadow: i == selected &&
                                theme.brightness == Brightness.light
                            ? [
                                BoxShadow(
                                  color: scheme.shadow.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        segments[i].label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: i == selected
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant,
                          fontWeight:
                              i == selected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

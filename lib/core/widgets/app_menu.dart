import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';
import 'app_press_scale.dart';

/// Label grup menu: huruf kapital kecil, text-secondary.
class AppMenuLabel extends StatelessWidget {
  const AppMenuLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs, AppSpacing.xl, AppSpacing.xs, AppSpacing.sm),
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: theme.textTheme.labelSmall
              ?.merge(AppTextStyles.groupLabel)
              .copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

/// Satu kartu berisi beberapa [AppMenuRow], dipisah garis tipis.
class AppMenuCard extends StatelessWidget {
  const AppMenuCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.only(
                    left: AppSpacing.lg + AppSizes.menuIcon + AppSpacing.md),
                child: Divider(),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Baris menu: tile ikon, label, nilai opsional, lalu chevron (atau [trailing]).
class AppMenuRow extends StatelessWidget {
  const AppMenuRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.valueColor,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;

  /// Mengganti chevron (mis. [Switch]).
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final fg = destructive ? scheme.error : colors.accentText;

    final row = MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.menuRow),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: AppSizes.menuIcon,
                  height: AppSizes.menuIcon,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(AppRadius.menuIcon)),
                  ),
                  child: Icon(icon, size: AppSizes.iconSm, color: fg),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium
                        ?.merge(AppTextStyles.menuLabel)
                        .copyWith(color: destructive ? scheme.error : null),
                  ),
                ),
                if (value != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      value!,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: valueColor ?? scheme.onSurfaceVariant,
                        fontWeight: valueColor != null ? FontWeight.w700 : null,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: AppSpacing.xs),
                trailing ??
                    (onTap == null
                        ? const SizedBox.shrink()
                        : Icon(Icons.chevron_right_rounded,
                            color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
    return AppPressScale(enabled: onTap != null, child: row);
  }
}

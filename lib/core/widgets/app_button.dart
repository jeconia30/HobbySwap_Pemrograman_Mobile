import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_press_scale.dart';

/// [danger] hanya untuk konfirmasi aksi yang tidak bisa dibatalkan (hapus, tolak).
enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.compact = false,
  });

  final String label;

  /// `null` = nonaktif (opasitas 0.4).
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final Widget? trailingIcon;

  /// Tombol kecil (selebar isinya, tinggi 48) untuk di dalam kartu/gelembung.
  final bool compact;


  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final (Color bg, Color fg, BorderSide side) = switch (variant) {
      AppButtonVariant.primary => (scheme.primary, scheme.onPrimary, BorderSide.none),
      AppButtonVariant.secondary => (colors.surfaceAlt, scheme.onSurface, BorderSide.none),
      AppButtonVariant.outline =>
        (AppPalette.transparent, scheme.onSurface, BorderSide(color: colors.border, width: 1.5)),
      AppButtonVariant.danger => (scheme.error, scheme.onError, BorderSide.none),
    };

    final disabled = onPressed == null;
    final interactive = !disabled && !isLoading;

    Widget iconOf(Widget icon) => IconTheme.merge(
          data: IconThemeData(color: fg, size: AppSizes.iconSm),
          child: icon,
        );

    final content = isLoading
        ? SizedBox.square(
            key: const ValueKey('loading'),
            dimension: AppSizes.spinner,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: fg,
              semanticsLabel: 'Memproses',
            ),
          )
        : Row(
            key: const ValueKey('label'),
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                iconOf(icon!),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: (compact ? text.labelMedium : text.labelLarge)
                      ?.copyWith(color: fg, fontWeight: FontWeight.w700),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                iconOf(trailingIcon!),
              ],
            ],
          );

    return AnimatedOpacity(
      opacity: disabled ? 0.4 : 1,
      duration: reduceMotion ? Duration.zero : AppDurations.short,
      child: AppPressScale(
        enabled: interactive,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: compact ? AppSizes.minTapTarget : AppSizes.buttonHeight,
            minWidth: compact ? 0 : double.infinity,
          ),
          child: Material(
            color: bg,
            shape: RoundedRectangleBorder(
                borderRadius: AppRadius.buttonAll, side: side),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: interactive ? onPressed : null,
              child: Semantics(
                label: isLoading ? label : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: compact ? AppSpacing.lg : AppSpacing.xl,
                      vertical: compact ? AppSpacing.sm : AppSpacing.md),
                  child: Center(
                    widthFactor: compact ? 1 : null,
                    child: AnimatedSwitcher(
                      duration: reduceMotion ? Duration.zero : AppDurations.short,
                      child: content,
                    ),
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

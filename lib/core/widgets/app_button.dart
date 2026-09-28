import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// [danger] hanya untuk konfirmasi aksi yang tidak bisa dibatalkan (hapus, tolak).
enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
  });

  final String label;

  /// `null` = nonaktif (opasitas 0.4).
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final Widget? trailingIcon;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final (Color bg, Color fg, BorderSide side) = switch (widget.variant) {
      AppButtonVariant.primary => (scheme.primary, scheme.onPrimary, BorderSide.none),
      AppButtonVariant.secondary => (colors.surfaceAlt, scheme.onSurface, BorderSide.none),
      AppButtonVariant.outline =>
        (Colors.transparent, scheme.onSurface, BorderSide(color: colors.border, width: 1.5)),
      AppButtonVariant.danger => (scheme.error, scheme.onError, BorderSide.none),
    };

    final disabled = widget.onPressed == null;
    final interactive = !disabled && !widget.isLoading;

    Widget iconOf(Widget icon) => IconTheme.merge(
          data: IconThemeData(color: fg, size: AppSizes.iconSm),
          child: icon,
        );

    final content = widget.isLoading
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
              if (widget.icon != null) ...[
                iconOf(widget.icon!),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelLarge?.copyWith(color: fg),
                ),
              ),
              if (widget.trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                iconOf(widget.trailingIcon!),
              ],
            ],
          );

    return AnimatedOpacity(
      opacity: disabled ? 0.4 : 1,
      duration: reduceMotion ? Duration.zero : AppDurations.short,
      child: AnimatedScale(
        scale: _pressed && !reduceMotion ? 0.97 : 1,
        duration: AppDurations.press,
        curve: Curves.easeOutCubic,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.buttonHeight,
            minWidth: double.infinity,
          ),
          child: Material(
            color: bg,
            shape: RoundedRectangleBorder(
                borderRadius: AppRadius.buttonAll, side: side),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: interactive ? widget.onPressed : null,
              onHighlightChanged: (v) => setState(() => _pressed = v),
              child: Semantics(
                label: widget.isLoading ? widget.label : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                  child: Center(
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

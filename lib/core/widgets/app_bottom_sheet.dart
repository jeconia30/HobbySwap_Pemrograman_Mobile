import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_press_scale.dart';

/// Bottom sheet standar (radius atas 28, drag handle, safe area).
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          0,
          AppSpacing.pageHorizontal,
          AppSpacing.xl,
        ),
        child: builder(context),
      ),
    ),
  );
}

/// Judul sheet opsional di atas daftar aksi.
class AppSheetTitle extends StatelessWidget {
  const AppSheetTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        header: true,
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

/// Satu baris pilihan di bottom sheet.
class AppSheetAction extends StatelessWidget {
  const AppSheetAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final fg = destructive ? theme.colorScheme.error : colors.accentText;
    final bg = destructive
        ? theme.colorScheme.error.withValues(alpha: 0.12)
        : colors.accentSoft;

    final row = InkWell(
      onTap: onTap,
      borderRadius: AppRadius.inputAll,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.iconTile),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: AppSizes.minTapTarget - AppSpacing.sm,
                height: AppSizes.minTapTarget - AppSpacing.sm,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, color: fg, size: AppSizes.iconSm),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: destructive ? theme.colorScheme.error : null),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return AppPressScale(child: row);
  }
}

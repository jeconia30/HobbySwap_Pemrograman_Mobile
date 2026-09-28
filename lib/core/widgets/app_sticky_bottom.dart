import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Area aksi yang menempel di bawah layar (di luar area scroll).
class AppStickyBottom extends StatelessWidget {
  const AppStickyBottom({
    super.key,
    required this.children,
    this.color,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.pageHorizontal,
      AppSpacing.lg,
      AppSpacing.pageHorizontal,
      AppSpacing.sm,
    ),
  });

  final List<Widget> children;

  /// Default: warna latar layar.
  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: AppColors.of(context).border)),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Tombol ikon kotak 44×44 (radius 14); area sentuh tetap 48.
/// Default latar surface + border; [backgroundColor] untuk versi di atas foto.
/// [showDot] menampilkan titik merah (mis. notifikasi belum dibaca).
class AppIconTileButton extends StatelessWidget {
  const AppIconTileButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.showDot = false,
    this.backgroundColor,
    this.iconColor,
    this.size = AppSizes.tileButton,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool showDot;

  /// Bila diisi, border tidak digambar.
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: showDot,
        smallSize: AppSpacing.sm,
        backgroundColor: scheme.error,
        child: Icon(icon, size: AppSizes.iconSm),
      ),
      style: IconButton.styleFrom(
        fixedSize: Size.square(size),
        minimumSize: Size.square(size),
        tapTargetSize: MaterialTapTargetSize.padded,
        foregroundColor: iconColor ?? scheme.onSurface,
        backgroundColor: backgroundColor ?? scheme.surface,
        side: backgroundColor == null
            ? BorderSide(color: AppColors.of(context).border)
            : BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.inputAll),
      ),
    );
  }
}

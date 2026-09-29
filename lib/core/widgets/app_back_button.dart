import 'package:flutter/material.dart';

import 'app_icon_tile_button.dart';
import '../constants/app_strings.dart';

/// Tombol kembali kotak 44×44 (area sentuh tetap 48).
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    required this.onPressed,
    this.tooltip = AppTeks.kembali,
  });

  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) => AppIconTileButton(
        icon: Icons.arrow_back_rounded,
        tooltip: tooltip,
        onPressed: onPressed,
      );
}

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Efek tekan DESIGN §5: skala turun ke 0.97 selama jari menempel, lalu kembali.
/// Hanya mendengarkan pointer (tidak ikut arena gesture), jadi aman membungkus
/// InkWell/Dismissible. Mati saat [enabled] false atau animasi sistem dimatikan.
class AppPressScale extends StatefulWidget {
  const AppPressScale({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<AppPressScale> createState() => _AppPressScaleState();
}

class _AppPressScaleState extends State<AppPressScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? AppSizes.pressScale : 1,
        duration: AppDurations.press,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

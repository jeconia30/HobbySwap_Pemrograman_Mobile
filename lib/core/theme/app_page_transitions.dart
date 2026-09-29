import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// Transisi antarhalaman DESIGN §5: fade + geser 16 px, 250 ms, easeOutCubic.
/// Bottom sheet & dialog tidak lewat sini (tetap animasi bawaan). Saat animasi
/// sistem dimatikan, halaman langsung tampil.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  static final _curve = CurveTween(curve: Curves.easeOutCubic);

  @override
  Duration get transitionDuration => AppDurations.pageTransition;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final t = animation.drive(_curve);
    return FadeTransition(
      opacity: t,
      child: AnimatedBuilder(
        animation: t,
        builder: (context, child) => Transform.translate(
          offset: Offset(AppSizes.pageSlide * (1 - t.value), 0),
          child: child,
        ),
        child: child,
      ),
    );
  }
}

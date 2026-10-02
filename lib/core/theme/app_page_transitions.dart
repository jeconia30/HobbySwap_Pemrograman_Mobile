import 'package:flutter/cupertino.dart';

/// Transisi antarhalaman: halaman baru bergeser masuk dari kanan, halaman lama
/// ikut bergeser sedikit ke kiri, dan bisa swipe dari tepi kiri untuk kembali.
/// Bottom sheet & dialog tidak lewat sini (tetap animasi bawaan). Saat animasi
/// sistem dimatikan, halaman langsung tampil.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  static const _slide = CupertinoPageTransitionsBuilder();

  @override
  Duration get transitionDuration => _slide.transitionDuration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return _slide.buildTransitions(
        route, context, animation, secondaryAnimation, child);
  }
}

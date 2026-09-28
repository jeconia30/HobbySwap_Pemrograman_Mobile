import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.nextRoute = '/home'});

  final String nextRoute;

  static const logoAsset = 'assets/images/logo.png';
  static const background = Color(0xFFF8FAFF);
  static const animationDuration = Duration(milliseconds: 1500);
  static const totalDuration = Duration(seconds: 3);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashScreen.animationDuration,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
  );

  late final Animation<double> _scale = Tween<double>(begin: 0.6, end: 1.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _navigationTimer = Timer(SplashScreen.totalDuration, _goNext);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(SplashScreen.logoAsset), context);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(widget.nextRoute, (route) => false);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoSize =
        (MediaQuery.sizeOf(context).shortestSide * 0.4).clamp(120.0, 180.0);

    return Scaffold(
      backgroundColor: SplashScreen.background,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Image.asset(
              SplashScreen.logoAsset,
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
              semanticLabel: 'Logo HobbySwap',
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.swap_horizontal_circle,
                size: logoSize * 0.6,
                color: const Color(0xFF5879E8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

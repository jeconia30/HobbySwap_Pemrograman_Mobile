import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const HobbySwapApp());
}

class HobbySwapApp extends StatelessWidget {
  const HobbySwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HobbySwap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF1EFE8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F6E56)),
      ),
      home: const SplashScreen(),
    );
  }
}
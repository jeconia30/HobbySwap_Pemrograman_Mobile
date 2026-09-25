import 'package:flutter/material.dart';

import 'data/app_store.dart';
import 'data/mock_repository.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/home_shell.dart';
import 'screens/item_detail_screen.dart';
import 'screens/item_form_screen.dart';
import 'screens/loan_detail_screen.dart';
import 'screens/loan_form_screen.dart';
import 'splash_screen.dart';
import 'widgets/common.dart';

void main() {
  runApp(HobbySwapApp(store: AppStore(MockRepository())));
}

/// Peta rute. Rute dengan ID bisa dibuka langsung (mis. dari URL di web).
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final segments = Uri.parse(settings.name ?? '/').pathSegments;
  final Widget page = switch (segments) {
    [] => const SplashScreen(),
    ['home'] => const HomeShell(),
    ['items', 'new'] => const ItemFormScreen(),
    ['item', final id] => ItemDetailScreen(id: id),
    ['item', final id, 'edit'] => ItemFormScreen(itemId: id),
    ['item', final id, 'borrow'] => LoanFormScreen(itemId: id),
    ['loan', final id] => LoanDetailScreen(id: id),
    ['loan', final id, 'edit'] => LoanFormScreen(loanId: id),
    ['profile', 'edit'] => const EditProfileScreen(),
    _ => const NotFoundScreen(),
  };
  return MaterialPageRoute(settings: settings, builder: (_) => page);
}

ThemeData buildTheme(Brightness brightness) {
  const brand = Color(0xFF0F6E56);
  final light = brightness == Brightness.light;
  var scheme = ColorScheme.fromSeed(seedColor: brand, brightness: brightness);
  if (light) scheme = scheme.copyWith(primary: brand);
  final radius = BorderRadius.circular(12);
  final buttonShape = RoundedRectangleBorder(borderRadius: radius);
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: light ? const Color(0xFFF1EFE8) : null,
    appBarTheme: AppBarTheme(
      backgroundColor: light ? brand : scheme.surface,
      foregroundColor: light ? const Color(0xFFE1F5EE) : scheme.onSurface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      border: OutlineInputBorder(borderRadius: radius),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48), shape: buttonShape),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48), shape: buttonShape),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

class HobbySwapApp extends StatelessWidget {
  const HobbySwapApp({super.key, required this.store, this.initialRoute = '/'});

  final AppStore store;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: store,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => MaterialApp(
          title: 'HobbySwap',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: initialRoute,
          onGenerateRoute: onGenerateRoute,
          onGenerateInitialRoutes: (name) => [
            if (name != '/' && name != '/home')
              onGenerateRoute(const RouteSettings(name: '/home')),
            onGenerateRoute(RouteSettings(name: name)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/data/app_store.dart';
import 'package:hobby_swab/data/mock_repository.dart';
import 'package:hobby_swab/main.dart';
import 'package:hobby_swab/screens/home_shell.dart';
import 'package:hobby_swab/splash_screen.dart';

void main() {
  testWidgets('Splash shows logo, animates, then navigates to home after 3s',
      (WidgetTester tester) async {
    await tester.pumpWidget(HobbySwapApp(store: AppStore(MockRepository())));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName == SplashScreen.logoAsset),
      findsOneWidget,
    );

    final fade = tester.widget<FadeTransition>(find.descendant(
        of: find.byType(SplashScreen), matching: find.byType(FadeTransition)));
    expect(fade.opacity.value, 0.0);

    await tester.pump(const Duration(milliseconds: 1500));
    expect(fade.opacity.value, 1.0);
    expect(find.byType(HomeShell), findsNothing);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(HomeShell), findsOneWidget);
  });
}

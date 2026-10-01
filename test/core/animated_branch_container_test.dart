import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/router/app_shell.dart';

double _opacityOf(WidgetTester tester, String label) => tester
    .widget<FadeTransition>(find
        .ancestor(of: find.text(label), matching: find.byType(FadeTransition))
        .first)
    .opacity
    .value;

void main() {
  testWidgets('tab lama benar-benar hilang setelah pindah tab', (tester) async {
    Widget shell(int index) => MaterialApp(
          home: AnimatedBranchContainer(
            currentIndex: index,
            children: const [Text('A'), Text('B'), Text('C')],
          ),
        );

    await tester.pumpWidget(shell(2));
    expect(_opacityOf(tester, 'C'), 1);

    await tester.pumpWidget(shell(0));
    await tester.pumpAndSettle();
    expect(_opacityOf(tester, 'A'), 1);
    expect(_opacityOf(tester, 'C'), 0);
  });
}

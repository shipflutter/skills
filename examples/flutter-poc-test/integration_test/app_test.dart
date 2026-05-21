import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_poc_test/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('runs deterministic score flow without screenshots', (
    tester,
  ) async {
    await tester.pumpWidget(const TestSkillsPocApp());
    await tester.pumpAndSettle();

    expect(find.text('Flutter Test Skills POC'), findsOneWidget);
    expect(find.text('Growth'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('count-field')), '20');
    await tester.enterText(find.byKey(const Key('multiplier-field')), '5');
    await tester.enterText(find.byKey(const Key('discount-field')), '25');
    await tester.tap(find.byKey(const Key('calculate-button')));
    await tester.pumpAndSettle();

    expect(find.text('75.00'), findsOneWidget);
    expect(find.text('Growth'), findsOneWidget);
  });
}

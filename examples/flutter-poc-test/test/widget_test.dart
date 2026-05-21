import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_poc_test/main.dart';

void main() {
  testWidgets('renders app shell', (tester) async {
    await tester.pumpWidget(const TestSkillsPocApp());

    expect(find.text('Flutter Test Skills POC'), findsOneWidget);
    expect(find.text('Deterministic score calculator'), findsOneWidget);
  });

  testWidgets('shows deterministic default result', (tester) async {
    await tester.pumpWidget(const TestSkillsPocApp());

    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.byKey(const Key('subtotal-value')), findsOneWidget);
    expect(find.text('96'), findsOneWidget);
    expect(find.text('86.40'), findsOneWidget);
    expect(find.text('Growth'), findsOneWidget);
  });

  testWidgets('updates result after user input', (tester) async {
    await tester.pumpWidget(const TestSkillsPocApp());

    await tester.enterText(find.byKey(const Key('count-field')), '20');
    await tester.enterText(find.byKey(const Key('multiplier-field')), '5');
    await tester.enterText(find.byKey(const Key('discount-field')), '25');
    await tester.tap(find.byKey(const Key('calculate-button')));
    await tester.pump();

    expect(find.text('75.00'), findsOneWidget);
    expect(find.text('Growth'), findsOneWidget);
  });
}

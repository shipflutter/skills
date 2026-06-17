import 'package:flutter/material.dart';
import 'package:flutter_poc_auth/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sign-in and sign-up flows render success states', (
    tester,
  ) async {
    await tester.pumpWidget(const AuthPocApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in').first);
    await tester.pump();
    await tester.tap(find.text('Sign in').last);
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.textContaining('User ID:'), findsOneWidget);
    expect(find.text('Email: demo@shipflutter.dev'), findsOneWidget);

    await tester.tap(find.text('Sign up').last);
    await tester.pumpAndSettle();
    expect(find.text('Display name'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'new@shipflutter.dev',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'password123',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Display name'),
      'New User',
    );
    await tester.tap(find.text('Create account'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Email: new@shipflutter.dev'), findsOneWidget);
    expect(find.text('Name: New User'), findsOneWidget);

    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'reset@shipflutter.dev',
    );
    await tester.tap(find.text('Send Reset Link'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(
      find.text('Reset link sent to reset@shipflutter.dev'),
      findsOneWidget,
    );
  });
}

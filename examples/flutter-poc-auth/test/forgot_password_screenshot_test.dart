import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_poc_auth/main.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> saveForgotPasswordScreenshot(
  WidgetTester tester,
  String name,
) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('forgot-password-screenshot-boundary')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('screenshots');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    await File('screenshots/$name.png').writeAsBytes(
      bytes!.buffer.asUint8List(),
      flush: true,
    );
  });
}

void main() {
  testWidgets('captures forgot password screenshots', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      const RepaintBoundary(
        key: ValueKey('forgot-password-screenshot-boundary'),
        child: AuthPocApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await saveForgotPasswordScreenshot(
      tester,
      'ep02-forgot-password-form',
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'reset@shipflutter.dev',
    );
    await tester.tap(find.text('Send Reset Link'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await saveForgotPasswordScreenshot(
      tester,
      'ep02-forgot-password-success',
    );

    await tester.binding.setSurfaceSize(null);
  });
}

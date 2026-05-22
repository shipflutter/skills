import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_poc_auth/main.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> saveScreenshot(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('auth-poc-screenshot-boundary')),
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
  testWidgets('captures auth flow screenshots', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      const RepaintBoundary(
        key: ValueKey('auth-poc-screenshot-boundary'),
        child: AuthPocApp(),
      ),
    );
    await tester.pump();

    await saveScreenshot(tester, 'ep01-auth-sign-in-form');

    await tester.binding.setSurfaceSize(null);
  });
}

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const screenshotSurfaceSize = Size(390, 844);

Future<void> prepareScreenshotSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(screenshotSurfaceSize);
}

Future<void> saveScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await tester.pump(const Duration(milliseconds: 100));

  var platformName = 'web';
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      platformName = 'android';
    } else if (Platform.isIOS) {
      platformName = 'ios';
    } else {
      platformName = Platform.operatingSystem;
    }
  }

  await binding.takeScreenshot('$name-$platformName');
}

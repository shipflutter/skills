---
name: flutter-driver-screenshot-test
description: Add Flutter driver based integration tests that capture and save screenshot PNG files on the host machine. Use when adding e2e screenshot tests with flutter drive.
---

# Flutter Driver Screenshot Test Skill

Use this skill when an AI agent needs to add Flutter end-to-end tests that save screenshot PNG files during `flutter drive` runs.

## Goal

Run Flutter integration tests through a driver process and persist screenshots on the host machine, not inside the app or simulator filesystem.

## Required dependencies

Add these dev dependencies when missing:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
```

## Directory layout

```text
integration_test/
  helpers/
    screenshot_helper.dart
  screenshot_test.dart
test_driver/
  integration_test.dart
e2e.sh
screenshots/
```

## Screenshot helper

Use this pattern inside `integration_test/helpers/screenshot_helper.dart`:

```dart
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
```

The helper must not create directories or write files. The app process may run on a read-only filesystem.

## Driver that saves PNG files

Use this pattern inside `test_driver/integration_test.dart`:

```dart
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
      onScreenshot: (String name, List<int> bytes,
          [Map<String, Object?>? args]) async {
        final screenshotsDir = Directory('screenshots');
        if (!screenshotsDir.existsSync()) {
          screenshotsDir.createSync(recursive: true);
        }

        final file = File('${screenshotsDir.path}/$name.png');
        await file.writeAsBytes(bytes, flush: true);
        return true;
      },
    );
```

## Test pattern

```dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await binding.convertFlutterSurfaceToImage();
  });

  testWidgets('saves home screen screenshot', (tester) async {
    await prepareScreenshotSurface(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await saveScreenshot(binding, tester, 'home_screen');
  });
}
```

## Run command

Use `e2e.sh` from this skill. Add one `flutter drive` command per target file.

## Rules

- Save screenshots from the driver process only.
- Import `integration_test_driver_extended.dart` when using `onScreenshot`.
- Do not write screenshots from files under `integration_test/`.
- Keep screenshot names stable and platform-suffixed.
- Run with a booted emulator or simulator visible in `flutter devices`.

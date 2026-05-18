---
name: flutter-integration-test
description: Add Flutter integration tests that run on an emulator or simulator without saving screenshot image files. Use when adding integration_test coverage without screenshot persistence.
---

# Flutter Integration Test Skill

Use this skill when an AI agent needs to add or maintain Flutter `integration_test` coverage that runs on a connected emulator or simulator and does not persist screenshot image files.

## Goal

Create integration tests that verify app flows on a real Flutter engine target. Do not save screenshots to disk. If screenshots are needed for assertions, keep them in memory only or remove screenshot capture entirely.

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
  app_test.dart
integration_test.sh
```

## Test pattern

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('runs app smoke flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
```

Adapt imports and assertions to the project. Prefer stable keys, visible text, and public UI behavior. Avoid delays unless the UI truly depends on timers or network.

## Emulator or simulator

Before running the script, ensure one target is booted and visible in:

```bash
flutter devices
```

If no device is running, start one with the platform tooling, then rerun the script.

## Run command

Use `integration_test.sh` from this skill. It runs formatting, analysis, unit/widget tests, then integration tests without screenshot persistence.

## Rules

- Do not create or write a `screenshots/` directory.
- Do not use `integration_test_driver_extended.dart` for this skill.
- Do not add `onScreenshot` callbacks.
- Keep the driver optional. For normal integration tests, prefer `flutter test integration_test`.
- If the project already uses `flutter drive`, use the standard driver only and do not save images.

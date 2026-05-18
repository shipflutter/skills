# AI Prompts for Flutter Test Skills

Use the prompts below with AI agents when integrating Flutter tests.

## 1. Integration test without saving screenshots

```text
You are an AI agent working in a Flutter project.

Integrate Flutter integration tests that run on an emulator or simulator without saving screenshot image files.

Requirements:
- Read the skill in `flutter-integration-test-skill/` if it exists.
- Add `integration_test` to `dev_dependencies` if it is missing.
- Create the `integration_test/` directory if it is missing.
- Create an integration smoke test for the app's main flow.
- Do not create a `screenshots/` directory.
- Do not write PNG/JPG files.
- Do not use `integration_test_driver_extended.dart`.
- Create `integration_test.sh` to run:
  - `flutter pub get`
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test`
  - `flutter test integration_test`
- Run validation and fix any failures.

When finished, report:
- Files created or modified.
- Commands run.
- Pass/fail result.
```

## 2. Flutter driver test with saved screenshot images

```text
You are an AI agent working in a Flutter project.

Integrate Flutter driver screenshot tests that save PNG screenshot files into the `screenshots/` directory on the host machine.

Requirements:
- Read the skill in `flutter-driver-screenshot-skill/` if it exists.
- Add `integration_test` to `dev_dependencies` if it is missing.
- Create `integration_test/helpers/screenshot_helper.dart`.
- The helper must only call `binding.takeScreenshot(...)`; it must not write files inside the app or simulator process.
- Create `test_driver/integration_test.dart` using `integration_test_driver_extended.dart` and `onScreenshot` to write PNG files into `screenshots/`.
- Create `integration_test/screenshot_test.dart` that captures at least one main app screen.
- Create `e2e.sh` to run:
  - `flutter pub get`
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test`
  - `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screenshot_test.dart`
- Run validation and fix any failures.

When finished, report:
- Files created or modified.
- Commands run.
- Screenshot files generated.
- Pass/fail result.
```

## 3. Integrate both features into another project

```text
You are an AI agent. Integrate both Flutter test features into this project:

PROJECT_PATH=<path to Flutter project>

Feature 1:
- Integration tests running on an emulator or simulator.
- No screenshot image files saved.
- Includes `integration_test.sh`.

Feature 2:
- Flutter driver screenshot tests.
- Saves PNG screenshots into `screenshots/` through the host driver.
- Includes `e2e.sh`.

Skill source:
- `flutter-integration-test-skill/`
- `flutter-driver-screenshot-skill/`

Workflow:
1. Verify `PROJECT_PATH` is a Flutter project with `pubspec.yaml`.
2. Read `lib/main.dart` and existing tests to choose an appropriate smoke flow.
3. Add the required dependency.
4. Create or update integration tests, screenshot helper, driver, and scripts.
5. Run:
   - `flutter pub get`
   - `dart format --set-exit-if-changed .`
   - `flutter analyze`
   - `flutter test`
   - `sh integration_test.sh`
   - `sh e2e.sh`
6. If anything fails, fix the root cause and do not bypass checks.

Final report:
- Changed files.
- Validation commands.
- Screenshot output paths.
- Note if a running emulator or simulator is required.
```

## 4. Short prompt for quick use

```text
Integrate 2 Flutter test skills into this project:
1. Integration tests without saving screenshots, with `integration_test.sh`.
2. Flutter driver screenshot tests that save PNG files into `screenshots/`, with `e2e.sh`.
Read the skill folders if available, create tests that match the current app, run validation, and fix failures until everything passes.
```

## Technical notes

- Use `flutter test integration_test` for normal integration tests that do not need a screenshot-saving driver.
- Use `flutter drive` with `integration_test_driver_extended.dart` when screenshot PNG files must be saved.
- Do not write screenshots directly from the app process because simulator/device filesystems can be read-only.
- `onScreenshot` runs in the host driver process, so it is the stable place to write files.

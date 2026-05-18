# Example Prompts

## Integrate Flutter screenshot e2e tests

```text
Use the `flutter-driver-screenshot-test` skill.

Add Flutter driver screenshot tests to this project.

Requirements:
- Save PNG screenshots into `screenshots/` on the host machine.
- Use `integration_test_driver_extended.dart` with `onScreenshot`.
- Do not write screenshot files from `integration_test/` code.
- Create `integration_test/helpers/screenshot_helper.dart`.
- Create `integration_test/screenshot_test.dart` for the main screens.
- Create `test_driver/integration_test.dart`.
- Create `e2e.sh` in the project root.
- Run validation and fix failures.

Report generated screenshot paths.
```

## Add screenshot coverage for specific screens

```text
Use the `flutter-driver-screenshot-test` skill.

Add screenshot tests for these screens: <screen list>.

Constraints:
- Use stable screenshot names.
- Include platform suffix in screenshot names.
- Keep screenshots deterministic by using fake data or stable app state.
- Run `sh e2e.sh` and verify PNG files are created.
```

## Fix screenshot save failures

```text
Use the `flutter-driver-screenshot-test` skill.

The e2e screenshot test is failing. Run `sh e2e.sh`, inspect the error, and fix it.

Rules:
- If the error is read-only filesystem, move file writing to the host driver `onScreenshot` callback.
- Do not write PNG files from the app process.
- Keep screenshot helper limited to `binding.takeScreenshot(...)`.
```

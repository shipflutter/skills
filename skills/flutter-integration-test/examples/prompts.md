# Example Prompts

## Integrate basic Flutter integration tests

```text
Use the `flutter-integration-test` skill.

Add Flutter integration tests to this project.

Requirements:
- Run on emulator/simulator.
- Do not save screenshot images.
- Add `integration_test` dev dependency if missing.
- Create `integration_test/app_test.dart` with a smoke flow for the current app.
- Create `integration_test.sh` in the project root.
- Run validation and fix failures.

Report changed files and commands run.
```

## Add integration test for a specific flow

```text
Use the `flutter-integration-test` skill.

Add an integration test for this flow: <describe user flow>.

Constraints:
- Use stable finders such as keys or visible text.
- Do not create or write to `screenshots/`.
- Prefer `flutter test integration_test`.
- Keep the test deterministic and avoid arbitrary waits.

Run `sh integration_test.sh` when done.
```

## Fix failing integration tests

```text
Use the `flutter-integration-test` skill.

Run the integration test script, inspect failures, and fix the root cause.

Rules:
- Do not bypass analyze, format, or test failures.
- Do not add screenshot persistence.
- Keep changes limited to the failing test or app behavior needed by the test.
```

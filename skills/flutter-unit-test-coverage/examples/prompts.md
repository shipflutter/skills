# Example Prompts

## Add Flutter unit test coverage report script

```text
Use the `flutter-unit-test-coverage` skill.

Add a Flutter unit/widget test coverage report workflow to this project.

Requirements:
- Copy the skill script to project root as `run_test.sh`.
- Make `run_test.sh` executable.
- Support `--test` for `flutter test --coverage`.
- Support `--report` for existing `coverage/lcov.info` using `lcov` and `genhtml`.
- Do not change app code unless tests fail because of a real issue.
- Run `./run_test.sh --test` and report coverage output path.
```

## Generate HTML coverage report

```text
Use the `flutter-unit-test-coverage` skill.

Generate a Flutter test coverage HTML report for this project.

Steps:
- Verify the project has `pubspec.yaml`.
- Run `flutter test --coverage`.
- If `lcov` and `genhtml` exist, generate HTML under `coverage/`.
- Open or report `coverage/index-sort-l.html`.

If `lcov` is missing, explain how to install it.
```

## Fix coverage script failure

```text
Use the `flutter-unit-test-coverage` skill.

Run the coverage script and fix failures.

Rules:
- Keep the script compatible with macOS bash.
- Do not hardcode absolute project paths.
- Fail clearly when the current directory is not a Flutter project.
- Fail clearly when `lcov` or `genhtml` is missing for report generation.
```

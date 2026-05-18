---
name: flutter-unit-test-coverage
description: Generate Flutter unit and widget test coverage reports using run_test.sh style commands. Use when the user asks for unit test coverage, lcov reports, or HTML coverage output.
---

# Flutter Unit Test Coverage

Use this skill to add or run Flutter unit/widget test coverage reports.

## Goal

Run Flutter tests with coverage, optionally clean the lcov report, and generate an HTML report under `coverage/`.

## Requirements

- The project must contain `pubspec.yaml`.
- Use `flutter test --coverage` for coverage collection.
- Use `lcov` and `genhtml` only when generating an HTML report.
- Do not modify app code unless tests fail because of a real issue.

## Script

Use `scripts/run_test.sh` from this skill. It supports:

```bash
./run_test.sh --test
./run_test.sh --report
./run_test.sh
```

## Behavior

- `--test`: run tests with coverage only.
- `--report`: generate HTML report from existing `coverage/lcov.info`.
- no args: run tests with coverage, then generate and open HTML report.

## Install notes

When integrating into a Flutter project, copy the script to the project root as `run_test.sh` and make it executable:

```bash
chmod +x run_test.sh
```

## Validation

Run:

```bash
./run_test.sh --test
```

If `lcov` is installed, also run:

```bash
./run_test.sh --report
```

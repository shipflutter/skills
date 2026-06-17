# Changelog

## 0.0.7 - 2026-05-24

### Added

- Added ASCII screen layout document support to `add-feat`, including a reusable screen layout template and generated `resources/screens/epXX-<feature>-screen.md` files.
- Added screen layout awareness to `add-srs` so SRS packages can trace user stories, technical designs, and `ASCII screen` documents together.
- Added forgot password flow coverage to `examples/flutter-poc-auth`, including model/service support, UI, user story, technical design, screen layout, tests, and screenshots.

### Changed

- Updated SRS HTML generation to render `resources/screens/*.md` inside the `Screens / UI Surfaces` section while preserving ASCII wireframes.
- Improved the Flutter auth POC e2e and SRS reports with sidebar navigation, summary counts, screenshot filtering, and cross-links between reports.
- Expanded SRS traceability for the auth POC to cover forgot password requirements, entities, flows, and verification artifacts.

## 0.0.6 - 2026-05-23

### Added

- Added `examples/flutter-poc-test` demo project for `flutter-unit-test-coverage`, `flutter-integration-test`, and `flutter-driver-screenshot-test`.
- Added e2e screenshot HTML report generation with screenshot gallery and passed test summary.
- Added example prompts for applying screenshot e2e testing to other Flutter projects.

### Fixed

- Fixed `examples/flutter-poc-fingerprint` iOS simulator loading by moving inherited-widget dependent loading out of `initState`.
- Made fingerprint POC screenshot tests assert the report UI renders instead of only saving a screenshot.

## 0.0.2 - 2026-05-18

### Added

- `flutter-unit-test-coverage`
  - Adds Flutter unit/widget test coverage reporting.
  - Provides `scripts/run_test.sh` for `flutter test --coverage` and optional `lcov` HTML report generation.

## 0.0.1 - 2026-05-18

Initial release of Flutter testing skills for AI agents.

### Added

- `flutter-unit-test-coverage`
  - Adds Flutter unit/widget test coverage reporting.
  - Provides `scripts/run_test.sh` for `flutter test --coverage` and optional `lcov` HTML report generation.

- `flutter-integration-test`
  - Adds Flutter `integration_test` coverage for emulator/simulator execution.
  - Provides guidance for smoke tests without screenshot image persistence.
  - Includes `scripts/integration_test.sh` for formatting, analysis, unit/widget tests, and integration tests.

- `flutter-driver-screenshot-test`
  - Adds Flutter driver based screenshot testing.
  - Saves screenshot PNG files through the host driver process, avoiding simulator read-only filesystem issues.
  - Includes `scripts/e2e.sh` for formatting, analysis, unit/widget tests, and `flutter drive` screenshot capture.

### Packaging

- Skills are exported under the standard `skills/<skill-name>/SKILL.md` layout.
- Each `SKILL.md` includes Claude-compatible `name` and `description` frontmatter.
- Supporting run scripts are stored under each skill's `scripts/` directory.

### Documentation

- Includes Vietnamese prompt guide: `README-ai.md`.
- Includes English prompt guide: `README-ai-en.md`.
- Includes skill placement and structure table: `skills-table.md`.

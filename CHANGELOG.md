# Changelog

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

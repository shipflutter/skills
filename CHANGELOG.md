# Changelog

## 0.0.9 - 2026-06-28

### Added

- **`marketing-app-banner` skill** — a drop-in, dependency-free native-style "Get the app" smart
  banner pinned to the top of a website or web app. Auto-detects iOS vs Android and links to the
  right store; hidden on desktop and (with a one-line guard) inside native wrappers. Ships
  `templates/app-banner.js` (self-injecting CSS), a standalone `templates/app-banner.css`, an SPA /
  in-app-hub integration guide (`reference/spa-integration.md`), and a static `examples/demo.html`.
  CSS is iOS-12 / WebKit-605 safe (flex-gap margin fallback, no `inset:` shorthand, safe-area aware).
- **`universal-download-link` skill** — one shared `/get/` link + QR that auto-detects the OS and
  forwards to the correct store before paint (`location.replace` in `<head>`), with a desktop
  chooser. Ships `templates/get-index.html`, an optional soft-redirect for existing download pages
  (`templates/download-redirect.js`), a `scripts/gen-qr.py` single-path SVG QR generator (verifies
  the path matches the encoded matrix), `reference/notes.md` (deploy/SEO/in-app-browser notes), and
  an interactive `examples/demo.html` (platform simulator + live detection + QR).
- Listed both skills in `README.md`, `skills-table.md`, and the plugin/marketplace manifests.

## 0.0.8 - 2026-06-25

### Added

- Added three interactive, data-driven views to the generated `srs-index.html`, switchable from the left sidebar:
  - **Docs** — the full SRS with a sticky table of contents (existing behavior, now one of three views).
  - **Flow** — a canvas that renders each screen's real ASCII mockup and connects them with navigation arrows inferred from each screen's `## Events`. Screens auto-order into a path so a hub screen sits between the screens it links to.
  - **Board** — a sprint kanban with **Backlog / To Do / In Progress / In Review / Done** columns. Cards show the story title and open a dialog with the full description and acceptance-criteria task checklist. A **List** layout adds status filter tags.
- Bundled the canonical generator at `skills/add-srs/assets/srs.sh` so agents copy it into `resources/srs.sh` instead of re-authoring it.
- Added a migration prompt for existing projects: `skills/add-srs/references/migrate-to-views.md`.
- Added a `Sign-up` backlog feature to `examples/flutter-poc-auth` (user story + screen) demonstrating the Backlog column and a three-screen flow.

### Changed

- `add-feat gen-tdd` now scaffolds user stories with a `Status:` line and screen `## Events` with a navigation-target convention, so freshly generated features populate the Board and Flow views automatically.
- Updated `add-feat` and `add-srs` `SKILL.md`, templates, and references to document the Flow/Board authoring conventions (`EventName -> <target-screen-file-id>` for arrows; `Status:` for board columns).
- Hardened the Flow event parser to accept both `->` and `→` and to match a target screen by its file id.

### Migration

- Existing projects keep working unchanged. To adopt the new views, run the prompt in `skills/add-srs/references/migrate-to-views.md` (copy the bundled `srs.sh`, add `Status:` lines, add navigation `## Events`, regenerate). Stories without a `Status:` line default to **Done**.

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

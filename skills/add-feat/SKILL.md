---
name: add-feat
description: Create a new feature package from repo conventions by writing user-story docs, technical design docs, implementation notes, and test/e2e scaffolding. Use when the user wants to add a feature template or expand a feature using the repo's user-story and technical-design structure.
---

# Add Feature Skill

Use this skill to bootstrap a new feature package in this repository.

## Core sources
- `resources/implement_feat_readme.md` when present in the target app.
- `resources/user-story/` for `EPXX.US###` requirements.
- `resources/technial-design/` for `epXX-<feature>.md` technical design.
- `skills/add-feat/assets/templates/` for reusable templates.

## Workflow
1. Read `resources/implement_feat_readme.md` first.
2. Mirror the repo structure:
   - user-story docs in `resources/user-story/`
   - technical design docs in `resources/technial-design/`
   - implementation in `lib/presentation/`
   - integration in `lib/integration/`
   - unit/widget tests in `test/`
   - integration tests in `integration_test/`
   - driver tests in `test_driver/`
   - screenshot output in `screenshots/`
   - an `e2e.sh` runner that generates `e2e-index.html`
3. For a new feature, create:
   - a feature brief
   - user-story markdown
   - technical-design markdown
   - implementation plan for UI -> bloc -> usecase -> repository/service
   - unit tests for service/usecase behavior
   - widget tests for rendering and validation
   - integration tests for the main user flow
   - driver or screenshot tests that save PNG screenshots
   - an `e2e.sh` script that runs tests, captures screenshots, builds `e2e-index.html`, and auto-opens it
4. If the user asks to derive docs from source, run `gen-tdd`:
   - From a target Flutter app: `../../scripts/add_feat.sh gen-tdd <feature-slug> <EPXX>`
   - From this repository root: `scripts/add_feat.sh gen-tdd <feature-slug> <EPXX>`
   - Direct skill script: `skills/add-feat/scripts/add_feat.sh gen-tdd <feature-slug> <EPXX>`
   - Example: `scripts/add_feat.sh gen-tdd auth EP01`

## Required conventions
- Keep user stories in the form `EPXX.US###`.
- Keep technical design files in the form `epXX-<feature>.md`.
- Include explicit flow steps and entities in the technical design.
- Include unit, widget, integration, and driver/screenshot test coverage before marking implementation complete.
- Include screenshot e2e runner names based on the user-story id or epic id.
- Generate `e2e-index.html` from `e2e.sh` with the standard E2E report CSS/template, screenshot grid, and auto-open behavior.

## Example pattern
Use the bundled sign-in template when the feature calls an API:
- `assets/templates/sign-in-api-service-ft-integration.md`
- Mock the `service_ft` integration boundary in tests.
- Keep API payload mapping in the service layer.

## Script
- `scripts/add_feat.sh gen-tdd <feature-slug> [EPXX]`
- Scans `lib/presentation/<feature-slug>` when it exists and records discovered Dart entry points.
- Creates `resources/user-story/epXX-<feature-slug>.md`.
- Creates `resources/technial-design/epXX-<feature-slug>.md`.
- Use the generated docs as the source for `add-srs` traceability.

## Output expectations
- Produce markdown templates first.
- Then produce the implementation plan.
- Then implement feature code.
- Then add unit, widget, integration, and driver/screenshot tests.
- Then add or update `e2e.sh` so it runs the test suite, captures screenshots, generates `e2e-index.html`, and auto-opens the report.
- Keep everything aligned with the repo's existing docs and naming.

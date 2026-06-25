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

## 5. Privacy-safe device/referral attributes

```text
Use the `privacy-safe-device-referral-attributes` skill.

Add a transparent device/referral attributes POC for Flutter Android, iOS, and Web.

Requirements:
- Use normal platform/browser metadata only.
- Parse only allowlisted referral params such as ref, referral, utm_source, utm_medium, utm_campaign, gclid, fbclid.
- Ignore sensitive unknown query params like token, email, session, access_token.
- Generate a local SHA-256 hash from normalized allowed attributes.
- Do not call third-party IP services.
- Do not use canvas/audio/WebGL/font fingerprinting.
- Show the collected JSON and privacy notes in the UI.
- Run format/analyze and report changed files.
```

## 6. Generate the full product docs (add-feat + add-srs)

```text
Use the add-feat and add-srs skills (repo: https://github.com/shipflutter/skills) to analyze this project and create the full product documentation using the latest templates.

0. INSTALL THE SKILLS FIRST (skip if already available). Install the plugin in Claude Code:
   /plugin marketplace add shipflutter/skills
   /plugin install shipflutter-skills@shipflutter
   Or copy them into the project:
   npx skills add shipflutter/skills --skill add-feat -a claude-code --copy
   npx skills add shipflutter/skills --skill add-srs -a claude-code --copy

1. ANALYZE FIRST. Map the product end to end (frontend, backend/API, data model, build/deploy).
   Group the functionality into epics EP01, EP02, … each with a kebab-case slug (e.g. ep01-auth).
   List the epics before writing files.

2. FOR EVERY EPIC create (under resources/, following skills/add-feat/assets/templates/):
   - resources/user-story/epXX-<slug>.md — stories as "## EPXX.US###: Title", each with:
     • a "Status:" line (Backlog | To Do | Sprint | In Progress | In Review | Done) — Board column;
     • an "As a … I want … so that …" line (card description);
     • an "Acceptance criteria:" bullet list (= task checklist; nested bullets = sub-tasks).
   - resources/technial-design/epXX-<slug>.md — Technologies, Entry Points (real file paths),
     Flow (numbered), one Mermaid diagram, an Entities table, Tests.
   - resources/screens/epXX-<slug>-screen.md — first heading = screen name; one ASCII wireframe in a
     fenced code block (box-drawing ┌─┐│└┘├┤┬┴); "## Components", "## States", "## Events".
     Write events as "EventName -> description" (or →) referencing the target screen by FILE ID
     (e.g. "… -> navigate to ep02-…-screen") or by TITLE KEYWORD so the Flow view draws arrows;
     add a return event on the target screen for two-way connectors.
   - one resources/feature-brief.md — product brief + epic catalog table.

3. COMPILE THE SRS. Write resources/srs.md: purpose, scope, requirements summary, user-story index,
   use cases, a "## Screens / UI Surfaces" section (leave it EMPTY for the script to inject),
   data/entity model with a Mermaid ER diagram, external interfaces/API, NFRs, risks, and a
   traceability matrix (FR → epic → stories → design → screen → verification).

4. RENDER. Ensure resources/srs.sh exists (copy the latest from
   examples/flutter-poc-auth/resources/srs.sh and rebrand the sidebar title), run ./resources/srs.sh
   to generate srs-index.html at the project root, and verify all three views:
   📄 Docs (TOC + injected screens) · 🔀 Flow (one card per screen, arrows from ## Events) ·
   🗂️ Board (one card per story, placed by Status:).

Keep box-drawing characters intact inside fenced code blocks, keep everything local (no external
renderers), and keep resources/srs.md as the single editable source of truth.

Tip: to derive starter docs from an existing Flutter feature tree, run
scripts/add_feat.sh gen-tdd <slug> EPXX first, then refine the generated files.
```

Deliverables checklist (complete when every box is ticked):

- [ ] `resources/feature-brief.md` — brief + epic catalog table.
- [ ] `resources/user-story/epXX-<slug>.md` per epic — `## EPXX.US###` stories with `Status:`, an `As a …` line, and `Acceptance criteria:` (nested bullets = sub-tasks).
- [ ] `resources/technial-design/epXX-<slug>.md` per epic — Technologies · Entry Points · Flow · **Mermaid** · Entities · Tests.
- [ ] `resources/screens/epXX-<slug>-screen.md` per screen — ASCII wireframe + `## Components/States/Events`; events `EventName -> …` referencing the target screen so Flow draws arrows.
- [ ] `resources/srs.md` — all sections + `## Screens / UI Surfaces` (placeholder) + Mermaid **ER** + traceability matrix.
- [ ] `resources/srs.sh` (latest) + `srs-index.html` generated via `./resources/srs.sh`.
- [ ] Verify in `srs-index.html`: **📄 Docs** injects screens · **🔀 Flow** shows arrows from `## Events` · **🗂️ Board** places cards by `Status:`, click a card for description + tasks · box-drawing preserved, no leftover markers.

## Technical notes

- Use `flutter test integration_test` for normal integration tests that do not need a screenshot-saving driver.
- Use `flutter drive` with `integration_test_driver_extended.dart` when screenshot PNG files must be saved.
- Do not write screenshots directly from the app process because simulator/device filesystems can be read-only.
- `onScreenshot` runs in the host driver process, so it is the stable place to write files.

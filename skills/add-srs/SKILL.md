---
name: add-srs
description: Generate or update the repository SRS package from resources/user-story, resources/technial-design, resources/screens ASCII layout documents, and implementation structure, then render srs-index.html through resources/srs.sh. Use when the user wants an SRS document, requirements report, traceability view, screen layout summary, or flow/entity summary.
---

# Add SRS Skill

Use this skill to generate the SRS package for this repository.

The generated `srs-index.html` showcases three interactive, data-driven views from one set of sources:
- **📄 Docs** — full SRS with a sticky table of contents.
- **🔀 Flow** — canvas of screen ASCII mockups connected by navigation arrows inferred from screen `## Events`.
- **🗂️ Board** — sprint kanban (Backlog / To Do / In Progress / In Review / Done) with a List layout + status filters, built from user-story `Status:` lines and acceptance-criteria tasks.

## Core sources
- `resources/srs.md`
- `resources/srs-template.md`
- `resources/srs.sh`
- `resources/user-story/`
- `resources/technial-design/`
- `resources/screens/`
- `lib/presentation/`

## Canonical generator
- `skills/add-srs/assets/srs.sh` is the canonical, up-to-date generator with the Docs / Flow / Board views and styling. When a project has no `resources/srs.sh` (or an older one), copy this asset to `resources/srs.sh` rather than re-authoring it: `cp skills/add-srs/assets/srs.sh resources/srs.sh`.
- After copying, update the hardcoded sidebar heading (`<h2>Flutter POC Auth</h2>`) to the target project's name.

## Migrating an existing project
- To upgrade a project that already has an older single-page `resources/srs.sh`, follow `references/migrate-to-views.md` (copy the canonical generator, add `Status:` lines to user stories, add navigation `## Events` to screens, regenerate). The change is additive: existing docs keep rendering, stories without `Status:` default to `Done`.

## Workflow
1. Read the user-story and technical-design docs for the features being captured.
2. Map them to:
   - requirements summary
   - user stories
   - use cases
   - screens
   - ASCII layout documents
   - flow diagrams
   - entity model
   - NFRs
   - risks and traceability
3. Update `resources/srs.md`.
4. Ensure `resources/srs.sh` exists and renders `srs-index.html` from `resources/srs.md`.
   - If missing or outdated, copy the canonical generator: `cp skills/add-srs/assets/srs.sh resources/srs.sh`.
   - It must read `resources/screens/*.md` and inject each ASCII layout document into the `Screens / UI Surfaces` section.
   - It must preserve box-drawing characters in fenced code blocks.
   - It must emit the Docs / Flow / Board sidebar views (see "Sidebar views" below).
5. Run `./resources/srs.sh` to regenerate `srs-index.html`.
6. Treat `resources/user-story/epXX-<feature>.md`, `resources/technial-design/epXX-<feature>.md`, and `resources/screens/epXX-<feature>-screen.md` as canonical inputs produced by `add-feat`.
7. Keep traceability to the feature's unit, integration, and e2e scripts.

## Example flow
- For a new auth demo, first run `scripts/add_feat.sh gen-tdd auth EP01`.
- Then update `resources/srs.md` with the generated auth story and design docs.
- Add `resources/srs.sh` if it is missing.
- Finally rerun `./resources/srs.sh` to generate `srs-index.html`.

## Required `resources/srs.sh` behavior
- Read `resources/srs.md` as the source of truth.
- Read `resources/screens/*.md` as screen layout sources and render them under `Screens / UI Surfaces`.
- Write `srs-index.html` at the project root.
- Use the standard SRS HTML template: two-column layout, sticky sidebar TOC, `#FCD535` primary accent, Mermaid CDN, table/code/blockquote styling, and auto-open after generation.
- Exit non-zero when `resources/srs.md` is missing.
- Keep output local; do not upload docs to external renderers.

## Sidebar views (Docs / Flow / Board)
The generated `srs-index.html` has a left-sidebar switcher with three views. Keep all three working when editing the generator:
- **Docs** — the rendered `resources/srs.md` plus the injected screen documents, with the sticky TOC.
- **Flow** — a canvas that draws each screen as its ASCII mockup (the first fenced block of each `resources/screens/*.md`) connected by navigation arrows. Arrows come from each screen's `## Events` list: an event `Name -> description` (or `→`) whose description references another screen (by its file id, e.g. `ep02-forgot-password-screen`, or by distinctive title words) becomes a labeled arrow. Screens are auto-ordered into a path so a hub screen sits between the screens it links to. The Flow view shows only the canvas (no detail text) and widens to full width.
- **Board** — a kanban with fixed columns **Backlog / To Do (Sprint) / In Progress / In Review / Done**. Each `## EPXX.US###` story in `resources/user-story/*.md` becomes a card placed by its optional `Status:` line (default `Done`). Cards show only the title; clicking a card opens a dialog with the `As a ...` description and the acceptance-criteria task checklist. A Board/List layout toggle is available; the **List** layout shows a flat list of user stories with status badges and a row of status filter tags (All / Backlog / To Do / …) that filter the list.

## Conventions that drive Flow & Board (produced by `add-feat`)
- Screen files (`resources/screens/epXX-*-screen.md`): first heading = screen name, first fenced block = mockup, `## Events` use `EventName -> description` with the target screen referenced for navigation arrows.
- User-story files (`resources/user-story/epXX-*.md`): `## EPXX.US###: Title`, optional `Status:` line, an `As a ...` description, and an `Acceptance criteria:` bullet list (nested bullets become sub-tasks).

## Rules
- Keep the SRS aligned with current repo structure.
- Include Mermaid flow diagrams and entity relationships when possible.
- Include traceability to tests and e2e scripts.
- Keep the markdown source as the single editable SRS source of truth.

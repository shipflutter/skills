# Add SRS Reference

## Source of truth
- `resources/srs.md` is the editable SRS source.
- `srs-index.html` is generated output.
- `resources/srs.sh` renders markdown to HTML and opens the result.
- `resources/screens/` stores ASCII layout documents for screen-level traceability.
- `resources/user-story/` stores `EPXX.US###` stories that feed the Board.
- `resources/srs.sh` injects `resources/screens/*.md` into the `Screens / UI Surfaces` HTML section.

## Generated views (sidebar switcher)
`srs-index.html` ships three views; the generator builds all three from the same sources:
- **Docs** — rendered `srs.md` + injected screens + sticky TOC.
- **Flow** — canvas of screen ASCII mockups linked by navigation arrows derived from each screen's `## Events`. Source: `resources/screens/*.md` (first fenced block = mockup). An event `Name -> description` (or `→`) that references another screen by file id or title keyword draws an arrow; screens are auto-ordered into a connected path.
- **Board** — kanban with columns Backlog / To Do (Sprint) / In Progress / In Review / Done. Source: `resources/user-story/*.md`. Each `## EPXX.US###` story is a card placed by its optional `Status:` line (default Done); the card shows the title, and a click dialog shows the `As a ...` description plus the acceptance-criteria task checklist.

## Authoring data for Flow & Board
- Navigation arrow: in a screen's `## Events`, write `EventName -> navigate to <target-screen-file-id>` (e.g. `ep02-forgot-password-screen`); add a return event on the target for a two-way connector.
- Board column: add `Status: Backlog` (or `To Do` / `Sprint` / `In Progress` / `In Review` / `Done`) under the story heading; omit for `Done`.

## Required SRS sections
- Executive Summary
- Included Documents
- Requirements Summary
- User Stories & Acceptance Criteria
- Use Cases
- Screens / UI Surfaces
- ASCII Layout Documents
- Flow Diagrams
- State Transitions
- Data Entities
- NFR
- Business Rules
- Error Matrix
- Risks / Assumptions / Open Questions
- Traceability Snapshot
- Verification Plan

## Render command
```bash
./resources/srs.sh
```

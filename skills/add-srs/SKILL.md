---
name: add-srs
description: Generate or update the repository SRS package from resources/user-story, resources/technial-design, resources/screens ASCII layout documents, and implementation structure, then render srs-index.html through resources/srs.sh. Use when the user wants an SRS document, requirements report, traceability view, screen layout summary, or flow/entity summary.
---

# Add SRS Skill

Use this skill to generate the SRS package for this repository.

## Core sources
- `resources/srs.md`
- `resources/srs-template.md`
- `resources/srs.sh`
- `resources/user-story/`
- `resources/technial-design/`
- `resources/screens/`
- `lib/presentation/`

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
   - It must read `resources/screens/*.md` and inject each ASCII layout document into the `Screens / UI Surfaces` section.
   - It must preserve box-drawing characters in fenced code blocks.
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

## Rules
- Keep the SRS aligned with current repo structure.
- Include Mermaid flow diagrams and entity relationships when possible.
- Include traceability to tests and e2e scripts.
- Keep the markdown source as the single editable SRS source of truth.

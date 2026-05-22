---
name: add-srs
description: Generate or update the repository SRS package from resources/user-story, resources/technial-design, and implementation structure, then render srs-index.html through resources/srs.sh. Use when the user wants an SRS document, requirements report, traceability view, or flow/entity summary.
---

# Add SRS Skill

Use this skill to generate the SRS package for this repository.

## Core sources
- `resources/srs.md`
- `resources/srs-template.md`
- `resources/srs.sh`
- `resources/user-story/`
- `resources/technial-design/`
- `lib/presentation/`

## Workflow
1. Read the user-story and technical-design docs for the features being captured.
2. Map them to:
   - requirements summary
   - user stories
   - use cases
   - screens
   - flow diagrams
   - entity model
   - NFRs
   - risks and traceability
3. Update `resources/srs.md`.
4. Run `./resources/srs.sh` to regenerate `srs-index.html`.

## Rules
- Keep the SRS aligned with current repo structure.
- Include Mermaid flow diagrams and entity relationships when possible.
- Include traceability to tests and e2e scripts.
- Keep the markdown source as the single editable SRS source of truth.


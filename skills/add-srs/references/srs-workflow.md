# Add SRS Reference

## Source of truth
- `resources/srs.md` is the editable SRS source.
- `srs-index.html` is generated output.
- `resources/srs.sh` renders markdown to HTML and opens the result.
- `resources/screens/` stores ASCII layout documents for screen-level traceability.
- `resources/srs.sh` injects `resources/screens/*.md` into the `Screens / UI Surfaces` HTML section.

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

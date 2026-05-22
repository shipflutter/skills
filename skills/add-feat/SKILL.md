---
name: add-feat
description: Create a new feature package from repo conventions by writing user-story docs, technical design docs, implementation notes, and test/e2e scaffolding. Use when the user wants to add a feature template or expand a feature using the repo's user-story and technical-design structure.
---

# Add Feature Skill

Use this skill to bootstrap a new feature package in this repository.

## Core sources
- `resources/implement_feat_readme.md`
- `resources/user-story/ep01-ssh-terminal.md`
- `resources/technial-design/ep01-ssh-terminal.md`
- `resources/templates/add-feat/`

## Workflow
1. Read `resources/implement_feat_readme.md` first.
2. Mirror the repo structure:
   - user-story docs in `resources/user-story/`
   - technical design docs in `resources/technial-design/`
   - implementation in `lib/presentation/`
   - integration in `lib/integration/`
   - tests in `test/` and `integration_test/`
   - e2e screenshot runners in `e2e/`
3. For a new feature, create:
   - a feature brief
   - user-story markdown
   - technical-design markdown
   - implementation plan for UI -> bloc -> usecase -> repository/service
   - unit/widget/integration/e2e tests
4. If the user asks to derive docs from source, run:
   - `skills/add-feat/scripts/add_feat.sh gen-tdd <feature-slug> <EPXX>`
   - Example: `skills/add-feat/scripts/add_feat.sh gen-tdd auth EP01`

## Required conventions
- Keep user stories in the form `EPXX.US###`.
- Keep technical design files in the form `epXX-<feature>.md`.
- Include explicit flow steps and entities in the technical design.
- Include screenshot e2e runner names based on the user-story id or epic id.

## Example pattern
Use the bundled sign-in template when the feature calls an API:
- `assets/templates/sign-in-api-service-ft-integration.md`
- Mock the `service_ft` integration boundary in tests.
- Keep API payload mapping in the service layer.

## Script
- `scripts/add_feat.sh gen-tdd <feature-slug> [EPXX]`
- Scans `lib/presentation/<feature-slug>` and creates user-story plus technical-design markdown.

## Output expectations
- Produce markdown templates first.
- Then produce the implementation plan.
- Then produce tests and e2e scaffolding.
- Keep everything aligned with the repo's existing docs and naming.

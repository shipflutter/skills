# Migrate an existing SRS to the Docs / Flow / Board views

Use this when a project already has an older `resources/srs.sh` (single Docs page) and
existing `resources/user-story/*.md` + `resources/screens/*.md`, and you want to upgrade
it to the three-view report (Docs · Flow · Board) without rewriting the content.

The change is **additive and safe**: existing markdown still renders in Docs. Stories
with no `Status:` line default to **Done**; screens with no navigation `## Events`
still appear in Flow, just without arrows.

## Copy-paste prompt for an agent

> Upgrade this project's SRS report to the new Docs / Flow / Board views.
>
> 1. Replace the generator with the canonical one:
>    `cp <skills>/add-srs/assets/srs.sh resources/srs.sh && chmod +x resources/srs.sh`
>    (where `<skills>` is the installed add-srs skill path). Then update the hardcoded
>    sidebar heading `<h2>...</h2>` in `resources/srs.sh` to this project's name.
> 2. **Board** — for every `## EPXX.US###` story in `resources/user-story/*.md`, add a
>    `Status:` line on the line directly under the heading. Use one of
>    `Backlog | To Do | In Progress | In Review | Done` (omit to default to Done).
>    Infer the status from the code/tests: shipped features → `Done`; planned/not-built
>    → `Backlog`; in-flight → `In Progress` / `In Review`.
> 3. **Flow** — in each `resources/screens/*.md`, make sure the screen mockup is the
>    **first** fenced code block, and that `## Events` uses `EventName -> description`
>    (or `→`). For navigation events, reference the target screen in the description by
>    its file id (e.g. `ep02-forgot-password-screen`) or by distinctive title words, and
>    add a return event on the target screen for a two-way arrow.
> 4. Regenerate and verify: `./resources/srs.sh`, then open `srs-index.html` and check
>    the Docs / Flow / Board sidebar switch, that screens link in Flow, and that stories
>    land in the right Board columns.
> 5. Do not delete or reword existing requirements; only add `Status:` lines and
>    navigation `## Events`.

## Checklist

- [ ] `resources/srs.sh` replaced with the bundled canonical generator and re-`chmod +x`.
- [ ] Sidebar heading updated to the project name.
- [ ] Every user story has a `Status:` line (or intentionally defaults to Done).
- [ ] Each screen's mockup is the first fenced block.
- [ ] Navigation `## Events` reference target screens (both directions where applicable).
- [ ] `./resources/srs.sh` runs clean and `srs-index.html` shows all three views.

## Conventions reference

- **Board column** ← `Status:` line under `## EPXX.US###: Title`
  (`Backlog | To Do | Sprint | In Progress | In Review | Done`; `Sprint` maps to To Do).
- **Board card detail** ← the `As a ...` line (description) + `Acceptance criteria:` bullets (tasks; nested bullets become sub-tasks).
- **Flow node** ← the first fenced code block of the screen file (the ASCII mockup).
- **Flow arrow** ← a screen `## Events` entry `EventName -> description` whose description references another screen by file id or title keyword.

## Notes

- The generator only adds `Status:` and navigation `## Events` semantics; it does not
  require any other change to existing docs.
- `Status:` matching is case/spacing-insensitive (`in progress`, `In-Progress`, `InProgress` all work).
- Arrow inference uses whole-word matching, so `auth` will not match inside `AuthService`.

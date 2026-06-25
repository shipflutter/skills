# shipflutter-skills

Flutter testing skills for AI coding agents.

Show case E2E and SRS report:
- https://shipflutter.github.io/vibe/e2e.html
- https://shipflutter.github.io/vibe/srs.html

## npm package

Run the package CLI:

```bash
npx shipflutter-skills list
```

The npm package ships the skill files and a small listing command. Use the open `skills` CLI below to install skills into AI agents.

Publish with an npm token:

```bash
NODE_AUTH_TOKEN='<npm-token>' npm run publish:npm
```

The token must have publish permission. If your npm account uses 2FA, use a granular token with bypass 2FA enabled or publish manually with `--otp`.

## Use with Claude Code

These skills follow the Agent Skills `SKILL.md` format and work with Claude Code natively. There are three ways to make Claude Code use them.

### Option A — Install as a Claude Code plugin (recommended)

The repo ships a plugin marketplace (`.claude-plugin/marketplace.json`). In Claude Code:

```text
/plugin marketplace add shipflutter/skills
/plugin install shipflutter-skills@shipflutter
```

This loads all skills (`add-feat`, `add-srs`, `appdist`, `flutter-integration-test`, `flutter-driver-screenshot-test`, `flutter-unit-test-coverage`, `privacy-safe-device-referral-attributes`) into every Claude Code session. Each skill bundles its own `scripts/`, `assets/`, and `references/`, resolved relative to the skill — no extra setup needed.

### Option B — Copy skills into a project (via the `skills` CLI)

See [Install skills](#install-skills) below to copy individual skills (or all) into `.claude/skills/` for Claude Code, Cursor, and other agents.

### Option C — Work on the skills inside this repo

To let Claude Code load the skills while developing in this repo, symlink them into the project skill path (`.claude/skills`, which is gitignored):

```bash
npm run link:claude
# or: bash scripts/link-claude-skills.sh
```

This creates `.claude/skills -> ../skills` so Claude Code discovers every skill from the source of truth without copying.

## Install skills

List available skills:

```bash
npx skills add shipflutter/skills --list
```

Install all skills for Claude Code in the current project:

```bash
npx skills add shipflutter/skills --skill '*' -a claude-code --copy
```

Install all skills globally for Claude Code:

```bash
npx skills add shipflutter/skills --skill '*' -a claude-code -g --copy
```

Install one skill:

```bash
npx skills add shipflutter/skills --skill add-feat -a claude-code --copy
npx skills add shipflutter/skills --skill add-srs -a claude-code --copy
npx skills add shipflutter/skills --skill flutter-integration-test -a claude-code --copy
npx skills add shipflutter/skills --skill flutter-driver-screenshot-test -a claude-code --copy
npx skills add shipflutter/skills --skill appdist -a claude-code --copy
npx skills add shipflutter/skills --skill flutter-unit-test-coverage -a claude-code --copy
npx skills add shipflutter/skills --skill privacy-safe-device-referral-attributes -a claude-code --copy
```

## Available Skills

| Skill | Description | Example prompt |
|---|---|---|
| [`add-feat`](skills/add-feat/SKILL.md) | Creates feature user-story and technical-design docs, including `gen-tdd` source scanning. | `Run add-feat gen-tdd auth EP01 and create the feature docs.` |
| [`add-srs`](skills/add-srs/SKILL.md) | Generates or updates SRS packages from user-story and technical-design docs. | `Generate the SRS from the current user-story and technical-design docs.` |
| [`appdist`](skills/appdist/SKILL.md) | Automated CI/CD deploy pipeline — iOS TestFlight, Android Firebase App Distribution, and Google Play Store internal testing with Telegram notifications. | `Use $appdist to set up deploy pipeline for iOS and Android.` |
| [`flutter-integration-test`](skills/flutter-integration-test/SKILL.md) | Adds Flutter `integration_test` coverage that runs on emulator/simulator without saving screenshot images. | `Add Flutter integration tests for the main app flow without saving screenshots.` |
| [`flutter-driver-screenshot-test`](skills/flutter-driver-screenshot-test/SKILL.md) | Adds Flutter driver screenshot tests that save PNG files through the host driver process. | `Add e2e screenshot tests for the main screens and save PNG files to screenshots/.` |
| [`flutter-unit-test-coverage`](skills/flutter-unit-test-coverage/SKILL.md) | Adds Flutter unit/widget coverage reporting with `flutter test --coverage` and optional HTML reports. | `Add a run_test.sh script that generates Flutter unit test coverage and an HTML report.` |
| [`privacy-safe-device-referral-attributes`](skills/privacy-safe-device-referral-attributes/SKILL.md) | Adds privacy-safe Flutter Android, iOS, Web, and static Web device/referral attribute demos. | `Add a transparent device referral attributes screen without third-party IP lookup or invasive fingerprinting.` |

## Repository structure

```text
.claude-plugin/            # Claude Code plugin marketplace manifest
├── marketplace.json
└── plugin.json
skills/
├── add-feat/
│   ├── SKILL.md
│   ├── assets/templates/
│   ├── references/
│   └── scripts/add_feat.sh
├── add-srs/
│   └── SKILL.md
├── appdist/
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   ├── scripts/
│   │   ├── deploy.sh
│   │   ├── prod.sh
│   │   ├── prepare.sh
│   │   ├── telegram.sh
│   │   └── upload-playstore.py
│   ├── assets/
│   │   ├── .env.example
│   │   ├── app_dist_template/
│   │   │   └── README.md
│   │   └── github_workflows/
│   │       └── deploy-uat.yml
│   └── references/
│       ├── EP01.US001.md
│       └── ep01-shipflutter-deploy.md
├── flutter-integration-test/
│   ├── SKILL.md
│   └── scripts/
│       └── integration_test.sh
├── flutter-driver-screenshot-test/
│   ├── SKILL.md
│   └── scripts/
│       └── e2e.sh
├── flutter-unit-test-coverage/
│   ├── SKILL.md
│   └── scripts/
│       └── run_test.sh
└── privacy-safe-device-referral-attributes/
    ├── SKILL.md
    ├── examples/
    │   └── prompts.md
    └── reference/
        └── attribute-contract.md
```

## Feature docs workflow

Use `add-feat gen-tdd` to derive user-story and technical-design docs from a Flutter feature source tree:

```bash
scripts/add_feat.sh gen-tdd auth EP01
```

The command creates:

- `resources/user-story/ep01-auth.md`
- `resources/technial-design/ep01-auth.md`

Use `add-srs` after that to compile the generated docs into `resources/srs.md` and render `srs-index.html` through `resources/srs.sh`.

### SRS report views — Docs · Flow · Board

The generated `srs-index.html` ships a left-sidebar switcher with three views, all built from the same `resources/` sources:

- **📄 Docs** — the full SRS: purpose, scope, user stories, requirements, use cases, entities, traceability, and every screen's ASCII layout, with a sticky table of contents.
- **🔀 Flow** — a canvas that renders each screen's real ASCII mockup and connects them with the navigation events from each screen's `## Events`. Screens auto-order into a path so a hub screen (e.g. sign-in) sits between the screens it links to.
- **🗂️ Board** — a sprint kanban with **Backlog / To Do / In Progress / In Review / Done** columns. Each user story becomes a card placed by its `Status:` line; clicking a card opens its full description and acceptance-criteria task checklist. A **List** layout adds status filter tags to slice the stories.

Two conventions wire these up (emitted by `add-feat gen-tdd`):

- Screen `## Events` written as `EventName -> description` (or `→`) referencing the target screen draw the **Flow** arrows.
- A `Status:` line under each `## EPXX.US###` story places it on the **Board**.

Live demo: <https://shipflutter.github.io/vibe/srs.html>

## Device referral fingerprint POC

The repository includes `examples/flutter-poc-fingerprint` as a runnable reference for privacy-safe device/referral attributes.

```mermaid
flowchart TD
  A[User opens device page or POC] --> B{Runtime}
  B -->|Android| C[Load safe Android attributes]
  B -->|iOS| D[Load safe iOS attributes]
  B -->|Flutter Web| E[Load browser attributes]
  B -->|Static Web| F[Run device.html JavaScript]
  C --> G[Normalize allowed device fields]
  D --> G
  E --> G
  F --> G
  A --> H[Parse allowlisted referral params]
  H --> I[Generate local SHA-256 hash]
  G --> I
  I --> J[Render transparent JSON report]
```

Implemented attributes include platform, OS/browser version, model/manufacturer where available, locale, timezone, screen size, device pixel ratio, referrer, and allowlisted referral params. Public IP is documented as unavailable without a same-origin backend endpoint.

## Auth POC

The repository includes `examples/flutter-poc-auth` as a runnable reference for the `add-feat` and `add-srs` workflows.

It demonstrates:

- Sign-in and sign-up UI states.
- Local auth service boundary.
- User-story and technical-design docs under `resources/`.
- Unit and integration tests.

```bash
cd examples/flutter-poc-auth
../../scripts/add_feat.sh gen-tdd auth EP01
./resources/srs.sh
flutter pub get
flutter test
```

## Notes

- The install source is `shipflutter/skills` because the GitHub repository is `https://github.com/shipflutter/skills`.
- The package display name is `shipflutter-skills`.
- Skills follow the Agent Skills `SKILL.md` format with `name` and `description` frontmatter.
- Claude Code discovers skills from `.claude/skills/` (project) and `~/.claude/skills/` (global), or from an installed plugin. The repo's `.claude-plugin/` manifest exposes all skills as the `shipflutter-skills` plugin.

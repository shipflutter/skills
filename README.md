# shipflutter-skills

Flutter testing skills for AI coding agents.

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
npx skills add shipflutter/skills --skill flutter-integration-test -a claude-code --copy
npx skills add shipflutter/skills --skill flutter-driver-screenshot-test -a claude-code --copy
npx skills add shipflutter/skills --skill flutter-unit-test-coverage -a claude-code --copy
npx skills add shipflutter/skills --skill privacy-safe-device-referral-attributes -a claude-code --copy
```

## Available Skills

| Skill | Description | Example prompt |
|---|---|---|
| [`flutter-integration-test`](skills/flutter-integration-test/SKILL.md) | Adds Flutter `integration_test` coverage that runs on emulator/simulator without saving screenshot images. | `Add Flutter integration tests for the main app flow without saving screenshots.` |
| [`flutter-driver-screenshot-test`](skills/flutter-driver-screenshot-test/SKILL.md) | Adds Flutter driver screenshot tests that save PNG files through the host driver process. | `Add e2e screenshot tests for the main screens and save PNG files to screenshots/.` |
| [`flutter-unit-test-coverage`](skills/flutter-unit-test-coverage/SKILL.md) | Adds Flutter unit/widget coverage reporting with `flutter test --coverage` and optional HTML reports. | `Add a run_test.sh script that generates Flutter unit test coverage and an HTML report.` |
| [`privacy-safe-device-referral-attributes`](skills/privacy-safe-device-referral-attributes/SKILL.md) | Adds privacy-safe Flutter Android, iOS, Web, and static Web device/referral attribute demos. | `Add a transparent device referral attributes screen without third-party IP lookup or invasive fingerprinting.` |

## Repository structure

```text
skills/
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

## Device referral fingerprint POC

The repository includes `example/flutter-poc-fingerprint` as a runnable reference for privacy-safe device/referral attributes.

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

## Notes

- The install source is `shipflutter/skills` because the GitHub repository is `https://github.com/shipflutter/skills`.
- The package display name is `shipflutter-skills`.
- Skills follow the Agent Skills `SKILL.md` format with `name` and `description` frontmatter.

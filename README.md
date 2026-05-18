# shipflutter-skills

Flutter testing skills for AI coding agents.

## npm package

Run the package CLI:

```bash
npx shipflutter-skills list
```

The npm package ships the skill files and a small listing command. Use the open `skills` CLI below to install skills into AI agents.

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
```

## Skills

| Skill | Purpose |
|---|---|
| `flutter-integration-test` | Adds Flutter `integration_test` coverage that runs on emulator/simulator without saving screenshot images. |
| `flutter-driver-screenshot-test` | Adds Flutter driver screenshot tests that save PNG files through the host driver process. |

## Repository structure

```text
skills/
├── flutter-integration-test/
│   ├── SKILL.md
│   └── scripts/
│       └── integration_test.sh
└── flutter-driver-screenshot-test/
    ├── SKILL.md
    └── scripts/
        └── e2e.sh
```

## Notes

- The install source is `shipflutter/skills` because the GitHub repository is `https://github.com/shipflutter/skills`.
- The package display name is `shipflutter-skills`.
- Skills follow the Agent Skills `SKILL.md` format with `name` and `description` frontmatter.

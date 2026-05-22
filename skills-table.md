# Skills Directory Table

| Scope | Path | Applies to | When to use |
|---|---|---|---|
| Enterprise | Managed settings | All users in an organization | Organization-wide shared skills and policy-controlled workflows. |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All projects for the current user | Reusable personal skills across many projects. |
| Project | `.claude/skills/<skill-name>/SKILL.md` | Current project only | Repo-specific workflows, coding conventions, test setup, deploy scripts. |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Projects where the plugin is enabled | Packaged skills shared as a plugin. |

## Recommended structure

```text
.claude/
└── skills/
    ├── flutter-integration-test/
    │   ├── SKILL.md
    │   └── scripts/
    │       └── integration_test.sh
    └── flutter-driver-screenshot-test/
        ├── SKILL.md
        ├── scripts/
        │   └── e2e.sh
        └── templates/
            ├── screenshot_helper.dart
            └── integration_test_driver.dart
```

## Generic skill structure

```text
skill-name/
├── SKILL.md              # Required entrypoint
├── scripts/              # Optional executable scripts
│   └── run.sh
├── templates/            # Optional starter files
│   └── example.dart
├── examples/             # Optional examples of expected output
│   └── sample.md
└── reference/            # Optional long-form documentation
    └── notes.md
```

## Required SKILL.md frontmatter

```markdown
---
name: skill-name
description: Describe what this skill does and when an AI agent should use it.
---

# Skill Title

Instructions for the AI agent.
```

## Flutter test skills

| Skill | Folder | Purpose | Script |
|---|---|---|---|
| Add SRS | `.claude/skills/add-srs/` | Generates or updates SRS packages from user-story and technical-design docs. | `scripts/render_srs.sh` |
| Flutter Integration Test | `.claude/skills/flutter-integration-test/` | Adds integration tests that run on emulator/simulator without saving screenshots. | `scripts/integration_test.sh` |
| Flutter Driver Screenshot Test | `.claude/skills/flutter-driver-screenshot-test/` | Adds `flutter drive` screenshot tests that save PNG files on the host machine. | `scripts/e2e.sh` |
| Privacy-Safe Device Referral Attributes | `.claude/skills/privacy-safe-device-referral-attributes/` | Adds transparent Flutter/Web device and referral attribute POCs without invasive fingerprinting. | N/A |

## Notes

- Use project skills for repo-specific behavior.
- Use personal skills for reusable workflows across projects.
- Keep `SKILL.md` concise; move long examples, scripts, and templates into supporting files.
- Reference supporting files from `SKILL.md` so the AI agent knows when to load them.

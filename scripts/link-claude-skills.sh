#!/usr/bin/env bash
# Make this repo's skills discoverable by Claude Code running inside the repo.
# Claude Code loads project skills from .claude/skills/<name>/SKILL.md.
# .claude is gitignored, so we symlink it to the source-of-truth skills/ dir.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

mkdir -p .claude

if [ -L .claude/skills ]; then
  rm .claude/skills
elif [ -e .claude/skills ]; then
  echo "error: .claude/skills exists and is not a symlink — remove it manually" >&2
  exit 1
fi

ln -s ../skills .claude/skills
echo "Linked .claude/skills -> ../skills"
echo "Skills available to Claude Code in this repo:"
ls -1 skills

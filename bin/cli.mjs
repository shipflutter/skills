#!/usr/bin/env node

import { readdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const rootDir = dirname(dirname(fileURLToPath(import.meta.url)));
const skillsDir = join(rootDir, 'skills');
const command = process.argv[2] ?? 'help';

function listSkills() {
  const skills = readdirSync(skillsDir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name)
    .sort();

  for (const skill of skills) {
    const skillPath = join(skillsDir, skill, 'SKILL.md');
    const content = readFileSync(skillPath, 'utf8');
    const description = content.match(/^description:\s*(.+)$/m)?.[1] ?? '';
    console.log(`${skill}${description ? ` - ${description}` : ''}`);
  }
}

function printHelp() {
  console.log(`shipflutter-skills

Flutter testing skills for AI coding agents.

Usage:
  shipflutter-skills list

Install with the open skills CLI:
  npx skills add shipflutter/skills --list
  npx skills add shipflutter/skills --skill '*' -a claude-code --copy
`);
}

if (command === 'list' || command === 'ls') {
  listSkills();
} else {
  printHelp();
}

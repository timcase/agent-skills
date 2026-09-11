# Taskwarrior Skill

This repository contains an agent skill for using the [Taskwarrior](https://taskwarrior.org/) CLI from Codex or Claude.
It gives the agent structured guidance for adding, listing, modifying, completing, deleting, and syncing tasks, including advanced features like filters, dependencies, recurrence, urgency, and UDAs.

## What Is Included

- `SKILL.md`: Main skill definition and operational guidance
- `references/`: Focused reference docs (`filters`, `dates`, `dependencies`, `projects`, `recurrence`, `udas`, `urgency`, etc.)

## Prerequisites

- Taskwarrior installed and available on PATH (`task --version`)
- A working Taskwarrior config (`~/.taskrc`) if you plan to use sync/advanced settings

## Installation

Use whichever agent you run.

### Install For Codex

Codex loads local skills from:

```bash
$HOME/.codex/skills
```

Install this skill as `taskwarrior`:

```bash
mkdir -p "$HOME/.codex/skills"
git clone https://github.com/timcase/taskwarrior-agent-skill.git "$HOME/.codex/skills/taskwarrior"
```

If you already cloned this repo elsewhere:

```bash
mkdir -p "$HOME/.codex/skills"
cp -R /path/to/this/repo "$HOME/.codex/skills/taskwarrior"
```

### Install For Claude

Claude loads local skills from:

```bash
$HOME/.claude/skills
```

Install this skill as `taskwarrior`:

```bash
mkdir -p "$HOME/.claude/skills"
git clone https://github.com/timcase/taskwarrior-agent-skill.git "$HOME/.claude/skills/taskwarrior"
```

If you already cloned this repo elsewhere:

```bash
mkdir -p "$HOME/.claude/skills"
cp -R /path/to/this/repo "$HOME/.claude/skills/taskwarrior"
```

## Usage

After installation, ask the agent to use the `taskwarrior` skill when you want task operations such as:

- Add tasks with attributes (`project:`, `+tags`, `due:`, `priority:`)
- Filter and list tasks (`project:Work +urgent`, `overdue`, date windows)
- Update tasks in bulk (`modify`, `done`, `delete` with filters)
- Manage dependencies and recurring tasks
- Sync with a task server (`task sync`)

Example requests:

- "Use the taskwarrior skill to add a high-priority task due tomorrow."
- "List all overdue tasks in my Work project."
- "Schedule all `+important` tasks for tomorrow."

## Notes

- For safety, preview bulk filters with `list` before `modify`/`delete`.
- The skill includes separate references in `references/` so agents can load only the docs needed for a given task.

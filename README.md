# Agent Tools Skills

A collection of installable agent skills for common command-line tools.

This repository currently includes:

- `gh-cli` (GitHub CLI)
- `doctl` (DigitalOcean CLI)
- `s3cmd` (S3-compatible object storage CLI)

Each skill includes:

- `SKILL.md` with usage guidance for the agent
- an `install.sh` script to install that skill into your local skills directory

## Install a Skill

Run the installer for the skill you want:

```bash
./gh-cli/install.sh
./doctl/install.sh
./s3cmd/install.sh
```

By default, each installer:

1. Clones `https://github.com/timcase/agent-skills.git` into `~/.claude/skills/agent-skills` (if needed)
2. Creates a symlink for the selected skill in `~/.claude/skills/<skill-name>`

## Installer Options

All three installer scripts support the same options:

```text
--repo <url>            Repo URL
--path <subdir>         Subdirectory in repo to install
--dest <dir>            Destination base directory (default: ~/.claude/skills)
--method <clone|archive>
--force                 Replace existing destination
-h, --help              Show help
```

## Examples

Install with defaults:

```bash
./doctl/install.sh
```

Replace an existing installation:

```bash
./s3cmd/install.sh --force
```

Install without keeping a local clone:

```bash
./gh-cli/install.sh --method=archive
```

Install to a custom destination:

```bash
./gh-cli/install.sh --dest ~/.claude/skills
```

Install from a different repo or subpath:

```bash
./gh-cli/install.sh --repo https://github.com/timcase/agent-skills.git --path gh-cli
```

## Updating Installed Skills

If installed with the default `clone` method:

```bash
cd ~/.claude/skills/agent-skills
git pull
```

If installed with `--method=archive`, re-run the installer with `--force`.

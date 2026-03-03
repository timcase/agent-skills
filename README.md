# Agent Tools Skills

A collection of installable agent skills for common command-line tools.

This repository currently includes:

- `gh-cli` (GitHub CLI)
- `doctl` (DigitalOcean CLI)
- `s3cmd` (S3-compatible object storage CLI)

Each skill includes:

- `SKILL.md` with usage guidance for the agent
- an `install.sh` script to install that skill into your local skills directory

## Skills

- `gh-cli`: [gh-cli/SKILL.md](gh-cli/SKILL.md)
- `doctl`: [doctl/SKILL.md](doctl/SKILL.md)
- `s3cmd`: [s3cmd/SKILL.md](s3cmd/SKILL.md)

## Install a Skill

Run the installer for the skill you want (via `curl`):

```bash
curl -fsSL https://raw.githubusercontent.com/timcase/agent-skills/main/gh-cli/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/timcase/agent-skills/main/doctl/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/timcase/agent-skills/main/s3cmd/install.sh | bash
```

By default, each installer:

1. Clones `https://github.com/timcase/agent-skills.git` into `~/.claude/skills/agent-skills` (if needed)
2. Creates a symlink for the selected skill in `~/.claude/skills/<skill-name>`

## Install All Skills

Use the root installer to install `gh-cli`, `doctl`, and `s3cmd` together:

```bash
curl -fsSL https://raw.githubusercontent.com/timcase/agent-skills/main/install.sh | bash
```

You can also pass options through bash:

```bash
curl -fsSL https://raw.githubusercontent.com/timcase/agent-skills/main/install.sh | bash -s -- --force
curl -fsSL https://raw.githubusercontent.com/timcase/agent-skills/main/install.sh | bash -s -- --method=archive
curl -fsSL https://raw.githubusercontent.com/timcase/agent-skills/main/install.sh | bash -s -- --dest ~/.claude/skills
```

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
curl -fsSL https://raw.githubusercontent.com/timcase/agent-skills/main/doctl/install.sh | bash
```

Replace an existing installation:

```bash
curl -fsSL https://raw.githubusercontent.com/timcase/agent-skills/main/s3cmd/install.sh | bash -s -- --force
```

Install without keeping a local clone:

```bash
curl -fsSL https://raw.githubusercontent.com/timcase/agent-skills/main/gh-cli/install.sh | bash -s -- --method=archive
```

Install to a custom destination:

```bash
curl -fsSL https://raw.githubusercontent.com/timcase/agent-skills/main/gh-cli/install.sh | bash -s -- --dest ~/.claude/skills
```

Install from a different repo or subpath:

```bash
curl -fsSL https://raw.githubusercontent.com/timcase/agent-skills/main/gh-cli/install.sh | bash -s -- --repo https://github.com/timcase/agent-skills.git --path gh-cli
```

## Updating Installed Skills

If installed with the default `clone` method:

```bash
cd ~/.claude/skills/agent-skills
git pull
```

If installed with `--method=archive`, re-run the installer with `--force`.

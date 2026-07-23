# Agent Tools Skills

A collection of installable agent skills for common command-line tools and services.

Each skill includes:

- `SKILL.md` with usage guidance for the agent
- an `install.sh` script that symlinks the skill into your local skills directories

## Skills

| Skill | Description |
| --- | --- |
| [`1password`](1password/SKILL.md) | Manage 1Password vaults/secrets with the `op` CLI: read secrets, secret references (`op://`), items, TOTP, documents. |
| [`aws-cli`](aws-cli/SKILL.md) | AWS CLI (`aws`) for querying and managing AWS resources, including S3 operations. |
| [`azuracast`](azuracast/SKILL.md) | Manage an AzuraCast web radio station via its REST API. |
| [`beets`](beets/SKILL.md) | Manage music libraries with the `beets` CLI: import, fix tags, query, organize, album art, ReplayGain. |
| [`cinc-client`](cinc-client/SKILL.md) | Manage infrastructure using `cinc-client` (FOSS Chef Infra Client). |
| [`cloudflare`](cloudflare/SKILL.md) | Manage Cloudflare DNS records and R2 object storage via API. |
| [`doctl`](doctl/SKILL.md) | DigitalOcean CLI (`doctl`): Droplets, registries, Spaces, firewalls, load balancers, VPCs, domains. |
| [`gh-cli`](gh-cli/SKILL.md) | GitHub CLI (`gh`): repos, issues, pull requests, Actions, projects, releases, gists, and more. |
| [`hcloud`](hcloud/SKILL.md) | Manage Hetzner Cloud resources with the `hcloud` CLI. |
| [`knife`](knife/SKILL.md) | Manage Chef/Cinc infrastructure with the `knife` CLI: nodes, roles, cookbooks, data bags, vault. |
| [`knup`](knup/SKILL.md) | Deployment script for `~/Sites/cinc` that bumps cookbook versions and uploads artifacts via `knife`. |
| [`newrelic`](newrelic/SKILL.md) | Interact with New Relic via the `newrelic` CLI: NRQL, APM, NerdGraph, Synthetics. |
| [`postmark`](postmark/SKILL.md) | Send emails and manage templates with the Postmark CLI. |
| [`proton-pass`](proton-pass/SKILL.md) | Manage Proton Pass vaults and secrets with `pass-cli`. |
| [`s3cmd`](s3cmd/SKILL.md) | Manage S3-compatible object storage (AWS S3, DigitalOcean Spaces) with `s3cmd`. |
| [`sentry`](sentry/SKILL.md) | Manage and query Sentry error reports with `sentry-cli`. |
| [`skill-creator`](skill-creator/SKILL.md) | Guide for creating and updating effective agent skills. |

## Install

The installers symlink the local skill directory into your skills directories, so
start by cloning this repository:

```bash
git clone https://github.com/timcase/agent-skills.git
cd agent-skills
```

### Install a single skill

Run the installer inside the skill you want:

```bash
./gh-cli/install.sh
./doctl/install.sh
./s3cmd/install.sh
```

Each installer creates a symlink for that skill in **both**:

- `~/.claude/skills/<skill-name>` (Claude Code)
- `~/.codex/skills/<skill-name>` (Codex)

### Install all skills

Use the root installer to install the bundled set at once:

```bash
./bin/install.sh
```

## Installer Options

Both the root and per-skill installers accept the same options:

```text
--dest <dir>    Primary destination base dir (default: ~/.claude/skills).
                The skill is also always installed to ~/.codex/skills.
--force         Replace an existing destination.
-h, --help      Show help.
```

Examples:

```bash
# Replace an existing installation
./s3cmd/install.sh --force

# Install to a custom primary destination
./gh-cli/install.sh --dest ~/.claude/skills

# Install every bundled skill, replacing existing links
./bin/install.sh --force
```

## Updating Installed Skills

Because skills are symlinked from your local clone, just pull the latest changes:

```bash
cd agent-skills
git pull
```

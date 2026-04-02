---
name: gh-cli
description: GitHub CLI (gh) comprehensive reference for repositories, issues, pull requests, Actions, projects, releases, gists, codespaces, organizations, extensions, and all GitHub operations from the command line.
---

# GitHub CLI (gh)

**Version:** 2.85.0+ | Official docs: https://cli.github.com/manual/

## Authentication

```bash
gh auth login                                        # interactive
gh auth login --hostname enterprise.internal         # GitHub Enterprise
gh auth login --with-token < mytoken.txt             # token from file
gh auth status
gh auth status --show-token
gh auth switch --hostname github.com --user username
gh auth token                                        # print active token
gh auth refresh --scopes write:org,read:public_key
gh auth setup-git                                    # configure git credential helper
```

## Configuration

```bash
gh config list
gh config get editor
gh config set editor vim
gh config set git_protocol ssh
gh config set pager "less -R"
gh config set prompt disabled
gh config clear-cache
```

### Environment Variables

| Variable | Purpose |
|---|---|
| `GH_TOKEN` | Auth token for automation |
| `GH_HOST` | GitHub hostname |
| `GH_REPO` | Override default repository |
| `GH_PROMPT_DISABLED` | Disable interactive prompts |
| `GH_EDITOR` | Custom editor |
| `GH_PAGER` | Custom pager |
| `GH_ENTERPRISE_HOSTNAME` | Enterprise hostname |

## Global Flags

| Flag | Description |
|---|---|
| `--repo [HOST/]OWNER/REPO` | Select repository |
| `--hostname HOST` | GitHub hostname |
| `--jq EXPRESSION` | Filter JSON output |
| `--json FIELDS` | Output JSON with fields |
| `--template STRING` | Format with Go template |
| `--web` | Open in browser |
| `--paginate` | Fetch all pages |

## Output Formatting

```bash
# JSON + jq
gh repo view --json name,description
gh repo view --json owner,name --jq '.owner.login + "/" + .name'
gh pr list --json number,title --jq '.[] | select(.number > 100)'

# Go template
gh repo view --template '{{.name}}: {{.description}}'
```

## Browse

```bash
gh browse                          # open repo in browser
gh browse 123                      # open issue/PR
gh browse main.go:312              # open file at line
gh browse --branch bug-fix main.go
gh browse --actions / --projects / --releases / --settings
gh browse --no-browser             # print URL only
```

## Reference Files

Load these as needed:

- **[repos.md](references/repos.md)** — `gh repo` commands (create, clone, fork, sync, edit, deploy keys, autolinks)
- **[issues-prs.md](references/issues-prs.md)** — `gh issue` and `gh pr` commands
- **[actions.md](references/actions.md)** — `gh run`, `gh workflow`, `gh cache`, `gh secret`, `gh variable`
- **[projects-releases.md](references/projects-releases.md)** — `gh project` and `gh release` commands
- **[misc.md](references/misc.md)** — gists, codespaces, orgs, search, labels, SSH/GPG keys, extensions, aliases, `gh api`, rulesets, attestations
- **[workflows.md](references/workflows.md)** — common workflow patterns, bulk operations, best practices

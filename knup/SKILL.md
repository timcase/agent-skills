---
name: knup
description: >
  knup is a custom deployment script for the Cinc/Chef repo at ~/Sites/cinc. It automatically
  detects git-modified files, bumps cookbook versions, uploads changed artifacts to the Cinc
  Server via knife, then commits and pushes the repo. Use whenever changes to cookbooks, nodes,
  roles, or data bags need to be deployed to the Chef server. Always run knup after editing any
  file in ~/Sites/cinc to publish changes. Triggers on: "run knup", "deploy cinc changes",
  "push cookbook", "publish changes", "upload and commit", "sync cinc", "update chef server".
---

# knup

`knup` is the single command to deploy all changes to the Cinc repo. No arguments, no flags.

```bash
knup
```

Run it from anywhere — it always operates on `/home/tcase/Sites/cinc`.

## What knup Does

1. **Detects changes** using `git ls-files -mo` (modified + untracked) in each artifact directory
2. **Cookbooks** — for each changed cookbook: runs `rake version:bump` (patch bump), then `knife cookbook upload <name>`
3. **Nodes** — runs `knife node from file <files>` for all changed node JSONs
4. **Roles** — runs `knife role from file <files>` for all changed role JSONs
5. **Data bags** — runs `knife data bag from file <bag> <item> --secret-file ~/.ssh/encrypted_data_bag_secret` for each changed item
6. **Commits & pushes** — runs `git aa && git cnm && git p` (add all, commit with no-edit/auto message, push)
7. **Notifies** — desktop notification + sound on completion

If no git-modified files are found, knup exits with "No changes detected" and does nothing.

## Typical Workflow

```bash
# 1. Edit something in the cinc repo
cd ~/Sites/cinc
vim cookbooks/devmachine/recipes/docker.rb

# 2. Run knup — it handles versioning, upload, and commit automatically
knup
```

## What Triggers Each Upload Type

| Changed file location | knup action |
|----------------------|-------------|
| `cookbooks/<name>/` | `rake version:bump` + `knife cookbook upload <name>` |
| `nodes/<name>.json` | `knife node from file <name>.json` |
| `roles/<name>.json` | `knife role from file <name>.json` |
| `data_bags/<bag>/<item>.json` | `knife data bag from file <bag> <item> --secret-file ~/.ssh/encrypted_data_bag_secret` |

## Important Behaviors

- **Cookbook version is always bumped (patch)** before upload — even for minor/trivial edits. This is by design.
- **Detection is git-based**: only files git considers modified or untracked are processed. Staged-but-not-committed files are included (`-mo` flag).
- **Data bags are always uploaded encrypted** using `~/.ssh/encrypted_data_bag_secret`.
- **The git commit is automatic** — knup commits everything with a pre-configured message via `git cnm` (a git alias). There is no prompt.
- **knup has no dry-run mode** — running it applies all changes immediately.

## When NOT to Use knup

- To converge a node (run `sudo cinc-client` on the target node instead)
- To check what would change without applying (use `knife` commands directly)
- To upload a single artifact manually (use `knife cookbook upload <name>` etc. directly)

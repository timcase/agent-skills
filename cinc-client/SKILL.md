---
name: cinc-client
description: >
  Manage infrastructure configuration using cinc-client (FOSS Chef Infra Client drop-in replacement).
  Use when the user asks to: apply configuration to nodes, run Chef/Cinc recipes or roles, do dry-run
  convergence, develop or test cookbooks, manage nodes/roles/data bags, debug convergence failures,
  or work with the Cinc/Chef server. Triggers on: "run cinc", "apply config", "converge node",
  "why-run", "test cookbook", "kitchen test", "chef recipe", "cinc recipe", "add role", "update node".
---

# cinc-client Skill

Cinc Client 18.6.2 at `/bin/cinc-client`. Config: `/etc/cinc/client.rb`. Chef server: `https://spinoza.ekamai.net/organizations/ekamai`. Local repo: `/home/tcase/Sites/cinc/`.

## Common Operations

### Apply configuration

```bash
# Apply this node's run list from server
sudo cinc-client

# Local mode with node JSON (no server needed)
sudo cinc-client -z -j nodes/$(hostname).json

# Override run list for a single run
sudo cinc-client -z -o 'role[devmachine]'
sudo cinc-client -z -o 'recipe[base::packages]'

# Dry run (show changes without applying)
sudo cinc-client -z --why-run
sudo cinc-client --why-run   # against server
```

### Useful flags

| Flag | Purpose |
|------|---------|
| `-z` | Local mode (uses `/home/tcase/Sites/cinc/`) |
| `-j FILE` | Load node attributes from JSON |
| `-o RUNLIST` | Override run list for this run only |
| `-W` / `--why-run` | Dry run |
| `-l debug` | Debug logging |
| `--once` | Run once, ignore interval/splay |
| `-E ENV` | Set environment |

## Cookbook Development

### Test Kitchen workflow (run inside cookbook dir)

```bash
cd /home/tcase/Sites/cinc/cookbooks/<name>

kitchen list          # show test suites/platforms
kitchen converge      # apply recipes to test instance
kitchen verify        # run InSpec tests
kitchen test          # full cycle: provision+converge+verify+destroy
kitchen destroy       # tear down test instances
kitchen login         # SSH into test instance
```

### Version bumping

```bash
rake version:bump:patch   # 0.1.0 → 0.1.1
rake version:bump:minor   # 0.1.0 → 0.2.0
rake version:bump:major   # 0.1.0 → 1.0.0
```

### Policyfile management

```bash
chef install Policyfile.rb     # resolve and install dependencies
chef update Policyfile.rb      # update lock file
chef export Policyfile.rb      # export for deployment
```

## Repository Structure

```
/home/tcase/Sites/cinc/
├── cookbooks/   base, common, devmachine, desktop, pihole, remote, repos, ruby, nodejs, taskwarrior
├── roles/       debian_derivative, devmachine, desktop, ekamai, local_essentials, pihole, …
├── nodes/       per-machine JSON (ella, jaco, socrates, airweave, coltrane, …)
└── data_bags/   users/, cronjobs/, ekamai/, vault/
```

See `references/repo-patterns.md` for cookbook internals, recipe patterns, data bag usage, and role composition.

## Node Management

```bash
# List nodes
knife node list

# Show node details
knife node show <nodename>

# Apply config to a new node in local mode
sudo cinc-client -z -j nodes/<hostname>.json
```

To add a new machine: create `nodes/<hostname>.json` with roles and attributes, then run the local-mode command above on that machine.

## Debugging

```bash
# Verbose output
sudo cinc-client -l debug 2>&1 | tee /tmp/cinc-debug.log

# Run single recipe for quick iteration
sudo cinc-client -z -o 'recipe[base::users]' -l debug

# Dry-run with debug for attribute inspection
sudo cinc-client -z -j nodes/$(hostname).json --why-run -l debug
```

When a run fails, identify the failing resource and its cookbook/recipe. Use `-l debug` to see full resource execution and template rendering output.

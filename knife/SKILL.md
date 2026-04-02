---
name: knife
description: "Manage Chef/Cinc infrastructure using the knife CLI. Use for: nodes, roles, cookbooks, data bags, run lists, environments, bootstrapping, knife ssh, or vault items. Triggers on 'knife', 'Chef server', 'bootstrap node', or 'knife vault'."
---

# knife Skill

knife is configured via `/home/tcase/.cinc/config.rb` (aliased as `knife`). Chef server: `https://spinoza.ekamai.net/organizations/ekamai`.

**Known nodes:** airweave, coltrane, desktop, ella, fathead, jaco, nina, ruby, socrates, spinoza, tcase, voltaire
**Known roles:** debian_derivative, devmachine, desktop, ekamai, local_essentials, nodejs, pihole, remote_access, ruby, taskwarrior
**Known cookbooks:** base, common, desktop, devmachine, nodejs, pihole, remote, repos, ruby, taskwarrior

## Node Management

```bash
knife node list
knife node show <node>
knife node edit <node>                           # opens $EDITOR

# Run list management
knife node run_list add <node> 'role[devmachine]'
knife node run_list remove <node> 'role[nodejs]'
knife node run_list set <node> 'role[debian_derivative],role[devmachine]'

# Set/change environment
knife node environment set <node> production
```

## Search

Knife search uses Solr syntax against node attributes, roles, recipes, platform, etc.

```bash
# Find nodes by role
knife search node 'role:devmachine'

# Find by platform
knife search node 'platform:ubuntu'

# Find by recipe in run list
knife search node 'recipes:devmachine\:\:docker'

# Find by attribute
knife search node 'hostname:jaco'

# All nodes
knife search node 'name:*'

# Output as JSON
knife search node 'role:devmachine' -F json
```

## Cookbook Management

```bash
knife cookbook list
knife cookbook show <name>
knife cookbook show <name> <version>

# Upload from local repo (run from /home/tcase/Sites/cinc)
knife cookbook upload <name>
knife cookbook upload --all          # upload all cookbooks
```

## Data Bags

```bash
knife data bag list
knife data bag show <bag>
knife data bag show <bag> <item>
knife data bag edit <bag> <item>
knife data bag from file <bag> <file.json>

# Encrypted data bags
knife data bag show vault secrets --secret-file /etc/cinc/encrypted_data_bag_secret
```

## Vault (knife-vault)

```bash
knife vault list
knife vault show <vault> [item]
knife vault edit <vault> <item>
knife vault create <vault> <item> '{"key": "value"}' -S 'role:devmachine'
knife vault update <vault> <item> '{"key": "value"}'
knife vault rotate keys <vault> <item>
```

## Roles

```bash
knife role list
knife role show <role>
knife role edit <role>
knife role from file roles/<role>.json    # upload from local file
```

## SSH (run commands on nodes)

```bash
# Run command on nodes matching a search query
knife ssh 'role:devmachine' 'sudo cinc-client'
knife ssh 'name:jaco' 'uptime'

# With specific user
knife ssh 'role:devmachine' -x tcase 'sudo apt update'
```

## Bootstrap a New Node

```bash
knife bootstrap <host> -N <nodename> \
  --run-list 'role[debian_derivative],role[local_essentials]' \
  -x <user> --sudo
```

## Output Formats

```bash
knife node show jaco -F json    # JSON output
knife node show jaco -F yaml    # YAML output
knife node show jaco -a run_list  # show specific attribute only
```

## Detailed References

- **Data bag patterns & vault**: See `references/data-bags.md`
- **Search query syntax**: See `references/search.md`

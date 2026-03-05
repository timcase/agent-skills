# knife search Reference

knife search uses Apache Solr syntax. General form:

```bash
knife search <index> '<query>' [options]
```

**Indexes:** `node`, `role`, `environment`, `client`, or any data bag name (e.g. `users`)

## Query Syntax

| Pattern | Example | Meaning |
|---------|---------|---------|
| Exact match | `name:jaco` | node named exactly "jaco" |
| Wildcard | `name:j*` | names starting with j |
| All | `name:*` | all items |
| Role | `role:devmachine` | nodes with that role |
| Recipe | `recipes:devmachine\:\:docker` | nodes running that recipe |
| Platform | `platform:ubuntu` | Ubuntu nodes |
| Platform version | `platform_version:24.10` | specific version |
| Attribute | `hostname:jaco` | by ohai attribute |
| Boolean AND | `role:devmachine AND platform:ubuntu` | |
| Boolean OR | `role:devmachine OR role:desktop` | |
| Boolean NOT | `role:devmachine NOT name:jaco` | |

## Nested Attribute Search

```bash
# Search by nested ohai attribute (use _ as separator)
knife search node 'memory_total:[4000000 TO *]'

# Tags
knife search node 'tags:production'
```

## Useful Recipes

```bash
# Find nodes NOT converged recently (missing attribute)
knife search node 'NOT ohai_time:*'

# Find nodes running a specific cookbook recipe
knife search node 'recipes:base\:\:users'

# Find nodes in a specific environment
knife search node 'chef_environment:production'

# Find nodes by IP range (Solr range query)
knife search node 'ipaddress:[192.168.10.0 TO 192.168.10.255]'
```

## Output Options

```bash
# Show only specific attributes
knife search node 'role:devmachine' -a name -a ipaddress

# JSON output for scripting
knife search node 'role:devmachine' -F json | jq '.rows[].name'

# Count matches only
knife search node 'role:devmachine' -i   # returns just names
```

## Searching Data Bags

```bash
# Search users data bag
knife search users 'groups:sudo'

# Search cronjobs data bag
knife search cronjobs 'name:cinc*'
```

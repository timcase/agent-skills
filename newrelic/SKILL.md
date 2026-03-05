---
name: newrelic
description: >
  Interact with the New Relic observability platform using the newrelic CLI. Use when the user
  asks to: query metrics or events with NRQL, search for entities (applications, hosts, services),
  view or create APM deployment markers, manage Synthetics monitors, send custom events, create
  change tracking events, execute NerdGraph GraphQL queries, manage workloads, list APM
  applications, or inspect New Relic account configuration. Triggers on: "query New Relic",
  "run NRQL", "search entities", "APM deployment marker", "synthetics monitor", "send custom event",
  "NerdGraph query", "New Relic workload", "check New Relic", "list APM apps".
---

# New Relic CLI

Configured profile: **Tim Case** (default) — account ID `7572905`.

```bash
newrelic <command> [subcommand] [flags]
```

Global flags available on all commands:
- `-a <id>` / `--accountId` — override account (default: 7572905)
- `--format JSON|Text|YAML` — output format (default: JSON)
- `--plain` — compact output
- `--profile <name>` — switch auth profile

## NRQL Queries

Query the New Relic Database directly:

```bash
newrelic nrql query -q 'SELECT count(*) FROM Transaction SINCE 1 hour ago'
newrelic nrql query -q 'SELECT average(duration) FROM Transaction FACET appName SINCE 30 minutes ago'
newrelic nrql query -q 'SELECT * FROM Log WHERE level = "error" SINCE 15 minutes ago LIMIT 50'
newrelic nrql query -q 'SELECT count(*) FROM Transaction TIMESERIES 5 minutes SINCE 1 hour ago'

# View query history
newrelic nrql history
```

## Entity Search

Find applications, hosts, services, and other monitored entities:

```bash
# Search by name
newrelic entity search --name "my-app"

# Search by type: APPLICATION, HOST, MONITOR, DASHBOARD, WORKLOAD, etc.
newrelic entity search --type APPLICATION
newrelic entity search --name "api" --type APPLICATION

# Search by domain: APM, BROWSER, INFRA, MOBILE, SYNTH, etc.
newrelic entity search --domain APM

# Filter by alert severity: CRITICAL, HIGH, MEDIUM, LOW, NOT_ALERTING
newrelic entity search --alert-severity CRITICAL

# Only reporting entities
newrelic entity search --name "web" --reporting true

# Return specific fields only
newrelic entity search --name "api" --fields-filter name,guid,alertSeverity
```

## APM Applications

```bash
# List / search APM apps
newrelic apm application search --name "my-app"
newrelic apm application get --applicationId <id>

# List deployment markers for an app
newrelic apm deployment list --applicationId <id>

# Create a deployment marker
newrelic apm deployment create --applicationId <id> \
  --revision "v1.2.3" \
  --user "tcase" \
  --description "Deploy new feature X"

# Delete a deployment marker
newrelic apm deployment delete --applicationId <id> --deploymentId <id>
```

## Change Tracking

Record a deployment or change event (broader than APM-only deployment markers):

```bash
newrelic changeTracking create \
  --entityGuid "<guid>" \
  --version "v1.2.3" \
  --user "tcase" \
  --description "Production deploy"
```

## Synthetics Monitors

```bash
newrelic synthetics monitor list
newrelic synthetics monitor search --name "homepage check"
newrelic synthetics monitor get --monitorId <id>

# Run a batch of monitors
newrelic synthetics run --monitorGuids <guid1>,<guid2>
```

## Custom Events

```bash
# Post a single custom event
newrelic events post --accountId 7572905 \
  --event '{"eventType":"Deploy","version":"1.2.3","env":"production"}'

# Post events from a JSON file
newrelic events postFile --accountId 7572905 --file events.json
```

## NerdGraph (GraphQL)

For anything the CLI subcommands don't cover, query the NerdGraph API directly:

```bash
newrelic nerdgraph query '{ actor { user { name email } } }'

newrelic nerdgraph query '
{
  actor {
    account(id: 7572905) {
      nrql(query: "SELECT count(*) FROM Transaction SINCE 1 hour ago") {
        results
      }
    }
  }
}'
```

See `references/nerdgraph.md` for common NerdGraph query patterns and entity GUID lookups.

## Workloads

```bash
newrelic workload list
newrelic workload get --guid <guid>
newrelic workload create --name "Production Services" --entityGuids <guid1>,<guid2>
newrelic workload update --guid <guid> --name "New Name"
newrelic workload delete --guid <guid>
```

## Entity Tags

```bash
# Add tags to an entity
newrelic entity tags create --guid <guid> --tag env:production,team:platform

# List tags on an entity
newrelic entity tags get --guid <guid>

# Delete a tag
newrelic entity tags delete --guid <guid> --tag env:production
```

## Output & Scripting Tips

```bash
# Pretty JSON (default)
newrelic entity search --name "api" --format JSON

# Pipe to jq for extraction
newrelic entity search --name "api" | jq '.[].guid'
newrelic apm application search --name "web" | jq '.[0].id'

# YAML output
newrelic entity search --name "api" --format YAML
```

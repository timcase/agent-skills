# NerdGraph Reference

NerdGraph is New Relic's GraphQL API. Access it via:

```bash
newrelic nerdgraph query '<graphql>'
```

Account ID: `7572905`

## Common Patterns

### Get current user
```graphql
{ actor { user { name email } } }
```

### Run NRQL via NerdGraph
```graphql
{
  actor {
    account(id: 7572905) {
      nrql(query: "SELECT count(*) FROM Transaction SINCE 1 hour ago") {
        results
      }
    }
  }
}
```

### Find entity GUID by name
```graphql
{
  actor {
    entitySearch(query: "name = 'my-app' AND type = 'APPLICATION'") {
      results {
        entities {
          name
          guid
          type
          domain
          alertSeverity
        }
      }
    }
  }
}
```

### Get entity details by GUID
```graphql
{
  actor {
    entity(guid: "<guid>") {
      name
      type
      domain
      alertSeverity
      reporting
      tags { key values }
    }
  }
}
```

### Get APM app error rate
```graphql
{
  actor {
    account(id: 7572905) {
      nrql(query: "SELECT rate(count(*), 1 minute) FROM TransactionError FACET appName SINCE 30 minutes ago") {
        results
      }
    }
  }
}
```

### List alert violations
```graphql
{
  actor {
    account(id: 7572905) {
      alerts {
        nrqlConditionsSearch {
          nrqlConditions {
            id
            name
            enabled
            nrql { query }
          }
        }
      }
    }
  }
}
```

### Get deployment markers for an entity
```graphql
{
  actor {
    entity(guid: "<guid>") {
      ... on ApmApplicationEntity {
        deploymentSearch {
          results {
            version
            timestamp
            user
            description
          }
        }
      }
    }
  }
}
```

## Useful Entity Types & Domains

| Domain | Type | Description |
|--------|------|-------------|
| APM | APPLICATION | APM-monitored apps |
| INFRA | HOST | Infrastructure hosts |
| SYNTH | MONITOR | Synthetics monitors |
| BROWSER | APPLICATION | Browser monitoring |
| MOBILE | APPLICATION | Mobile apps |
| EXT | SERVICE | External services |

## Multiline Queries in Shell

For complex queries, use a heredoc or single-quoted string:

```bash
newrelic nerdgraph query '
{
  actor {
    entitySearch(query: "domain = '\''APM'\'' AND alertSeverity = '\''CRITICAL'\''") {
      results {
        entities { name guid alertSeverity }
      }
    }
  }
}'
```

Or store in a variable:
```bash
QUERY='{ actor { user { name } } }'
newrelic nerdgraph query "$QUERY"
```

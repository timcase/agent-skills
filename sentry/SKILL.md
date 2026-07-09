---
name: sentry
description: "Manage and query Sentry error reports using sentry-cli. Use for: listing/viewing issues, pulling latest errors for a project, resolving or muting issues. Triggers on 'Sentry errors', 'pull Sentry issues', 'what is broken', or 'resolve issue'."
---

# Sentry

Sentry error monitoring via `sentry-cli`. The tool is authenticated and ready to use.

## Configuration

- **Org slug**: `wingtask`
- **Project naming**: The Sentry project slug may not match the working directory name. Check CLAUDE.md for a project-specific slug, or run `sentry-cli projects list --org wingtask` to find it.

## Common Commands

### List issues for current project

```bash
# Infer project from cwd basename
sentry-cli issues list --org wingtask --project <project>

# Unresolved only (most common)
sentry-cli issues list --org wingtask --project <project> --status unresolved

# With query filter
sentry-cli issues list --org wingtask --project <project> --query "is:unresolved"

# Limit rows
sentry-cli issues list --org wingtask --project <project> --max-rows 20
```

### Resolve / mute / unresolve issues

```bash
# Resolve a specific issue by ID
sentry-cli issues resolve --org wingtask --project <project> --id <issue-id>

# Resolve all unresolved
sentry-cli issues resolve --org wingtask --project <project> --status unresolved

# Mute an issue
sentry-cli issues mute --org wingtask --project <project> --id <issue-id>
```

### List all projects

```bash
sentry-cli projects list --org wingtask
```

## Workflow

1. Determine the project slug: check CLAUDE.md first, then fall back to `sentry-cli projects list --org wingtask`
2. Run the appropriate command
3. Present results clearly — summarize patterns if there are many issues

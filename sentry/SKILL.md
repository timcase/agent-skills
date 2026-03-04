---
name: sentry
description: Manage and query Sentry error reports using sentry-cli. Use when the user asks to view, list, or check errors/issues in Sentry, pull down latest issues for a project, resolve or mute issues, or check what's broken in an app. Triggers on requests like "pull down the latest issues", "show me the Sentry errors", "what errors are in Sentry", "resolve this Sentry issue", or "check the errors for this project".
---

# Sentry

Sentry error monitoring via `sentry-cli`. The tool is authenticated and ready to use.

## Configuration

- **Org slug**: `wingtask`
- **Project naming**: The Sentry project slug matches the current working directory name (e.g., working in `bravo/` → project is `bravo`)

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

1. Determine the project: use `basename $PWD` or ask the user if ambiguous
2. Run the appropriate command
3. Present results clearly — summarize patterns if there are many issues

# gh actions — Workflows, Runs, Caches, Secrets, Variables

## Workflow Runs (gh run)

```bash
gh run list
gh run list --workflow "ci.yml" --branch main --limit 20
gh run list --json databaseId,status,conclusion,headBranch

gh run view 123456789
gh run view 123456789 --log
gh run view 123456789 --job 987654321
gh run view 123456789 --web

gh run watch 123456789
gh run watch 123456789 --interval 5

gh run rerun 123456789
gh run rerun 123456789 --job 987654321 --failed

gh run cancel 123456789
gh run delete 123456789

gh run download 123456789
gh run download 123456789 --name build --dir ./artifacts
```

## Workflows (gh workflow)

```bash
gh workflow list
gh workflow view ci.yml
gh workflow view ci.yml --yaml --web

gh workflow enable ci.yml
gh workflow disable ci.yml

gh workflow run ci.yml
gh workflow run ci.yml --ref develop
gh workflow run ci.yml \
  --raw-field version="1.0.0" \
  --raw-field environment="production"
```

## Action Caches (gh cache)

```bash
gh cache list
gh cache list --branch main --limit 50

gh cache delete 123456789
gh cache delete --all
```

## Secrets (gh secret)

```bash
gh secret list

gh secret set MY_SECRET                         # prompts for value
echo "$MY_SECRET" | gh secret set MY_SECRET     # from stdin/env
gh secret set MY_SECRET --env production
gh secret set MY_SECRET --org orgname

gh secret delete MY_SECRET
gh secret delete MY_SECRET --env production
```

## Variables (gh variable)

```bash
gh variable list

gh variable set MY_VAR "some-value"
gh variable set MY_VAR "value" --env production
gh variable set MY_VAR "value" --org orgname

gh variable get MY_VAR

gh variable delete MY_VAR
gh variable delete MY_VAR --env production
```

## CI/CD Workflow Pattern

```bash
# Trigger workflow and wait for it
gh workflow run ci.yml --ref main
RUN_ID=$(gh run list --workflow ci.yml --limit 1 --json databaseId --jq '.[0].databaseId')
gh run watch "$RUN_ID"
gh run download "$RUN_ID" --dir ./artifacts
```

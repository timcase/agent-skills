# Common Workflows and Best Practices

## Create PR from Issue

```bash
gh issue develop 123 --branch feature/issue-123
# make changes, commit, push
gh pr create --title "Fix #123" --body "Closes #123"
```

## Bulk Operations

```bash
# Close multiple stale issues
gh issue list --search "label:stale" --json number --jq '.[].number' | \
  xargs -I {} gh issue close {} --comment "Closing as stale"

# Add label to multiple PRs
gh pr list --search "review:required" --json number --jq '.[].number' | \
  xargs -I {} gh pr edit {} --add-label needs-review
```

## Repository Setup Workflow

```bash
gh repo create my-project --public \
  --description "My awesome project" \
  --clone --gitignore python --license mit

cd my-project
git checkout -b develop && git push -u origin develop

gh label create bug --color "d73a4a" --description "Bug report"
gh label create enhancement --color "a2eeef" --description "Feature request"
```

## Fork Sync Workflow

```bash
gh repo fork original/repo --clone
cd repo
git remote add upstream https://github.com/original/repo.git
gh repo sync
```

## Shell Integration

```bash
# Add to ~/.bashrc or ~/.zshrc
eval "$(gh completion -s zsh)"   # or bash/fish

alias gs='gh status'
alias gpr='gh pr view --web'
alias gco='gh pr checkout'
```

## Best Practices

1. **Automation auth** — use env var: `export GH_TOKEN=$(gh auth token)`
2. **Default repo** — avoid repetition: `gh repo set-default owner/repo`
3. **JSON + jq** for complex filtering:
   ```bash
   gh pr list --json number,title --jq '.[] | select(.title | contains("fix"))'
   ```
4. **Pagination** for large sets: `gh issue list --state all --paginate`
5. **Caching** for frequent reads: `gh api /user --cache force`

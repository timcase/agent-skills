# gh issue / gh pr — Issues and Pull Requests

## Issues

### Create / List / View

```bash
gh issue create
gh issue create --title "Bug: Login not working" --body "Steps to reproduce..."
gh issue create --body-file issue.md --labels bug,high-priority --assignee user1
gh issue create --repo owner/repo --web

gh issue list
gh issue list --state all --limit 50 --assignee @me
gh issue list --labels bug --milestone "v1.0"
gh issue list --search "is:open label:bug" --sort created --order desc
gh issue list --json number,title,state,author
gh issue list --json number,title,labels --jq '.[] | [.number, .title, .labels[].name] | @tsv'

gh issue view 123
gh issue view 123 --comments --web
gh issue view 123 --json title,body,state,labels,comments
gh issue status
```

### Edit / Close / Comment

```bash
gh issue edit 123 --title "New title" --body "New description"
gh issue edit 123 --add-label bug --remove-label stale
gh issue edit 123 --add-assignee user1 --remove-assignee user2
gh issue edit 123 --milestone "v1.0"

gh issue close 123 --comment "Fixed in PR #456"
gh issue reopen 123

gh issue comment 123 --body "This looks good!"
gh issue comment 123 --edit 456789 --body "Updated comment"
gh issue comment 123 --delete 456789
```

### Other Issue Actions

```bash
gh issue pin 123 / gh issue unpin 123
gh issue lock 123 --reason off-topic / gh issue unlock 123
gh issue transfer 123 --repo owner/new-repo
gh issue delete 123 --yes
gh issue develop 123 --branch fix/issue-123 --base main   # create draft PR
```

---

## Pull Requests

### Create / List / View

```bash
gh pr create
gh pr create --title "Feature: Add new functionality" --body "This PR adds..."
gh pr create --base main --head feature-branch --draft
gh pr create --assignee user1 --reviewer user1,user2 --labels enhancement
gh pr create --issue 123 --repo owner/repo --web

gh pr list
gh pr list --state all --limit 50 --author @me
gh pr list --head feature-branch --base main --labels bug
gh pr list --search "is:open label:review-required" --sort created --order desc
gh pr list --json number,title,state,author,headRefName
gh pr list --json number,title,statusCheckRollup --jq '.[] | [.number, .title, .statusCheckRollup[]?.status]'

gh pr view 123
gh pr view 123 --comments --web
gh pr view 123 --json title,body,state,author,commits,files
gh pr status
```

### Checkout / Diff

```bash
gh pr checkout 123
gh pr checkout 123 --branch name-123 --force

gh pr diff 123
gh pr diff 123 --color always --name-only
gh pr diff 123 > pr-123.patch
```

### Merge / Close / Reopen / Revert

```bash
gh pr merge 123 --merge
gh pr merge 123 --squash --delete-branch
gh pr merge 123 --rebase --subject "Merge PR #123" --body "Merging feature"
gh pr merge 123 --admin                  # force merge / skip checks

gh pr close 123 --comment "Closing due to..."
gh pr reopen 123
gh pr revert 123 --branch revert-pr-123
```

### Edit / Review / Checks

```bash
gh pr edit 123 --title "New title" --body "New description"
gh pr edit 123 --add-label bug --remove-label stale
gh pr edit 123 --add-reviewer user1 --remove-reviewer user2
gh pr edit 123 --ready                   # convert draft to ready

gh pr review 123 --approve --body "LGTM!"
gh pr review 123 --request-changes --body "Please fix these issues"
gh pr review 123 --comment --body "Some thoughts..."
gh pr review 123 --dismiss

gh pr checks 123
gh pr checks 123 --watch --interval 5
```

### Comment / Update / Lock

```bash
gh pr comment 123 --body "Looks good!"
gh pr comment 123 --edit 456789 --body "Updated"
gh pr comment 123 --delete 456789

gh pr update-branch 123
gh pr update-branch 123 --force --merge

gh pr lock 123 --reason off-topic / gh pr unlock 123
gh pr ready 123
```

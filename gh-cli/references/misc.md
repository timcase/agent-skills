# gh — Miscellaneous Commands

## Gists (gh gist)

```bash
gh gist list --limit 20
gh gist view abc123 --files
gh gist create script.py --desc "My script" --public
gh gist create file1.py file2.py
echo "print('hello')" | gh gist create
gh gist edit abc123
gh gist delete abc123
gh gist rename abc123 --filename old.py new.py
gh gist clone abc123 my-directory
```

## Codespaces (gh codespace)

```bash
gh codespace list
gh codespace create --repo owner/repo --branch develop --machine premiumLinux
gh codespace view
gh codespace ssh
gh codespace ssh --command "cd /workspaces && ls"
gh codespace code --path /workspaces/repo   # open in browser/VS Code
gh codespace stop / gh codespace delete
gh codespace logs
gh codespace ports
gh codespace rebuild
gh codespace edit --machine standardLinux
gh codespace cp file.txt :/workspaces/file.txt
gh codespace cp :/workspaces/file.txt ./file.txt
```

## Organizations (gh org)

```bash
gh org list
gh org list --user username --json login,name,description
gh org view orgname
gh org view orgname --json members --jq '.members[] | .login'
```

## Search (gh search)

```bash
gh search code "TODO" --repo owner/repo --extension py
gh search commits "fix bug"
gh search issues "label:bug state:open"
gh search prs "is:open review:required"
gh search repos "stars:>1000 language:python" --limit 50 --order desc --sort stars
gh search repos "stars:>100" --json name,description,stargazers
gh search prs "is:open" --web
```

## Labels (gh label)

```bash
gh label list
gh label create bug --color "d73a4a" --description "Something isn't working"
gh label edit bug --name "bug-report" --color "ff0000"
gh label delete bug
gh label clone owner/repo
gh label clone owner/repo --repo target/repo
```

## SSH Keys (gh ssh-key)

```bash
gh ssh-key list
gh ssh-key add ~/.ssh/id_rsa.pub --title "My laptop"
gh ssh-key add ~/.ssh/id_ed25519.pub --type "authentication"
gh ssh-key delete 12345
gh ssh-key delete --title "My laptop"
```

## GPG Keys (gh gpg-key)

```bash
gh gpg-key list
gh gpg-key add ~/.gpg/key.pub
gh gpg-key delete ABCD1234
```

## Status (gh status)

```bash
gh status
gh status --repo owner/repo --json
```

## Extensions (gh extension)

```bash
gh extension list
gh extension search github
gh extension install owner/extension-repo
gh extension install owner/extension-repo --branch develop
gh extension upgrade extension-name
gh extension remove extension-name
gh extension create my-extension
gh extension browse
gh extension exec my-extension --arg value
```

## Aliases (gh alias)

```bash
gh alias list
gh alias set prview 'pr view --web'
gh alias set co 'pr checkout' --shell
gh alias delete prview
gh alias import ./aliases.sh
```

## API Requests (gh api)

```bash
gh api /user
gh api /user --jq '.login'
gh api /repos/owner/repo --jq '.stargazers_count'

gh api --method POST /repos/owner/repo/issues \
  --field title="Issue title" --field body="Issue body"

gh api /user --header "Accept: application/vnd.github.v3+json"
gh api /user/repos --paginate
gh api /user --raw --include --silent
gh api --input request.json
gh api /user --hostname enterprise.internal

# GraphQL
gh api graphql -f query='{ viewer { login repositories(first: 5) { nodes { name } } } }'
```

## Rulesets (gh ruleset)

```bash
gh ruleset list
gh ruleset view 123
gh ruleset check --branch feature
gh ruleset check --repo owner/repo --branch main
```

## Attestations (gh attestation)

```bash
gh attestation download owner/repo --artifact-id 123456
gh attestation verify owner/repo
gh attestation trusted-root
```

## Completion

```bash
gh completion -s bash > ~/.gh-complete.bash
gh completion -s zsh > ~/.gh-complete.zsh
gh completion -s fish > ~/.gh-complete.fish
```

## Help

```bash
gh --help
gh pr --help
gh issue create --help
gh help formatting
gh help environment
gh help exit-codes
```

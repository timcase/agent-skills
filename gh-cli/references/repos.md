# gh repo — Repository Commands

## Create

```bash
gh repo create my-repo
gh repo create my-repo --description "My awesome project" --public
gh repo create my-repo --private --license mit --gitignore python
gh repo create org/my-repo                    # in organization
gh repo create my-repo --template             # as template repo
gh repo create my-repo --disable-issues --disable-wiki
gh repo create my-repo --source=.             # from existing local dir
```

## Clone / Fork / Sync

```bash
gh repo clone owner/repo
gh repo clone owner/repo my-directory
gh repo clone owner/repo --branch develop

gh repo fork owner/repo
gh repo fork owner/repo --org org-name --clone --remote-name upstream

gh repo sync                    # sync fork with upstream
gh repo sync --branch feature
gh repo sync --force
```

## List / View

```bash
gh repo list
gh repo list owner --limit 50 --public --source
gh repo list --json name,visibility,owner --jq '.[].name'

gh repo view
gh repo view owner/repo
gh repo view --json name,description,defaultBranchRef
gh repo view --web
```

## Edit / Rename / Archive

```bash
gh repo edit --description "New description"
gh repo edit --homepage https://example.com
gh repo edit --visibility private
gh repo edit --enable-issues --disable-wiki --enable-projects
gh repo edit --default-branch main
gh repo rename new-name
gh repo archive
gh repo unarchive
```

## Delete

```bash
gh repo delete owner/repo --yes
```

## Set Default

```bash
gh repo set-default
gh repo set-default owner/repo
gh repo set-default --unset
```

## Autolinks

```bash
gh repo autolink list
gh repo autolink add --key-prefix JIRA- --url-template https://jira.example.com/browse/<num>
gh repo autolink delete 12345
```

## Deploy Keys

```bash
gh repo deploy-key list
gh repo deploy-key add ~/.ssh/id_rsa.pub --title "Production server" --read-only
gh repo deploy-key delete 12345
```

## Gitignore / License

```bash
gh repo gitignore
gh repo license mit
gh repo license mit --fullname "John Doe"
```

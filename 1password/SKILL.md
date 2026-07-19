---
name: 1password
description: "Manage 1Password vaults/secrets with the op CLI. Use for: reading secrets, secret references (op://), listing/creating/editing items, injecting secrets into configs, running commands with secret env vars, TOTP, documents. Triggers on '1Password'."
---

# 1Password CLI

CLI binary: `op` (at `/bin/op`). Requires the 1Password 8 desktop app with CLI integration enabled, or a service account token (`OP_SERVICE_ACCOUNT_TOKEN`) for headless/CI use.

**Output:** Add `--format=json` to any list/get command for scripting. `op` masks/conceals secret fields unless you use `op read`, `--reveal`, or `--fields`.

## Authentication

```bash
op signin                       # Sign in via desktop app integration (idempotent)
op signin --account my.1password.com
eval $(op signin --raw)         # Only when app integration is off; sets OP_SESSION token
op whoami                       # Show current account
op account list                 # List configured accounts
op signout
```

Non-interactive (CI, scripts): export `OP_SERVICE_ACCOUNT_TOKEN`. Scope service accounts to specific vaults for least privilege. Select account per-command with `--account` or `OP_ACCOUNT`.

## Reading Secrets (preferred for automation)

`op read` takes a **secret reference** `op://<vault>/<item>/[section/]<field>` and prints the raw value:

```bash
op read op://Prod/db/password
op read op://Prod/db/password -n              # No trailing newline
op read "op://Prod/ssh key/private key?ssh-format=openssh"
op read "op://Prod/db/one-time password?attribute=otp"   # TOTP value
op read -o ./key.pem op://Prod/server/ssh/key.pem        # Write to file (mode 0600)

# Inline in another command
docker login -u "$(op read op://prod/docker/username)" -p "$(op read op://prod/docker/password)"
```

## Items

### Listing and getting

```bash
op item list                                      # All items (excludes Archive)
op item list --vault Prod
op item list --categories Login --vault Staging
op item list --tags documentation --format=json
op item list --favorite

op item get "GitHub"                              # By name, ID, or share link
op item get "GitHub" --vault Prod                 # Disambiguate by vault
op item get "GitHub" --fields label=username,label=password
op item get "GitHub" --fields type=concealed      # Filter by field type
op item get "GitHub" --format=json
op item get Google --otp                          # One-time password
op item get "GitHub" --vault Prod --share-link    # Get shareable link
```

**To read a single field value, prefer `op read op://vault/item/field`** over `item get --fields` — it returns the raw value directly.

### Creating

Use assignment statements `[<section>.]<field>[[<fieldType>]]=<value>`. List categories with `op item template list`.

```bash
op item create --category login --title "GitHub" --vault Personal \
  --url https://github.com \
  username=alice password=secret

# Generate a password (default 32 chars); recipe = letters,digits,symbols,LENGTH
op item create --category login --title "GitHub" --generate-password
op item create --category login --title "GitHub" --generate-password='letters,digits,symbols,24'

# Custom fields and sections
op item create --category login --title "DB" \
  "Database Credentials.host[text]=33.166.240.221" \
  "Database Credentials.port[text]=5432"

op item create --category "Secure Note" --title "Notes" notesPlain="my note"
op item create --category login --title "Deploy" --ssh-generate-key   # Generate SSH key

op item create --dry-run ...                      # Preview without saving
```

**Sensitive values on the command line are visible in shell history and to other processes.** For secrets, pipe a JSON template instead of using assignment args:

```bash
op item template get Login > login.json          # Edit, then:
op item create --template login.json
```

### Editing, moving, sharing, deleting

```bash
op item edit "GitHub" password=newsecret              # Update a field
op item edit "GitHub" --generate-password='letters,digits,symbols,32'
op item edit "GitHub" "section.oldfield[delete]"      # Delete a custom field
op item edit "GitHub" --tags work,ops --title "GitHub Work"
op item edit "GitHub" --template updated.json         # Edit via JSON template

op item move "GitHub" --destination-vault Work
op item share "GitHub" --emails a@x.com --expires-in 2d
op item share "GitHub" --view-once

op item delete "Old Login"                            # 30-day Recently Deleted
op item delete "Old Login" --archive                  # Move to Archive instead
```

## Vaults

```bash
op vault list
op vault get Prod
op vault create Work --description "Work credentials"
op vault edit Work --name "Work Secrets"
op vault delete Work
op vault user list Prod                                # Who has access
```

## Secret Injection into Config Files

Template config files with `{{ op://vault/item/field }}`:

```bash
echo "db_password: {{ op://Prod/db/password }}" | op inject
op inject -i config.yml.tpl -o config.yml             # Output file is mode 0600
op inject -i config.yml.tpl -o config.yml -f          # Skip confirmation
```

**Delete the resolved output file when done** — it contains plaintext secrets.

## Run Commands with Secrets as Env Vars

`op run` loads secret references (from the environment or an `.env` file) as real env vars only for the child process. Secrets in stdout/stderr are masked by default.

```bash
export DB_PASSWORD="op://Prod/db/password"
op run -- ./my-script.sh
op run --env-file .env.tpl -- node server.js
op run --no-masking -- printenv DB_PASSWORD
```

`.env.tpl` lines look like `DATABASE_URL=op://Prod/db/url`. Env-file values take precedence over shell env vars.

## Documents

```bash
op document list
op document get "Report" --output ./report.pdf
op document create ./file.pdf --title "Report" --vault Personal
op document edit "Report" ./newfile.pdf
op document delete "Report"
```

## TOTP / One-Time Passwords

```bash
op item get Google --otp
op read "op://Prod/Google/one-time password?attribute=otp"
```

## Tips

- Run `op whoami` first if commands fail unexpectedly — the session may have expired; re-run `op signin`.
- Prefer item **names/titles** interactively; use item **IDs** + `--vault` in scripts for reliability and to avoid ambiguity/rate limits.
- Pipe between commands: `op item list --tags web --format=json | op item get - --fields label=username,label=password`.
- For a single value use `op read op://...`; for whole-item inspection use `op item get --format=json`.
- Never echo secrets into logs or commit resolved `op inject` output; keep secrets as references (`op://...`) in version control.

---
name: proton-pass
description: "Manage Proton Pass password manager vaults, items, and secrets using the pass-cli command-line tool. Use when the user asks to: list vaults or items, view/retrieve passwords or secrets, create or update login/note/credit card/SSH key items, delete or move items, generate passwords or TOTP codes, inject secrets into config files, run commands with secrets as environment variables, manage vault members/sharing, or use the Proton Pass SSH agent. Triggers on requests like 'show my Proton Pass vaults', 'get the password for X', 'create a login in Pass', 'inject secrets', 'run with Pass env vars', 'generate a TOTP', or 'add an SSH key to Pass'."
---

# Proton Pass CLI

CLI binary: `pass-cli`

## Authentication

```bash
pass-cli login          # Web-based login (default)
pass-cli test           # Verify authenticated connection
pass-cli info           # Show current session info
pass-cli logout
```

## Vaults

```bash
pass-cli vault list
pass-cli vault list --output json
pass-cli vault create --name "Work" --description "Work credentials"
pass-cli vault update --vault-name "Work" --name "Work Secrets"
pass-cli vault delete --vault-name "Work"
pass-cli vault share --vault-name "Work" --email user@example.com
```

## Items

### Listing and viewing

```bash
pass-cli item list                                    # All items across vaults
pass-cli item list "VaultName"                        # Items in specific vault
pass-cli item list --filter-type login                # Types: note, login, alias, credit-card, identity, ssh-key, wifi, custom
pass-cli item list --output json

pass-cli item view --item-title "GitHub"              # By title
pass-cli item view --vault-name "Work" --item-title "GitHub"
pass-cli item view --item-title "GitHub" --field password   # Specific field only
pass-cli item view --output json --item-title "GitHub"
pass-cli item view pass://SHARE_ID/ITEM_ID            # By URI
pass-cli item view pass://SHARE_ID/ITEM_ID/password   # Field via URI
```

**Item URI format:** `pass://SHARE_ID/ITEM_ID[/FIELD]` — get share IDs from `vault list --output json`

### Creating items

```bash
# Login item
pass-cli item create login --vault-name "Personal" \
  --title "GitHub" --username "alice" --email "alice@example.com" \
  --password "secret" --url "https://github.com"

# Generate password on creation
pass-cli item create login --vault-name "Personal" --title "GitHub" \
  --generate-password                        # Default settings
pass-cli item create login --title "GitHub" --generate-password="20,true,true"  # length,uppercase,symbols

# Create from JSON template
pass-cli item create login --get-template    # Print template JSON
pass-cli item create login --from-template item.json
pass-cli item create login --from-template - < item.json

# Other item types
pass-cli item create note --vault-name "Personal" --title "Notes"
pass-cli item create ssh-key --vault-name "Work" --title "Deploy Key"
pass-cli item create credit-card --vault-name "Finance" --title "Visa"
pass-cli item create identity --vault-name "Personal" --title "Passport"
pass-cli item create wifi --vault-name "Home" --title "HomeNetwork"
pass-cli item create custom --vault-name "Work" --title "API Keys"
```

### Updating and managing

```bash
pass-cli item update --item-title "GitHub" --field "username=newuser"
pass-cli item update --item-title "GitHub" --field "password=newpass" --field "username=alice"

pass-cli item move --item-title "GitHub" --vault-name "Work"
pass-cli item trash --item-title "OldItem"
pass-cli item untrash --item-title "OldItem"
pass-cli item delete --item-title "OldItem"
```

## Secret Injection

Inject secrets into templated config files using `{{ pass://SHARE_ID/ITEM_ID/FIELD }}` syntax:

```bash
# Template file (config.template):
# DATABASE_URL=postgres://{{ pass://abc123/xyz789/username }}:{{ pass://abc123/xyz789/password }}@host/db

pass-cli inject -i config.template              # Output to stdout
pass-cli inject -i config.template -o .env      # Write to file (mode 0600)
pass-cli inject -i config.template -o .env -f   # Skip confirmation prompt
```

## Run Commands with Secrets as Env Vars

```bash
# Env vars sourced from Pass item fields
pass-cli run -- ./my-script.sh
pass-cli run --env-file .env.template -- node server.js
pass-cli run --no-masking -- printenv   # Disable secret masking in output
```

## Password Generation

```bash
pass-cli password generate random
pass-cli password generate random --length 24 --no-symbols
pass-cli password generate passphrase
pass-cli password generate passphrase --word-count 5

pass-cli password score "mypassword"    # Score a password's strength
```

## TOTP

```bash
pass-cli totp generate --secret "BASE32SECRET"
pass-cli totp generate --uri "otpauth://totp/..."
pass-cli item totp --item-title "GitHub"    # Generate TOTP for a stored item
```

## SSH Agent

```bash
pass-cli ssh-agent start    # Start Proton Pass SSH agent
pass-cli ssh-agent load     # Load SSH keys from Pass into system SSH agent
pass-cli ssh-agent debug    # Debug SSH key items
```

## Tips

- Use `--output json` on list/view commands for scripting
- Prefer `--item-title` for interactive use; use `--item-id` + `--share-id` in scripts for reliability
- `pass-cli item view --field password --item-title "X"` returns just the password value — useful for piping
- Run `pass-cli test` first if commands fail unexpectedly (session may have expired)

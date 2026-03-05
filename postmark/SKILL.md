---
name: postmark
description: "Send emails and manage email templates and servers using the Postmark CLI. Use when the user asks to: send a transactional email, send an email using a Postmark template, list Postmark servers, pull/push/preview email templates, or manage template workflows. Triggers on requests like 'send an email via Postmark', 'use a Postmark template', 'list my Postmark servers', 'pull down templates', 'push templates to Postmark', or 'preview email templates'."
---

# Postmark CLI

CLI binary: `postmark`

## Servers

```bash
postmark servers list
postmark servers list --json
postmark servers list --name "production" --show-tokens
postmark servers list --count 10 --offset 0
```

## Send Email

### Raw email

```bash
postmark email raw \
  --from sender@example.com \
  --to recipient@example.com \
  --subject "Hello" \
  --html "<p>Hello world</p>" \
  --text "Hello world"
```

`--from` must be a verified domain address or confirmed Sender Signature.

### Templated email

```bash
# By template alias
postmark email template \
  --alias welcome-email \
  --from sender@example.com \
  --to recipient@example.com \
  --model '{"name": "Alice", "confirm_url": "https://example.com/confirm"}'

# By template ID
postmark email template \
  --id 12345 \
  --from sender@example.com \
  --to recipient@example.com \
  --model '{"name": "Alice"}'
```

`--model` is a JSON string of variables to inject into the template.

## Templates

```bash
# Pull templates from server to local directory
postmark templates pull ./templates
postmark templates pull ./templates --overwrite   # Overwrite existing files

# Push local templates to server
postmark templates push ./templates
postmark templates push ./templates --force        # Skip confirmation prompt
postmark templates push ./templates --all          # Push all, even unchanged

# Preview templates in browser (starts local server at http://localhost:3005)
postmark templates preview ./templates
postmark templates preview ./templates --port 3005
```

### Template workflow

`templates pull` → edit locally → `templates preview` → `templates push`

After pulling, templates are organized as directories containing `content.html`, `content.txt`, and `meta.json`. Edit these files locally, preview, then push to deploy.

## Tips

- Use `--show-tokens` with `servers list` to retrieve server API tokens
- `--json` on `servers list` returns machine-readable output
- Specify `--alias` (preferred) or `--id` when sending templated emails

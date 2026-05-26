---
name: cloudflare-dns
description: "Manage Cloudflare DNS records via API — add, update, list, or delete A, AAAA, CNAME, MX, and TXT records. Use when adding or updating DNS records, pointing a subdomain, setting up MX or TXT records, or configuring a Cloudflare zone."
---

# Cloudflare DNS

Manage DNS records for Cloudflare-managed zones using the REST API.
`CLOUDFLARE_API_TOKEN` is available in the environment.

Read [references/api_reference.md](references/api_reference.md) before
executing any API calls — it contains all endpoint shapes and curl examples.

## Workflow

Every operation follows this two-step pattern:

1. **Find the zone ID** for the domain
2. **Operate on DNS records** within that zone

### Step 1 — Resolve zone ID

Look up the zone ID from the domain name (e.g. `example.com`). The zone
is always the registrable domain, not a subdomain.

```bash
curl -s "https://api.cloudflare.com/client/v4/zones?name=example.com" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" | jq -r '.result[0].id'
```

If `result` is empty, the domain is not in this Cloudflare account.

### Step 2 — Add or update a record

**Adding:** POST to `/zones/$ZONE_ID/dns_records` with the record body.

**Updating:** First list records to find the `id` of the existing record,
then PATCH only the changed fields.

See `references/api_reference.md` for per-type JSON bodies (A, CNAME, MX,
TXT, AAAA) and the list/update/delete curl commands.

## Key facts

- `"ttl": 1` = Auto (Cloudflare-managed TTL)
- `"proxied": true` routes traffic through Cloudflare (orange cloud);
  only valid for A, AAAA, CNAME
- MX and TXT records cannot be proxied
- Always verify `"success": true` in the response before reporting done
- Duplicate records return error code 81057

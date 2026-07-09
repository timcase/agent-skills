---
name: cloudflare
description: "Manage Cloudflare DNS records and R2 object storage via API. Use for adding/updating/deleting DNS records (A, AAAA, CNAME, MX, TXT), or managing R2 buckets, lifecycle, CORS, custom domains, notifications, lock rules, metrics, or Sippy migration."
---

# Cloudflare

Manage Cloudflare-hosted resources using the REST API.
`CLOUDFLARE_API_TOKEN` is available in the environment and works for both
DNS and R2 (must be scoped with the relevant permissions).

This skill has two domains — read only the reference file for the one
you need:

- **DNS records** → [references/dns.md](references/dns.md)
- **R2 storage** → [references/r2.md](references/r2.md)

## DNS

Every DNS operation follows: resolve the zone ID for the domain, then
operate on DNS records within that zone. See `references/dns.md` for the
zone lookup and per-record-type (A, AAAA, CNAME, MX, TXT) request bodies.

## R2

Every R2 management operation follows: resolve the account ID, then operate
on buckets/lifecycle/CORS/domains/notifications/lock/metrics/sippy within
that account. See `references/r2.md` for the account lookup and endpoint
details.

For uploading, downloading, or listing actual object contents, don't use
this skill's API calls — use the **s3cmd skill** against R2's S3-compatible
endpoint instead (see `s3cmd/references/providers.md` for the R2 config
profile). This skill only covers R2's management plane.

## Key facts

- `"ttl": 1` = Auto (Cloudflare-managed TTL) for DNS records
- `"proxied": true` routes DNS traffic through Cloudflare (orange cloud);
  only valid for A, AAAA, CNAME — MX and TXT cannot be proxied
- Always verify `"success": true` in the response before reporting done
- Duplicate DNS records return error code 81057
- R2 object PUT/GET via the Cloudflare v4 API caps at 300MB with no
  multipart — that's the signal to use s3cmd instead

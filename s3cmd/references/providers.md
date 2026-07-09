# Provider Configuration

## Multiple Config Profiles

Use separate config files per provider and pass with `-c`:

```bash
s3cmd -c ~/.s3cfg-aws ls
s3cmd -c ~/.s3cfg-do  ls
```

---

## AWS S3

Configure interactively:
```bash
s3cmd --configure -c ~/.s3cfg-aws
```

Key values:
- Access Key / Secret Key: from IAM console
- Default Region: e.g. `us-east-1`
- S3 Endpoint: `s3.amazonaws.com` (default, leave blank)
- DNS-style bucket+hostname: `%(bucket)s.s3.amazonaws.com`
- Encryption password: optional

---

## DigitalOcean Spaces

Configure interactively:
```bash
s3cmd --configure -c ~/.s3cfg-do
```

Key values:
- Access Key / Secret Key: from DO console → API → Spaces Keys
- S3 Endpoint: `{region}.digitaloceanspaces.com`
- DNS-style bucket+hostname: `%(bucket)s.{region}.digitaloceanspaces.com`
- Use HTTPS: `True`
- Encryption password: leave blank

### Regions

| Region | Endpoint |
|--------|----------|
| New York | `nyc3.digitaloceanspaces.com` |
| San Francisco | `sfo3.digitaloceanspaces.com` |
| Amsterdam | `ams3.digitaloceanspaces.com` |
| Singapore | `sgp1.digitaloceanspaces.com` |
| Frankfurt | `fra1.digitaloceanspaces.com` |
| London | `lon1.digitaloceanspaces.com` |
| Toronto | `tor1.digitaloceanspaces.com` |
| Sydney | `syd1.digitaloceanspaces.com` |
| Bangalore | `blr1.digitaloceanspaces.com` |

> If your Space is in `nyc3`, set endpoint to `nyc3.digitaloceanspaces.com`
> and bucket hostname to `%(bucket)s.nyc3.digitaloceanspaces.com`.

---

## Cloudflare R2

Configure interactively:
```bash
s3cmd --configure -c ~/.s3cfg-r2
```

Key values:
- Access Key / Secret Key: from Cloudflare dashboard → R2 → **Manage API
  Tokens** (this is a separate credential from `CLOUDFLARE_API_TOKEN` used
  by the `cloudflare` skill — that token does not work here)
- S3 Endpoint: `{account_id}.r2.cloudflarestorage.com`
- DNS-style bucket+hostname: leave blank / disabled — R2 does not support
  virtual-hosted-style addressing by default; use path-style
- Default Region: `auto`
- Encryption password: leave blank

> Find `{account_id}` via `GET /accounts` in the `cloudflare` skill's
> `references/r2.md`, or from the Cloudflare dashboard URL.

For bucket management (create/delete/lifecycle/CORS/custom domains), use
the `cloudflare` skill instead — s3cmd here is only for object I/O.

---

## Verifying a Config

```bash
s3cmd -c ~/.s3cfg-do  ls         # should list your Spaces
s3cmd -c ~/.s3cfg-aws ls         # should list your S3 buckets
s3cmd -c ~/.s3cfg-r2  ls         # should list your R2 buckets
```

---
name: s3cmd
description: >
  Manage S3-compatible object storage using the s3cmd CLI. Use when the user
  asks to: list buckets or bucket contents, upload or download files, sync
  directories to/from S3, inspect or change ACLs/permissions, or list all
  objects in a bucket. Supports multiple providers including AWS S3 and
  DigitalOcean Spaces via named config profiles. Triggers on requests like
  "upload this to my Spaces bucket", "sync my folder to S3", "what's the ACL
  for bucket X", "list everything in bucket Y", or "download from S3".
---

# s3cmd

## Provider Selection

When the user has multiple providers, identify which one they mean, then use
the appropriate config file with `-c`:

```bash
s3cmd -c ~/.s3cfg-aws <command>     # AWS S3
s3cmd -c ~/.s3cfg-do  <command>     # DigitalOcean Spaces
```

If the user hasn't set up named configs yet, see
[references/providers.md](references/providers.md) for setup.

## Common Operations

**List buckets:**
```bash
s3cmd ls
```

**List bucket contents:**
```bash
s3cmd ls s3://bucket-name/
s3cmd ls s3://bucket-name/prefix/
```

**List all objects recursively:**
```bash
s3cmd ls --recursive s3://bucket-name/
```

**Upload a file:**
```bash
s3cmd put localfile.txt s3://bucket-name/path/file.txt
```

**Upload a directory:**
```bash
s3cmd put --recursive localdir/ s3://bucket-name/path/
```

**Download a file:**
```bash
s3cmd get s3://bucket-name/path/file.txt localfile.txt
```

**Sync local → bucket:**
```bash
s3cmd sync localdir/ s3://bucket-name/path/
```

**Sync bucket → local:**
```bash
s3cmd sync s3://bucket-name/path/ localdir/
```

Add `--delete-removed` to mirror deletions. Add `--dry-run` to preview.

## ACLs

**Inspect ACL / bucket info:**
```bash
s3cmd info s3://bucket-name
s3cmd info s3://bucket-name/path/file.txt
```

**Set ACL on a bucket or object:**
```bash
s3cmd setacl --acl-public  s3://bucket-name          # public-read
s3cmd setacl --acl-private s3://bucket-name          # private
s3cmd setacl --acl-public  s3://bucket-name/file.txt
```

**Apply recursively:**
```bash
s3cmd setacl --acl-private --recursive s3://bucket-name/
```

## Provider Configuration

See [references/providers.md](references/providers.md) for:
- Setting up AWS S3 and DigitalOcean Spaces config profiles
- DigitalOcean region endpoints
- Verifying a new config

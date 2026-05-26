---
name: aws-cli
description: "AWS CLI (aws) for querying and managing AWS resources. Use for S3 operations (list buckets/objects, upload, download, sync, copy, delete), ad-hoc resource queries, and checking AWS resource state. Triggers on 'aws', 'S3', or any AWS service request."
---

# aws-cli

AWS CLI v2 is installed. Single default profile — no `--profile` flag needed.

## Output control

```bash
--output json     # machine-readable (default for scripting)
--output table    # human-readable grid
--output text     # tab-separated, good for piping
--query '<JMESPath>'  # filter/shape output
```

Example — list only bucket names:
```bash
aws s3api list-buckets --query 'Buckets[].Name' --output text
```

## S3 high-level commands (`aws s3`)

Prefer these for everyday file operations:

```bash
# List buckets
aws s3 ls

# List objects in a bucket (top-level)
aws s3 ls s3://bucket-name/

# List recursively with sizes
aws s3 ls s3://bucket-name/ --recursive --human-readable

# Copy file up / down
aws s3 cp local.txt s3://bucket-name/path/file.txt
aws s3 cp s3://bucket-name/path/file.txt local.txt

# Sync local dir → bucket (skips unchanged files)
aws s3 sync ./local-dir/ s3://bucket-name/prefix/
aws s3 sync s3://bucket-name/prefix/ ./local-dir/

# Delete object
aws s3 rm s3://bucket-name/path/file.txt

# Move (rename within or between S3 locations)
aws s3 mv s3://bucket-name/old-key s3://bucket-name/new-key
```

Add `--dryrun` to preview without executing. Add `--delete` to `sync` to mirror deletions.

## S3 API commands (`aws s3api`)

Use for metadata, ACLs, presigned URLs, and anything not covered by `aws s3`.
See [references/s3api.md](references/s3api.md) for details.

## Checking identity / region

```bash
aws sts get-caller-identity    # current account ID, user/role ARN
aws configure get region       # configured default region
```

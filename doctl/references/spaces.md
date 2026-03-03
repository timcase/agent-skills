# Spaces

DigitalOcean Spaces is S3-compatible object storage. `doctl spaces`
only manages **access keys**. Bucket/object operations use the
S3-compatible API via tools like `s3cmd`, AWS CLI (`aws`), or any
S3 SDK.

## Access keys (doctl)

```bash
doctl spaces keys list
doctl spaces keys get <access-key-id>
doctl spaces keys create \
  --name "my-key" \
  --grants '[{"bucket":"my-space","permission":"readwrite"}]'
doctl spaces keys update <access-key-id> \
  --grants '[{"bucket":"my-space","permission":"read"}]'
doctl spaces keys delete <access-key-id>
```

Grant permissions: `read`, `readwrite`, `fullaccess`
Omit `--grants` for account-wide access.

## Bucket / object operations (AWS CLI)

Spaces endpoint format: `https://<region>.digitaloceanspaces.com`
Common regions: `nyc3`, `sfo3`, `ams3`, `sgp1`, `fra1`, `syd1`

```bash
# Configure AWS CLI for Spaces (one-time)
aws configure --profile spaces
# AWS Access Key ID: <spaces-access-key>
# AWS Secret Access Key: <spaces-secret>
# Default region name: us-east-1  (any value works)
# Default output format: json

# Use --endpoint-url with every command
ENDPOINT=https://nyc3.digitaloceanspaces.com
PROFILE=--profile spaces --endpoint-url $ENDPOINT

# List buckets
aws s3 ls $PROFILE

# List objects in a bucket
aws s3 ls $PROFILE s3://my-space/
aws s3 ls $PROFILE s3://my-space/prefix/ --recursive

# Upload / download
aws s3 cp $PROFILE ./file.txt s3://my-space/path/file.txt
aws s3 cp $PROFILE s3://my-space/path/file.txt ./file.txt
aws s3 sync $PROFILE ./local-dir s3://my-space/remote-dir

# Delete
aws s3 rm $PROFILE s3://my-space/path/file.txt
aws s3 rm $PROFILE s3://my-space/prefix/ --recursive

# Create / delete bucket
aws s3 mb $PROFILE s3://new-space
aws s3 rb $PROFILE s3://my-space --force

# Make object public
aws s3api $PROFILE put-object-acl \
  --bucket my-space --key path/file.txt --acl public-read
```

## s3cmd (alternative)

```bash
s3cmd --access_key=<key> --secret_key=<secret> \
  --host=nyc3.digitaloceanspaces.com \
  --host-bucket='%(bucket)s.nyc3.digitaloceanspaces.com' \
  ls s3://my-space/
```

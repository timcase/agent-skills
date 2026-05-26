# S3 API Reference (`aws s3api`)

Use `aws s3api` for low-level S3 operations not covered by the high-level `aws s3` commands.

## Object metadata

```bash
# Get object metadata (without downloading)
aws s3api head-object --bucket bucket-name --key path/to/file.txt

# List objects with metadata (first 1000)
aws s3api list-objects-v2 --bucket bucket-name --prefix path/

# Count objects and total size
aws s3api list-objects-v2 --bucket bucket-name \
  --query '{Count: KeyCount, Objects: Contents[].{Key: Key, Size: Size}}'
```

## Presigned URLs

```bash
# Generate a presigned download URL (1 hour default)
aws s3 presign s3://bucket-name/path/file.txt

# Custom expiry (in seconds)
aws s3 presign s3://bucket-name/path/file.txt --expires-in 3600
```

## Bucket operations

```bash
# Create a bucket (us-east-1 does not need LocationConstraint)
aws s3api create-bucket --bucket my-new-bucket \
  --create-bucket-configuration LocationConstraint=us-west-2

# Get bucket region
aws s3api get-bucket-location --bucket bucket-name

# Get bucket versioning status
aws s3api get-bucket-versioning --bucket bucket-name

# Get bucket ACL
aws s3api get-bucket-acl --bucket bucket-name
```

## Object ACLs and visibility

```bash
# Make object public-read
aws s3api put-object-acl --bucket bucket-name --key path/file.txt --acl public-read

# Make object private
aws s3api put-object-acl --bucket bucket-name --key path/file.txt --acl private

# Check object ACL
aws s3api get-object-acl --bucket bucket-name --key path/file.txt
```

## Server-side copy

```bash
# Copy within or between buckets (no download/upload)
aws s3api copy-object \
  --copy-source source-bucket/source-key \
  --bucket dest-bucket --key dest-key

# Change storage class in place
aws s3api copy-object \
  --copy-source bucket-name/key \
  --bucket bucket-name --key key \
  --storage-class STANDARD_IA \
  --metadata-directive COPY
```

## Filtering with --query (JMESPath)

```bash
# List only keys containing a string
aws s3api list-objects-v2 --bucket bucket-name \
  --query 'Contents[?contains(Key, `keyword`)].Key' --output text

# Objects larger than 1 MB
aws s3api list-objects-v2 --bucket bucket-name \
  --query 'Contents[?Size>`1000000`].{Key: Key, Size: Size}' --output table

# Objects modified after a date
aws s3api list-objects-v2 --bucket bucket-name \
  --query 'Contents[?LastModified>=`2024-01-01`].Key' --output text
```

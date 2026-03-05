# knife Data Bags & Vault Reference

## Data Bag Structure

Data bags in this repo: `users`, `cronjobs`, `ekamai`, `vault`
Local files: `/home/tcase/Sites/cinc/data_bags/`

## Common Operations

```bash
# List all bags and their items
knife data bag list
knife data bag show users

# View an item
knife data bag show users tcase
knife data bag show cronjobs cinc_client

# Edit an item (opens $EDITOR, saves to server on exit)
knife data bag edit users tcase

# Create a new item
knife data bag create users newuser
knife data bag edit users newuser

# Upload from local JSON file
knife data bag from file users data_bags/users/tcase.json
knife data bag from file users data_bags/users/   # upload entire folder
```

## Encrypted Data Bags

```bash
# View encrypted item (needs secret key)
knife data bag show vault secrets \
  --secret-file /etc/cinc/encrypted_data_bag_secret

# Edit encrypted item
knife data bag edit vault secrets \
  --secret-file /etc/cinc/encrypted_data_bag_secret

# Create encrypted item from file
knife data bag from file vault secrets.json \
  --secret-file /etc/cinc/encrypted_data_bag_secret
```

## knife-vault

knife vault wraps Chef Vault, which manages encrypted data bags with ACL-based key management. Items are encrypted per-node using that node's public key.

```bash
# List vaults
knife vault list

# Show vault item (auto-decrypts for authorized clients)
knife vault show vault secrets
knife vault show vault secrets key_name   # show specific key

# Create a vault item, granting access to nodes matching search
knife vault create vault secrets '{"password": "s3cr3t"}' \
  -S 'role:devmachine'

# Update existing vault item
knife vault update vault secrets '{"new_key": "value"}'

# Add/remove specific keys
knife vault remove vault secrets '["old_key"]'

# Edit vault item interactively
knife vault edit vault secrets

# Refresh access (after adding new nodes)
knife vault refresh vault secrets

# Rotate encryption keys
knife vault rotate keys vault secrets
knife vault rotate all keys
```

## User Data Bag Schema

Items in `data_bags/users/` typically contain:

```json
{
  "id": "tcase",
  "uid": 1001,
  "gid": 1001,
  "home": "/home/tcase",
  "shell": "/bin/zsh",
  "groups": ["sudo", "docker"],
  "ssh_keys": ["ssh-ed25519 AAAA..."]
}
```

## Cronjob Data Bag Schema

Items in `data_bags/cronjobs/` typically contain:

```json
{
  "id": "cinc_client",
  "minute": "*/30",
  "hour": "*",
  "command": "sudo cinc-client",
  "user": "root"
}
```

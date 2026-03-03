# Droplets

## List / Inspect

```bash
doctl compute droplet list
doctl compute droplet list --format ID,Name,PublicIPv4,Region,Status
doctl compute droplet get <id>
doctl compute droplet list --tag-name <tag>
```

## Create

```bash
doctl compute droplet create <name> \
  --region nyc3 \
  --size s-1vcpu-1gb \
  --image ubuntu-24-04-x64 \
  --ssh-keys <fingerprint-or-id> \
  --enable-ipv6 \
  --enable-monitoring \
  --tag-names web,production \
  --wait   # block until Droplet is active
```

Common sizes: `s-1vcpu-1gb`, `s-2vcpu-4gb`, `s-4vcpu-8gb`,
`g-2vcpu-8gb` (general purpose), `c-4` (CPU-optimized).

Get slugs: `doctl compute size list`
Get image slugs: `doctl compute image list --public`
Get SSH key IDs: `doctl compute ssh-key list`

## SSH

```bash
doctl compute ssh <id-or-name>
doctl compute ssh <id-or-name> --ssh-user ubuntu
```

## Actions (power management)

```bash
doctl compute droplet-action power-off --droplet-id <id>
doctl compute droplet-action power-on  --droplet-id <id>
doctl compute droplet-action reboot    --droplet-id <id>
doctl compute droplet-action resize    --droplet-id <id> \
  --size s-2vcpu-4gb --wait
```

## Snapshots

```bash
doctl compute droplet snapshots <id>
doctl compute droplet-action snapshot --droplet-id <id> \
  --snapshot-name my-snapshot --wait
doctl compute snapshot list
doctl compute snapshot delete <snapshot-id>
```

## Tags

```bash
doctl compute droplet tag   <id> --tag-name <tag>
doctl compute droplet untag <id> --tag-name <tag>
```

## Delete

```bash
doctl compute droplet delete <id>          # prompts for confirmation
doctl compute droplet delete <id> --force  # no prompt
```

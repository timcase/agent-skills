---
name: doctl
description: "DigitalOcean CLI (doctl) for managing cloud infrastructure. Use for: Droplets, container registries, Spaces storage, firewalls, load balancers, VPCs, reserved IPs, domains, or DNS. Triggers on 'doctl' or any DigitalOcean resource request."
---

# doctl

DigitalOcean CLI. Already installed and configured; invoke as `doctl`.

## Workflow

1. Read the relevant reference file for the resource type
2. Run `doctl` commands via Bash
3. Use `-o json` for machine-readable output; default text is fine for
   display

## Global flags

```
-o json          # JSON output
--no-header      # suppress column headers
--format <cols>  # comma-separated column names to display
--context <name> # auth context (multiple accounts)
```

## Reference files

Load the appropriate file before working with a resource:

| Domain | File |
|---|---|
| Droplets | `references/droplets.md` |
| Container Registries | `references/registries.md` |
| Spaces (object storage) | `references/spaces.md` |
| Firewalls, LBs, VPCs, IPs | `references/networking.md` |
| Domains / DNS | `references/dns.md` |

## Common lookups

```bash
doctl compute region list          # region slugs (nyc3, sfo3, etc.)
doctl compute size list            # Droplet size slugs
doctl compute image list --public  # OS image slugs
doctl account get                  # current auth account
doctl auth list                    # all configured auth contexts
```

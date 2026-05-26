---
name: hcloud
description: Manage Hetzner Cloud resources using the hcloud CLI. Use for servers, volumes, snapshots, firewalls, networks, load balancers, SSH keys, and placement groups. Triggers on 'hcloud', 'Hetzner', or any Hetzner Cloud resource management task.
---

# hcloud — Hetzner Cloud CLI

## Output formats

All list/describe commands support `-o json` or `-o yaml`. Use `--output columns=name,status,ipv4` to select columns.

```bash
hcloud server list -o json
hcloud server list -o columns=name,status,ipv4,type,location
hcloud server describe my-server -o json
```

## Servers

```bash
# List
hcloud server list
hcloud server list -l env=prod          # filter by label

# Create (--location preferred over --datacenter, which is deprecated)
hcloud server create \
  --name my-server \
  --type cx22 \
  --image ubuntu-24.04 \
  --location nbg1 \
  --ssh-key my-key \
  --firewall my-firewall \
  --network my-network

# Common flags: --volume, --placement-group, --user-data-from-file, --enable-backup
# --without-ipv4 / --without-ipv6, --enable-protection delete,rebuild

# Power
hcloud server reboot my-server
hcloud server poweron my-server
hcloud server shutdown my-server   # graceful
hcloud server poweroff my-server   # hard stop

# Info & access
hcloud server describe my-server
hcloud server ip my-server
hcloud server ssh my-server

# Resize
hcloud server change-type my-server --server-type cx32

# Snapshot
hcloud server create-image my-server --type snapshot --description "before-upgrade"

# Delete
hcloud server delete my-server
```

## Volumes

```bash
hcloud volume list
hcloud volume create --name data --size 50 --location nbg1 --server my-server
hcloud volume attach data --server my-server --automount
hcloud volume detach data
hcloud volume resize data --size 100
hcloud volume delete data
```

## Snapshots & Images

```bash
hcloud image list                          # all images (public + snapshots)
hcloud image list --type snapshot
hcloud image list --type backup
hcloud image describe <id>
hcloud image delete <id>
hcloud server rebuild my-server --image <snapshot-id>
```

## Firewalls

```bash
hcloud firewall list
hcloud firewall create --name web-fw

# Add rules
hcloud firewall add-rule web-fw \
  --direction in --protocol tcp --port 443 --source-ips 0.0.0.0/0,::/0
hcloud firewall add-rule web-fw \
  --direction in --protocol icmp --source-ips 0.0.0.0/0,::/0

# Apply / remove from resources
hcloud firewall apply-to-resource web-fw --type server --server my-server
hcloud firewall remove-from-resource web-fw --type server --server my-server

# Bulk replace rules from JSON file
hcloud firewall replace-rules web-fw --rules-file rules.json

hcloud firewall describe web-fw
hcloud firewall delete web-fw
```

## Networks

```bash
hcloud network list
hcloud network create --name private-net --ip-range 10.0.0.0/16
hcloud network add-subnet private-net \
  --type cloud --ip-range 10.0.1.0/24 --network-zone eu-central

hcloud server attach-to-network my-server --network private-net --ip 10.0.1.10
hcloud server detach-from-network my-server --network private-net

hcloud network delete private-net
```

## Load Balancers

```bash
hcloud load-balancer list
hcloud load-balancer create --name my-lb --type lb11 --location nbg1
hcloud load-balancer add-target my-lb --type server --server my-server
hcloud load-balancer add-service my-lb \
  --protocol http --listen-port 80 --destination-port 8080
hcloud load-balancer attach-to-network my-lb --network private-net
hcloud load-balancer describe my-lb
hcloud load-balancer delete my-lb
```

## SSH Keys

```bash
hcloud ssh-key list
hcloud ssh-key create --name my-key --public-key-from-file ~/.ssh/id_ed25519.pub
hcloud ssh-key describe my-key
hcloud ssh-key delete my-key
```

## Placement Groups

```bash
hcloud placement-group list
hcloud placement-group create --name spread-group --type spread
hcloud server add-to-placement-group my-server --placement-group spread-group
hcloud server remove-from-placement-group my-server
hcloud placement-group delete spread-group
```

## Discovery (locations, server types, images)

```bash
hcloud location list
hcloud server-type list
hcloud image list --type system        # official OS images
```

## Scripting & jq patterns

See [references/scripting.md](references/scripting.md) for output formats, jq patterns, and shell scripting examples.

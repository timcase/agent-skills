# hcloud — Scripting & jq Patterns

## Output formats

`-o json` produces a top-level array for list commands, a single object for describe.

```bash
hcloud server list -o json        # array of server objects
hcloud server describe web -o json # single server object
```

## Extracting values with jq

```bash
# List server names and IPs
hcloud server list -o json | jq -r '.[] | "\(.name) \(.public_net.ipv4.ip)"'

# Get IP of a specific server
hcloud server list -o json | jq -r '.[] | select(.name=="my-server") | .public_net.ipv4.ip'

# List all running servers
hcloud server list -o json | jq -r '.[] | select(.status=="running") | .name'

# Get server ID by name
hcloud server list -o json | jq -r '.[] | select(.name=="my-server") | .id'

# List snapshot IDs and descriptions
hcloud image list -o json | jq -r '.[] | select(.type=="snapshot") | "\(.id) \(.description)"'

# Get volume IDs attached to a server
hcloud server describe my-server -o json | jq -r '.volumes[]'

# List firewall names applied to a server
hcloud server describe my-server -o json | jq -r '.firewall_status[].firewall.name'
```

## Shell scripting patterns

```bash
# Get server IP into a variable
IP=$(hcloud server ip my-server)

# Iterate over all servers matching a label
hcloud server list -l env=prod -o columns=name --no-header | while read name; do
  echo "Processing $name"
done

# Delete all snapshots older than a certain description pattern
hcloud image list -o json \
  | jq -r '.[] | select(.type=="snapshot") | .id' \
  | xargs -I{} hcloud image delete {}

# Create server and capture ID
SERVER_ID=$(hcloud server create --name test --type cx22 --image ubuntu-24.04 \
  --location nbg1 -o json | jq -r '.server.id')
echo "Created server $SERVER_ID"
```

## Column output (no-header for scripting)

```bash
# Suppress header for piping
hcloud server list -o columns=name,ipv4 --no-header

# Custom columns available for servers:
# id, name, status, type, location, ipv4, ipv6, datacenter,
# labels, volumes, created, placement_group, protection
```

## Labels (filtering and tagging)

```bash
# Add/update label
hcloud server add-label my-server env=prod team=backend

# Remove label
hcloud server remove-label my-server env

# Filter by label selector
hcloud server list -l env=prod
hcloud server list -l "env in (prod,staging)"
hcloud server list -l "env!=dev"
```

## Firewall rules JSON format (for replace-rules)

```json
[
  {
    "direction": "in",
    "protocol": "tcp",
    "port": "22",
    "source_ips": ["0.0.0.0/0", "::/0"],
    "description": "SSH"
  },
  {
    "direction": "in",
    "protocol": "tcp",
    "port": "443",
    "source_ips": ["0.0.0.0/0", "::/0"],
    "description": "HTTPS"
  },
  {
    "direction": "in",
    "protocol": "icmp",
    "source_ips": ["0.0.0.0/0", "::/0"]
  }
]
```

## User data (cloud-init)

```bash
hcloud server create --name my-server --type cx22 --image ubuntu-24.04 \
  --location nbg1 --user-data-from-file cloud-init.yaml
```

Minimal cloud-init example:

```yaml
#cloud-config
packages:
  - nginx
runcmd:
  - systemctl enable nginx
  - systemctl start nginx
```

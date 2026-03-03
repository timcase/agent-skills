# Networking

## Firewalls

```bash
doctl compute firewall list
doctl compute firewall get <id>
doctl compute firewall list-by-droplet <droplet-id>

# Create firewall
doctl compute firewall create \
  --name my-fw \
  --inbound-rules  "protocol:tcp,ports:22,sources:addresses:0.0.0.0/0" \
  --inbound-rules  "protocol:tcp,ports:80,sources:addresses:0.0.0.0/0" \
  --outbound-rules "protocol:tcp,ports:all,destinations:addresses:0.0.0.0/0,::1/0"

# Add/remove rules
doctl compute firewall add-rules <id> \
  --inbound-rules "protocol:tcp,ports:443,sources:addresses:0.0.0.0/0"
doctl compute firewall remove-rules <id> \
  --inbound-rules "protocol:tcp,ports:443,sources:addresses:0.0.0.0/0"

# Assign Droplets
doctl compute firewall add-droplets    <id> --droplet-ids <id1>,<id2>
doctl compute firewall remove-droplets <id> --droplet-ids <id1>

# Assign by tag
doctl compute firewall add-tags    <id> --tag-names production
doctl compute firewall remove-tags <id> --tag-names production

doctl compute firewall delete <id>
```

Rule format reference:
- `sources` / `destinations`: `addresses:<cidr>`, `droplet_ids:<id>`,
  `load_balancer_uids:<uid>`, `tags:<name>`
- `ports`: `22`, `80`, `443`, `8000-9000`, or `all`
- `protocol`: `tcp`, `udp`, `icmp`

## Load Balancers

```bash
doctl compute load-balancer list
doctl compute load-balancer get <id>

doctl compute load-balancer create \
  --name my-lb \
  --region nyc3 \
  --forwarding-rules "entry_protocol:http,entry_port:80,\
target_protocol:http,target_port:8080" \
  --droplet-ids <id1>,<id2>
  # or --tag-name <tag> to target by tag

doctl compute load-balancer update <id> \
  --forwarding-rules "entry_protocol:https,entry_port:443,\
target_protocol:http,target_port:8080,\
certificate_id:<cert-id>,tls_passthrough:false"

doctl compute load-balancer add-droplets    <id> --droplet-ids <ids>
doctl compute load-balancer remove-droplets <id> --droplet-ids <ids>
doctl compute load-balancer delete <id>
```

## VPCs

VPCs use the top-level `doctl vpcs` command (not `doctl compute`).

```bash
doctl vpcs list
doctl vpcs get <id>

doctl vpcs create \
  --name my-vpc \
  --region nyc3 \
  --ip-range 10.10.0.0/16

doctl vpcs update <id> --name new-name --description "desc"
doctl vpcs delete <id>
```

## Reserved IPs

```bash
doctl compute reserved-ip list
doctl compute reserved-ip get <ip>

# Reserve an IP in a region
doctl compute reserved-ip create --region nyc3

# Assign / unassign from a Droplet
doctl compute reserved-ip-action assign   <ip> <droplet-id>
doctl compute reserved-ip-action unassign <ip>

doctl compute reserved-ip delete <ip>
```

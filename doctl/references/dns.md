# Domains / DNS

## Domains

```bash
doctl compute domain list
doctl compute domain get <domain>          # e.g. example.com

# Add domain to account (delegates DNS to DigitalOcean)
doctl compute domain create example.com \
  --ip-address <droplet-ip>               # creates root A record

doctl compute domain delete example.com
```

DigitalOcean nameservers: `ns1.digitalocean.com`, `ns2.digitalocean.com`,
`ns3.digitalocean.com`

## DNS Records

```bash
doctl compute domain records list <domain>
doctl compute domain records list <domain> --format ID,Type,Name,Data,TTL
```

### Create records

```bash
# A record
doctl compute domain records create example.com \
  --record-type A --record-name @ --record-data 1.2.3.4 --record-ttl 3600

# CNAME
doctl compute domain records create example.com \
  --record-type CNAME --record-name www --record-data @ --record-ttl 3600

# MX
doctl compute domain records create example.com \
  --record-type MX \
  --record-name @ \
  --record-data mail.example.com. \
  --record-priority 10 \
  --record-ttl 3600

# TXT (SPF, DKIM, domain verification, etc.)
doctl compute domain records create example.com \
  --record-type TXT \
  --record-name @ \
  --record-data "v=spf1 include:_spf.google.com ~all" \
  --record-ttl 3600

# AAAA (IPv6)
doctl compute domain records create example.com \
  --record-type AAAA --record-name @ --record-data <ipv6> --record-ttl 3600

# NS
doctl compute domain records create example.com \
  --record-type NS --record-name @ --record-data ns1.example.com.

# SRV
doctl compute domain records create example.com \
  --record-type SRV \
  --record-name _service._proto \
  --record-data target.example.com. \
  --record-priority 10 \
  --record-weight 5 \
  --record-port 8080
```

### Update / delete records

```bash
# Get the record ID first
doctl compute domain records list example.com --format ID,Type,Name,Data

doctl compute domain records update example.com \
  --record-id <id> \
  --record-data 1.2.3.5 \
  --record-ttl 1800

doctl compute domain records delete example.com --record-id <id>
```

### Wildcard records

Use `*` as the record name:

```bash
doctl compute domain records create example.com \
  --record-type A --record-name "*" --record-data 1.2.3.4
```

# Cloudflare DNS API Reference

Base URL: `https://api.cloudflare.com/client/v4`
Auth header: `Authorization: Bearer $CLOUDFLARE_API_TOKEN`

---

## Find Zone ID

```bash
curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=example.com" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" | jq '.result[0].id'
```

Save the returned string as `ZONE_ID`.

---

## List DNS Records

```bash
curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" | jq '.result[] | {id, type, name, content}'
```

Filter by type or name:

```bash
# By type
.../dns_records?type=CNAME

# By name (exact match)
.../dns_records?name=www.example.com
```

---

## Create a DNS Record

```bash
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "A",
    "name": "subdomain.example.com",
    "content": "1.2.3.4",
    "ttl": 1,
    "proxied": false
  }'
```

`"ttl": 1` means "Auto" in Cloudflare's UI. Use `"proxied": true` for orange-cloud.

### Record type bodies

**A** — IPv4 address
```json
{ "type": "A", "name": "sub.example.com", "content": "1.2.3.4", "ttl": 1, "proxied": false }
```

**AAAA** — IPv6 address
```json
{ "type": "AAAA", "name": "sub.example.com", "content": "2001:db8::1", "ttl": 1, "proxied": false }
```

**CNAME**
```json
{ "type": "CNAME", "name": "www.example.com", "content": "example.com", "ttl": 1, "proxied": true }
```

**MX**
```json
{ "type": "MX", "name": "example.com", "content": "mail.example.com", "priority": 10, "ttl": 1 }
```

**TXT** — SPF, DKIM, domain verification, etc.
```json
{ "type": "TXT", "name": "example.com", "content": "v=spf1 include:_spf.google.com ~all", "ttl": 1 }
```

---

## Update a DNS Record

Requires the record ID (from list endpoint).

```bash
curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "content": "5.6.7.8"
  }'
```

`PATCH` updates only the fields you send. `PUT` replaces the entire record (requires all fields).

---

## Delete a DNS Record

```bash
curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN"
```

---

## Response shape

Success:
```json
{ "success": true, "result": { "id": "...", "type": "A", "name": "...", "content": "..." } }
```

Error:
```json
{ "success": false, "errors": [{ "code": 81057, "message": "The record already exists." }] }
```

Always check `success` before treating the result as valid.

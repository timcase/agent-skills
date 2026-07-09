# Broadcasting: Station Control

BASE = `https://radio.lysn.bar/api`  
Auth header: `X-API-Key: $LYSN_API_KEY`

## Restart & Service Control

```bash
# Restart ALL services (frontend + backend)
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/restart"

# Frontend only (Icecast/Shoutcast): start | stop | reload | restart
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/frontend/restart"
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/frontend/start"
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/frontend/stop"

# Backend only (Liquidsoap): start | stop | reload | restart | skip | disconnect
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/backend/restart"
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/backend/skip"
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/backend/disconnect"
```

## Mount Points

```bash
# List all mount points
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/mounts"

# Get a single mount point
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/mount/{id}"

# Create a mount point
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "/radio.mp3", "display_name": "Main Stream", "is_default": true, "enable_autodj": true}' \
  "$BASE/station/1/mounts"

# Update a mount point
curl -s -X PUT -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"display_name": "Updated Stream"}' \
  "$BASE/station/1/mount/{id}"

# Delete a mount point
curl -s -X DELETE -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/mount/{id}"

# Upload intro file for a mount
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"path": "intro.mp3", "file": "<base64>"}' \
  "$BASE/station/1/mount/{id}/intro"
```

## Streamers (Live DJs)

```bash
# List all streamers
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/streamers"

# Get a single streamer
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/streamer/{id}"

# Create a streamer
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"streamer_username": "djname", "streamer_password": "pass", "display_name": "DJ Name", "is_active": true}' \
  "$BASE/station/1/streamers"

# Update a streamer
curl -s -X PUT -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"display_name": "New Name"}' \
  "$BASE/station/1/streamer/{id}"

# Delete a streamer
curl -s -X DELETE -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/streamer/{id}"

# List broadcasts for a streamer
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/streamer/{id}/broadcasts"

# Download a broadcast recording
GET /station/1/streamer/{id}/broadcast/{broadcast_id}/download
```

## Remote Relays

```bash
# List remote relays
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/remotes"

# Get/create/update/delete a remote relay
GET/POST/PUT/DELETE "$BASE/station/1/remote/{id}"
```

## HLS Streams

```bash
# List HLS streams
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/hls_streams"

# Get/create/update/delete
GET/POST/PUT/DELETE "$BASE/station/1/hls_stream/{id}"
```

## Webhooks

```bash
# List webhooks
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/webhooks"

# Get/create/update/delete webhook
GET/POST/PUT/DELETE "$BASE/station/1/webhook/{id}"

# Toggle webhook on/off
curl -s -X PUT -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/webhook/{id}/toggle"

# Test a webhook
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/webhook/{id}/test"
```

## Liquidsoap Config

```bash
# Export current Liquidsoap config
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/liquidsoap-config/export"

# Get writable Liquidsoap config
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/liquidsoap-config"

# Update Liquidsoap config
curl -s -X PUT -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"config": "..."}' \
  "$BASE/station/1/liquidsoap-config"
```

## SFTP Users

```bash
# List SFTP users
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/sftp-users"

# Create an SFTP user
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"username": "user", "password": "pass"}' \
  "$BASE/station/1/sftp-users"

# Delete an SFTP user
curl -s -X DELETE -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/sftp-user/{id}"
```

## Song Requests (listener-facing)

```bash
# List requestable songs (public)
curl -s "$BASE/station/1/requests"

# Submit a song request (public)
curl -s -X POST "$BASE/station/1/request/{request_id}"
```

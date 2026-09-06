---
name: azuracast
description: "Manage an AzuraCast web radio station via its REST API. Use for: checking what's playing, managing playlists/media, restarting the station, viewing listeners, reports, schedule, queue, podcasts, mounts, streamers, and full station administration."
---

# AzuraCast

REST API for managing the radio station at `https://radio.lysn.bar`.

## Auth & base URL

```bash
BASE="https://radio.lysn.bar/api"
KEY="${LYSN_API_KEY}"   # set in environment
```

All requests use `X-API-Key: $KEY` header. Public endpoints (now playing, schedule, requests) work without auth.

## curl pattern

```bash
# GET
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/status"

# POST with JSON body
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}' \
  "$BASE/station/1/restart"

# PUT
curl -s -X PUT -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{...}' \
  "$BASE/station/1/playlist/5"

# DELETE
curl -s -X DELETE -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/queue/42"
```

Pipe to `| python3 -m json.tool` or `| jq` for readable output.

## Station ID

The current station ID is `4` ("Hard Bop 24"). The `references/*` examples use `1` as a
placeholder — substitute `4`. Confirm the current ID with:

```bash
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/admin/stations" | python3 -m json.tool
```

## Reference files

Load the appropriate file for the task:

| Area | File | What's covered |
|---|---|---|
| Now playing, queue, schedule, history, status | `references/station.md` | Live state, playback history |
| Files, playlists, media upload | `references/media.md` | Library management, adding songs |
| Restart, frontend/backend control, mounts, streamers | `references/broadcasting.md` | Station services |
| Listeners, reports, analytics | `references/reports.md` | Audience data |
| Podcasts | `references/podcasts.md` | Episode management |

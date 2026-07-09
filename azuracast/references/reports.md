# Reports & Listeners

BASE = `https://radio.lysn.bar/api`  
Auth header: `X-API-Key: $LYSN_API_KEY`

## Current Listeners

```bash
# Detailed info about current listeners (IP, client, stream, duration)
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/listeners"
```

Response fields per listener: `ip`, `user_agent`, `connected_seconds`, `mount_name`, `location` (country, region, city).

## Overview Reports

```bash
# Best and worst performing songs
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/reports/overview/best-and-worst"

# Listeners by browser
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/reports/overview/by-browser"

# Listeners by client app
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/reports/overview/by-client"

# Listeners by country
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/reports/overview/by-country"

# Listeners by listening time (duration buckets)
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/reports/overview/by-listening-time"

# Listeners by stream/mount
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/reports/overview/by-stream"

# Listener count charts (time-series data)
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/reports/overview/charts"
```

## Song Request Reports

```bash
# List pending/recent song requests
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/reports/requests"

# Clear all pending requests
curl -s -X DELETE -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/reports/requests/clear"

# Delete a specific pending request
curl -s -X DELETE -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/reports/requests/{request_id}"
```

## SoundExchange Report

```bash
# Get SoundExchange royalty report (date range required)
curl -s -H "X-API-Key: $LYSN_API_KEY" \
  "$BASE/station/1/reports/soundexchange?start_date=2024-01-01&end_date=2024-12-31"
```

## Playback History

See `references/station.md` — `GET /station/1/history` with optional `start`/`end` query params.

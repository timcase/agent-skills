# Station: Live State & History

BASE = `https://radio.lysn.bar/api`  
Auth header: `X-API-Key: $LYSN_API_KEY`

## Now Playing

```bash
# Full now-playing summary (public, no auth needed)
curl -s "$BASE/nowplaying/1" | python3 -m json.tool

# Now-playing art redirect
GET /nowplaying/1/art
```

Response includes: `now_playing.song` (title, artist, album), `listeners.current`, `live` (is live streaming?), `station` (name, shortcode), `playing_next`.

## Station Status

```bash
# Service status (frontend + backend running?)
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/status"

# Station profile/details
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1"

# Station profile (editable settings)
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/profile"
```

## Playback Queue

```bash
# Upcoming songs in queue
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/queue"

# Delete a queued item
curl -s -X DELETE -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/queue/{id}"
```

## Schedule

```bash
# Upcoming/ongoing schedule entries (public)
curl -s "$BASE/station/1/schedule"

# Limit results
curl -s "$BASE/station/1/schedule?rows=10"

# Schedule at a specific time
curl -s "$BASE/station/1/schedule?now=2024-12-25T20:00:00"
```

## Playback History

```bash
# Recent song history
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/history"

# Filtered by date range (PHP date/time format)
curl -s -H "X-API-Key: $LYSN_API_KEY" \
  "$BASE/station/1/history?start=2024-12-01&end=2024-12-31"
```

## Logs

```bash
# List available log types
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/logs"

# View a specific log
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/log/{key}"
```

## Update Now Playing (manual trigger)

```bash
curl -s -X PUT -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/nowplaying/update"
```

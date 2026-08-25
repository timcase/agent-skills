# Player (playback control)

Requires a user token with `user-read-playback-state` (read) and/or
`user-modify-playback-state` (control) scopes. **Requires Spotify Premium** — most
write endpoints 403 for free accounts. Playback must be active on some device
(desktop app, mobile app, web player, or a Connect-enabled speaker) — the API doesn't
start playback out of thin air on a machine with no Spotify client running.

## State

```bash
# Current playback state (device, track, progress, shuffle/repeat, is_playing)
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/me/player"

# Just the currently playing track
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/me/player/currently-playing"

# Available devices
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/me/player/devices"
```

`GET /me/player` returns 204 No Content (empty body) when nothing is active — don't
treat that as an error.

## Control

All control endpoints accept `?device_id=$DEVICE_ID` to target a specific device;
omitted, they act on whatever device is currently active.

```bash
# Play (optionally with context_uri/uris + position)
curl -s -X PUT -H "Authorization: Bearer $SPOTIFY_TOKEN" -H "Content-Type: application/json" \
  -d '{"context_uri": "spotify:album:'"$ALBUM_ID"'", "offset": {"position": 0}}' \
  "https://api.spotify.com/v1/me/player/play"

curl -s -X PUT -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/me/player/pause"

curl -s -X POST -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/me/player/next"
curl -s -X POST -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/me/player/previous"

# Seek (ms), volume (0-100), shuffle/repeat
curl -s -X PUT -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  "https://api.spotify.com/v1/me/player/seek?position_ms=30000"
curl -s -X PUT -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  "https://api.spotify.com/v1/me/player/volume?volume_percent=50"
curl -s -X PUT -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  "https://api.spotify.com/v1/me/player/shuffle?state=true"
curl -s -X PUT -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  "https://api.spotify.com/v1/me/player/repeat?state=context"   # track|context|off

# Transfer playback to another device
curl -s -X PUT -H "Authorization: Bearer $SPOTIFY_TOKEN" -H "Content-Type: application/json" \
  -d '{"device_ids": ["'"$DEVICE_ID"'"], "play": true}' \
  "https://api.spotify.com/v1/me/player"
```

## Queue

```bash
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/me/player/queue"

curl -s -X POST -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  "https://api.spotify.com/v1/me/player/queue?uri=spotify:track:$TRACK_ID"
```

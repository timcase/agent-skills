# Playlists and library

Requires a user (Authorization Code) token with the relevant scope — see
`auth.md#scopes`.

## Playlists

```bash
# Current user's playlists
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/me/playlists"

# A specific playlist
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/playlists/$PLAYLIST_ID"

# Create (needs the user id from GET /me)
curl -s -X POST -H "Authorization: Bearer $SPOTIFY_TOKEN" -H "Content-Type: application/json" \
  -d '{"name": "My Playlist", "description": "Made via API", "public": false}' \
  "https://api.spotify.com/v1/users/$USER_ID/playlists"
```

### Playlist items (tracks) — use `/items`, not `/tracks`

`GET/POST/PUT/DELETE /playlists/{id}/tracks` is deprecated. Use `/playlists/{id}/items`:

```bash
# Read items (paginated)
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  "https://api.spotify.com/v1/playlists/$PLAYLIST_ID/items?limit=50"

# Add items (uris, not bare ids)
curl -s -X POST -H "Authorization: Bearer $SPOTIFY_TOKEN" -H "Content-Type: application/json" \
  -d '{"uris": ["spotify:track:'"$TRACK_ID"'"]}' \
  "https://api.spotify.com/v1/playlists/$PLAYLIST_ID/items"

# Reorder / replace — PUT with range_start/insert_before, or full "uris" replace
curl -s -X PUT -H "Authorization: Bearer $SPOTIFY_TOKEN" -H "Content-Type: application/json" \
  -d '{"range_start": 0, "insert_before": 3}' \
  "https://api.spotify.com/v1/playlists/$PLAYLIST_ID/items"

# Remove items
curl -s -X DELETE -H "Authorization: Bearer $SPOTIFY_TOKEN" -H "Content-Type: application/json" \
  -d '{"tracks": [{"uri": "spotify:track:'"$TRACK_ID"'"}]}' \
  "https://api.spotify.com/v1/playlists/$PLAYLIST_ID/items"
```

Cover image: `GET/PUT /playlists/{id}/images` (PUT body is base64 JPEG, ≤256KB).

## Saved library (user's "Liked Songs" / saved albums)

```bash
# Check / read
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/me/tracks"
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/me/albums"
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  "https://api.spotify.com/v1/me/tracks/contains?ids=$ID1,$ID2"

# Save / remove (PUT to add, DELETE to remove, body or query {"ids": [...]})
curl -s -X PUT -H "Authorization: Bearer $SPOTIFY_TOKEN" -H "Content-Type: application/json" \
  -d '{"ids": ["'"$TRACK_ID"'"]}' "https://api.spotify.com/v1/me/tracks"
```

## Following

```bash
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  "https://api.spotify.com/v1/me/following?type=artist"

curl -s -X PUT -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  "https://api.spotify.com/v1/me/following?type=artist&ids=$ARTIST_ID"
```

## User profile / top items

```bash
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/me"
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  "https://api.spotify.com/v1/me/top/tracks?time_range=medium_term"
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/me/player/recently-played"
```

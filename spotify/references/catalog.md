# Catalog: search, tracks, albums, artists

Works with either a Client Credentials or user token. All GET requests, all take
`?market=<ISO-3166 country code>` to filter to playable results in that market.

## Search

```bash
curl -s -G -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  "https://api.spotify.com/v1/search" \
  --data-urlencode "q=Random Access Memories artist:Daft Punk" \
  --data-urlencode "type=track,album,artist,playlist" \
  --data-urlencode "limit=20"
```

- `type` is comma-separated; response has one array per requested type
  (`tracks.items`, `albums.items`, etc.), each paginated (`limit`, `offset`, `next`).
- Field filters in `q`: `artist:`, `album:`, `track:`, `year:`, `genre:`, `isrc:`,
  `upc:`. Combine freely, e.g. `q=genre:jazz year:2020-2023`.

## Tracks / Albums / Artists — single and batch

```bash
# Single
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/tracks/$ID"
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/albums/$ID"
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/artists/$ID"

# Batch (comma-separated ids, max 50 tracks/albums, 50 artists)
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  "https://api.spotify.com/v1/tracks?ids=$ID1,$ID2,$ID3"
```

- Album tracks: `GET /albums/{id}/tracks` (paginated).
- Artist's albums: `GET /artists/{id}/albums?include_groups=album,single,appears_on,compilation`.
- Artist's top tracks: `GET /artists/{id}/top-tracks?market=US`.
- 30-second `preview_url` in track objects is frequently `null` — restricted for apps
  without Extended Quota Mode (see SKILL.md gotchas) and not guaranteed even then.

## Restricted for new apps (see SKILL.md)

`GET /audio-features/{id}`, `GET /audio-analysis/{id}`, `GET /recommendations`, and
`GET /artists/{id}/related-artists` return 403/404-style restrictions for apps that
don't have pre-existing Extended Quota Mode access. Don't build a workflow around these
without first confirming the app's access mode.

## Browse

```bash
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/browse/new-releases"
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" "https://api.spotify.com/v1/browse/categories"
```

`Get Featured Playlists` and `Get a Category's Playlists` are in the restricted list
above — don't rely on them for new apps.

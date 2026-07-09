# Media & Playlists

BASE = `https://radio.lysn.bar/api`  
Auth header: `X-API-Key: $LYSN_API_KEY`

## Files (Media Library)

```bash
# List all uploaded files
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/files"

# List files in a directory
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/files/list?currentDirectory=path/to/dir"

# Get details for a single file
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/file/{id}"

# Upload a new file (base64-encoded content)
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"path": "folder/song.mp3", "file": "<base64-encoded-content>"}' \
  "$BASE/station/1/files"

# Edit file metadata (title, artist, album, etc.)
curl -s -X PUT -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"title": "My Song", "artist": "Artist Name", "album": "Album"}' \
  "$BASE/station/1/file/{id}"

# Delete a file
curl -s -X DELETE -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/file/{id}"

# Download a file
GET /station/1/files/download?file={path}

# Create a directory
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"currentDirectory": "", "name": "NewFolder"}' \
  "$BASE/station/1/files/mkdir"

# Rename a file/directory
curl -s -X PUT -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"from": "old/path.mp3", "to": "new/path.mp3"}' \
  "$BASE/station/1/files/rename"

# Quota usage
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/quota"
```

### Batch file operations

```bash
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"do": "delete", "current_directory": "", "files": ["path1.mp3", "path2.mp3"]}' \
  "$BASE/station/1/files/batch"
```

`do` options: `delete`, `playlist` (add to playlist), `move`, `queue`

## Playlists

```bash
# List all playlists
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/playlists"

# Get a single playlist
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/playlist/{id}"

# Create a playlist
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "My Playlist", "type": "default", "source": "songs", "order": "shuffle", "is_enabled": true}' \
  "$BASE/station/1/playlists"

# Update a playlist
curl -s -X PUT -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "Updated Name", "is_enabled": true}' \
  "$BASE/station/1/playlist/{id}"

# Delete a playlist
curl -s -X DELETE -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/playlist/{id}"

# Toggle playlist on/off
curl -s -X PUT -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/playlist/{id}/toggle"

# Empty a playlist (remove all songs)
curl -s -X DELETE -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/playlist/{id}/empty"

# View songs in playlist queue
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/playlist/{id}/queue"

# Reshuffle playlist
curl -s -X PUT -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/playlist/{id}/reshuffle"

# Clone a playlist
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "Clone Name"}' \
  "$BASE/station/1/playlist/{id}/clone"
```

### Adding songs to a playlist

Use the batch files endpoint with `do: "playlist"`:

```bash
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "do": "playlist",
    "files": ["relative/path/to/song.mp3"],
    "playlist": 5
  }' \
  "$BASE/station/1/files/batch"
```

`playlist` is the numeric playlist ID from `GET /station/1/playlists`.

### Playlist schedule (set when a playlist plays)

Schedule items live inside the playlist object's `schedule_items` array. To set a schedule, PUT the full playlist with `schedule_items`:

```json
{
  "name": "Morning Show",
  "schedule_items": [
    {
      "start_time": 600,
      "end_time": 900,
      "days": [1, 2, 3, 4, 5]
    }
  ]
}
```

`start_time`/`end_time` are minutes from midnight (600 = 10:00, 900 = 15:00). `days`: 1=Mon … 7=Sun.

### Import/export playlist

```bash
# Export as M3U or PLS
GET /station/1/playlist/{id}/export/m3u
GET /station/1/playlist/{id}/export/pls

# Import from M3U/PLS file
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -F "playlist_file=@my-playlist.m3u" \
  "$BASE/station/1/playlist/{id}/import"
```

## On-Demand

```bash
# List on-demand media for a station (public)
curl -s "$BASE/station/1/ondemand"

# Download on-demand media
GET /station/1/ondemand/download/{media_id}
```

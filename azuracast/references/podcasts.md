# Podcasts

BASE = `https://radio.lysn.bar/api`  
Auth header: `X-API-Key: $LYSN_API_KEY`

## Podcasts

```bash
# List all podcasts for the station
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/podcasts"

# Get a single podcast
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/podcast/{id}"

# Create a podcast
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My Podcast",
    "description": "A podcast description",
    "language": "en",
    "author": "Author Name",
    "email": "email@example.com",
    "website": "https://example.com",
    "categories": [{"text": "Music"}]
  }' \
  "$BASE/station/1/podcasts"

# Update a podcast
curl -s -X PUT -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated Title"}' \
  "$BASE/station/1/podcast/{id}"

# Delete a podcast
curl -s -X DELETE -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/podcast/{id}"

# Upload podcast artwork
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"path": "cover.jpg", "file": "<base64>"}' \
  "$BASE/station/1/podcast/{podcast_id}/art"

# Delete podcast artwork
curl -s -X DELETE -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/podcast/{podcast_id}/art"
```

## Episodes

```bash
# List episodes for a podcast
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/podcast/{podcast_id}/episodes"

# Get a single episode
curl -s -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/podcast/{podcast_id}/episode/{id}"

# Create an episode
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Episode Title",
    "description": "Episode description",
    "publish_at": null,
    "is_published": true,
    "season_number": 1,
    "episode_number": 1
  }' \
  "$BASE/station/1/podcast/{podcast_id}/episodes"

# Update an episode
curl -s -X PUT -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated Title", "is_published": true}' \
  "$BASE/station/1/podcast/{podcast_id}/episode/{id}"

# Delete an episode
curl -s -X DELETE -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/podcast/{podcast_id}/episode/{id}"

# Upload episode media
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"path": "episode1.mp3", "file": "<base64>"}' \
  "$BASE/station/1/podcast/{podcast_id}/episode/{episode_id}/media"

# Delete episode media
curl -s -X DELETE -H "X-API-Key: $LYSN_API_KEY" "$BASE/station/1/podcast/{podcast_id}/episode/{episode_id}/media"

# Upload episode artwork
curl -s -X POST -H "X-API-Key: $LYSN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"path": "cover.jpg", "file": "<base64>"}' \
  "$BASE/station/1/podcast/{podcast_id}/episode/{episode_id}/art"
```

## Public Podcast Feeds (no auth)

```bash
# List public podcasts
curl -s "$BASE/station/1/public/podcasts"

# Get a public podcast
curl -s "$BASE/station/1/public/podcast/{podcast_id}"

# List public episodes
curl -s "$BASE/station/1/public/podcast/{podcast_id}/episodes"

# Get a public episode
curl -s "$BASE/station/1/public/podcast/{podcast_id}/episode/{episode_id}"
```

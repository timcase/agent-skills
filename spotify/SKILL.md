---
name: spotify
description: "Work with the Spotify Web API: search catalog, manage playlists/library, control playback, read user/artist/album/track data. Use for 'Spotify API', playlist automation, playback control, or any spotify.com/api integration task."
---

# Spotify Web API

REST + JSON API at `https://api.spotify.com/v1`. OpenAPI spec (source of truth for
request/response shapes and current endpoint status):
`https://developer.spotify.com/reference/web-api/open-api-schema.yaml`.

## Auth

Every request needs `Authorization: Bearer <token>`. Two token flows — pick based on
whose data you're touching:

- **Client Credentials** — app-only token, no user context. Only works for public
  catalog data (search, tracks, albums, artists). Cannot touch playback, library, or
  anything user-specific.
- **Authorization Code (with PKCE for no-backend apps)** — required for anything tied
  to a user: playback control, saved library, playlists owned/followed by the user,
  "Get Current User's Profile". Produces an access token + refresh token.

Never use the Implicit Grant flow (deprecated). Client secrets never go in client-side
code. See `references/auth.md` for the exact token-request curl commands, scope list,
and refresh flow.

## Making requests

```bash
curl -s -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  "https://api.spotify.com/v1/me"
```

- Market/locale-sensitive endpoints often need `?market=US` (or the user's market) to
  return playable results.
- IDs, URIs, URLs are interchangeable in most SDKs but the raw API wants the bare ID in
  the path and `spotify:track:<id>` URIs in bodies (e.g. queueing, adding to playlist) —
  check the specific endpoint.

## Rate limiting

A 429 response includes a `Retry-After` header (seconds). Back off for that long, then
retry — never retry immediately or in a tight loop. Limits are rolling per-app windows,
not documented as fixed numbers.

## Restricted endpoints — check before relying on these

As of Nov 27, 2024, new Spotify apps (registered after that date, or existing apps
still in Development Mode without an approved extension request) **cannot** use:
Related Artists, Recommendations, Audio Features, Audio Analysis, Get Featured
Playlists, Get Category's Playlists, 30-second preview URLs, and algorithmic/editorial
playlists. Apps with pre-existing Extended Quota Mode access are unaffected. If a task
needs one of these, confirm the app's access mode first rather than assuming the
endpoint works — a 403 here usually means this restriction, not a scope problem.

## Reference files

Load the file for the domain you're working in:

| Area | File |
|---|---|
| Token flows, scopes, refresh | `references/auth.md` |
| Search, tracks, albums, artists, audio features | `references/catalog.md` |
| Playlists, saved library, following | `references/library-playlists.md` |
| Playback state and control, devices, queue | `references/player.md` |

## Workflow

1. Determine whether the task needs a user token or works with client-credentials.
2. Get/refresh a token (`references/auth.md`).
3. Read the relevant reference file for exact endpoints and request bodies.
4. For anything not covered in the reference files, or to confirm a request/response
   shape, check the OpenAPI schema URL above rather than guessing.

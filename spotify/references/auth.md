# Auth

Register an app at https://developer.spotify.com/dashboard to get `SPOTIFY_CLIENT_ID`
and `SPOTIFY_CLIENT_SECRET`. Redirect URIs must be HTTPS (or `http://127.0.0.1`, never
`http://localhost`, never a wildcard).

## Client Credentials flow (app-only, no user context)

Public catalog data only — search, tracks, albums, artists. No playback, no library,
no user profile.

```bash
curl -s -X POST "https://accounts.spotify.com/api/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d grant_type=client_credentials \
  -d client_id="$SPOTIFY_CLIENT_ID" \
  -d client_secret="$SPOTIFY_CLIENT_SECRET" \
  | python3 -m json.tool
```

Returns `access_token` (expires in ~3600s, `token_type: Bearer`). No refresh token —
just request a new one when it expires.

## Authorization Code flow (user context)

1. **Redirect the user to authorize:**

```
https://accounts.spotify.com/authorize?
  client_id=$SPOTIFY_CLIENT_ID
  &response_type=code
  &redirect_uri=$REDIRECT_URI
  &scope=user-read-private%20user-read-email
  &state=$RANDOM_STATE
```

Add `code_challenge_method=S256&code_challenge=$CHALLENGE` for PKCE (required for apps
without a secure backend — mobile, SPA, CLI). Generate `code_challenge` as
base64url(SHA256(code_verifier)); send `code_verifier` in the token exchange below
instead of `client_secret`.

2. **Exchange the code for tokens** (confidential/backend app):

```bash
curl -s -X POST "https://accounts.spotify.com/api/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d grant_type=authorization_code \
  -d code="$AUTH_CODE" \
  -d redirect_uri="$REDIRECT_URI" \
  -d client_id="$SPOTIFY_CLIENT_ID" \
  -d client_secret="$SPOTIFY_CLIENT_SECRET" \
  | python3 -m json.tool
```

Returns `access_token`, `refresh_token`, `expires_in` (~3600s), and granted `scope`.

3. **Refresh when the access token expires:**

```bash
curl -s -X POST "https://accounts.spotify.com/api/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d grant_type=refresh_token \
  -d refresh_token="$SPOTIFY_REFRESH_TOKEN" \
  -d client_id="$SPOTIFY_CLIENT_ID" \
  -d client_secret="$SPOTIFY_CLIENT_SECRET" \
  | python3 -m json.tool
```

A new `refresh_token` may or may not be returned — if it is, replace the stored one. If
a refresh fails with `invalid_grant`, the user must reauthorize from step 1.

## Scopes

Request only what the feature needs — extra scopes get flagged in app review and
missing scopes cause 403s at call time, not at auth time. Common ones:

| Scope | Grants |
|---|---|
| `user-read-private`, `user-read-email` | Profile info |
| `user-read-playback-state`, `user-modify-playback-state`, `user-read-currently-playing` | Player read/control |
| `playlist-read-private`, `playlist-read-collaborative` | Read private/collab playlists |
| `playlist-modify-public`, `playlist-modify-private` | Create/edit playlists |
| `user-library-read`, `user-library-modify` | Saved tracks/albums |
| `user-follow-read`, `user-follow-modify` | Followed artists/users |
| `user-top-read` | Top artists/tracks |
| `user-read-recently-played` | Recently played |
| `streaming` | Web Playback SDK (requires Premium) |

Full list: https://developer.spotify.com/documentation/web-api/concepts/scopes

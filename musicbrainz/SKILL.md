---
name: musicbrainz
description: "Query the MusicBrainz WS/2 API: search artists/releases/recordings, look up MBIDs, browse discographies, resolve ISRC/ISWC/disc IDs/URLs, read relationships, submit tags/ratings. Use for 'MusicBrainz', MBID, or music metadata tasks."
---

# MusicBrainz API (WS/2)

REST API at `https://musicbrainz.org/ws/2/`. No API key. XML by default;
always add `fmt=json` for reads. Writes are XML-only (see below).

## Hard rules

- **One request per second per IP, max.** Exceeding it gets 503s for
  *all* requests and risks an IP ban. Never parallelize requests.
- **Meaningful User-Agent required**:
  `AppName/1.0 ( contact-url-or-email )`. Generic agents
  (python-urllib, curl defaults, blank) are throttled hardest. Use
  `gk-music-tools/1.0 ( gk@karmacrash.com )` for any raw curl calls.
- On 503, back off (seconds, increasing) and retry. Don't poll for
  changes — data rarely changes.
- Non-commercial use is free; commercial use needs a MetaBrainz plan.

## Helper script

`scripts/mb.py` (stdlib Python) enforces the rate limit across
invocations, retries 503s, and pages browses. It sends the User-Agent
above (override with `MB_USER_AGENT`).

```bash
mb.py search artist 'artist:"Autechre"' --limit 5
mb.py lookup release <mbid> --inc recordings+artist-credits+labels
mb.py browse release-group --by artist <mbid> --type 'album|ep' --all
mb.py get isrc/GBAYE0601498 inc=artist-credits
```

Pipe to `jq` to trim output; lookups with many incs are large.

## Request types

Every entity (area, artist, event, genre, instrument, label, place,
recording, release, release-group, series, work, url) supports:

```
lookup: /<entity>/<mbid>?inc=<a+b>
browse: /<entity>?<linked-entity>=<mbid>&limit=&offset=&inc=
search: /<entity>?query=<lucene>&limit=&offset=
```

(Genre has no browse/search; use `/genre/all`.)

- **Search** is the only way from a name to an MBID. Search first, pick
  by score + disambiguation, then lookup/browse with the MBID.
- **Lookup** returns one entity. `inc=` adds linked entities, but linked
  lists are **capped at 25** — use browse for complete lists.
- **Browse** lists entities directly linked to an MBID, paged (limit
  ≤100). Release pages hold ≤500 tracks total: advance `offset` by
  items received, not by `limit`.
- **Non-MBID lookups**: `/isrc/<isrc>`, `/iswc/<iswc>`,
  `/discid/<id>?toc=`, `/url?resource=<url>` — return lists.

## Data model essentials

- **Release group** = the abstract album; **release** = a specific
  edition (country, date, label, barcode); **medium** = disc; **track**
  = position on a medium; **recording** = the audio; **work** = the
  composition. Discography → release groups; tracklists, barcodes,
  labels → releases; songwriting → works.
- `artist-credit` is how names appear on a release/track (joinphrases
  like " feat. "); the linked `artist` is the canonical entity.
- `disambiguation` distinguishes same-named entities.
- Relationships (`inc=artist-rels`, `work-rels`, `url-rels`, ...) load
  only links to that *target* type; request each type needed. Track
  credits need `recording-level-rels`; composers need
  `work-rels+work-level-rels+artist-rels`.
- `inc=genres` for genres (not `genre-rels`). Genres are also in `tags`.

## Common recipes

- Discography: search artist →
  `browse release-group --by artist <id> --type album
  --release-group-status website-default --all`.
- Album tracklist: search release-group →
  `lookup release-group <id> --inc releases` → pick a release →
  `lookup release <id> --inc recordings+artist-credits+media`.
- External links (Spotify, Wikidata, homepage):
  `lookup artist <id> --inc url-rels`.
- Who played/wrote what on a release:
  `lookup release <id> --inc recordings+artist-rels+work-rels
  +recording-level-rels+work-level-rels`.
- Resolve a streaming/Discogs URL to an entity:
  `get url resource=<url> inc=artist-rels+release-rels`.

## Reference files

- `references/search.md` — Lucene syntax, searchable fields per entity.
- `references/lookup-browse.md` — all `inc=` values, relationships,
  browse matrix, type/status filters, discid/TOC, collections.
- `references/submitting.md` — tags, ratings, barcodes, ISRCs,
  collection edits, auth.

## Writes

Only tags/genres, ratings, barcodes, ISRCs, and collection membership
can be written. Writes need OAuth2 (or deprecated digest auth), XML
bodies, and `client=<app>-<version>` in the URL. They change a real
user's account or open public edits — confirm with the user first.

# Lookup, browse, and non-MBID lookups

## Contents
- Lookup `inc=` subqueries
- Modifier and misc `inc=` values
- Relationships (`*-rels`)
- Browse: linked entities, `inc=`, paging
- Type and status filters
- Non-MBID lookups: discid, isrc, iswc, url
- Collections (read)

## Lookup `inc=` subqueries

`GET /<entity>/<mbid>?inc=a+b`. Linked lists are capped at 25 items and
sorted by MBID — browse for complete lists.

- **artist**: recordings, releases, release-groups, works
- **collection**: user-collections (private; auth)
- **label**: releases
- **recording**: releases, release-groups
- **release**: collections, labels, recordings, release-groups
- **release-group**: releases
- **area, event, genre, instrument, place, series, work, url**: (none)

Lookups that include release-groups accept `type=`; those that include
releases accept `type=` and `status=`.

## Modifier and misc `inc=` values

Modifiers (apply to included linked entities):
- `discids` — disc IDs for all media in releases
- `media` — media per release (track count, format)
- `isrcs` — ISRCs for recordings
- `artist-credits` — artist credits for releases/recordings
- `various-artists` — only with `artist?inc=releases`: releases where the
  artist appears on a track but not in the release credit

Misc:
- `aliases` — unordered set
- `annotation`
- `tags`, `ratings`; `user-tags`, `user-ratings` (auth)
- `genres`, `user-genres` (auth). Genres are also in `tags`.

Get a full tracklist with credits:
`release/<mbid>?inc=recordings+artist-credits+isrcs+labels`.

## Relationships

`area-rels artist-rels event-rels genre-rels instrument-rels label-rels
place-rels recording-rels release-rels release-group-rels series-rels
url-rels work-rels` — available on every entity except genre.

Each loads relationships to that *target type* only; `artist-rels` on an
artist gives artist↔artist links, not all relationships. Request every
target type you need.

Level switches (need the matching `*-rels` too):
- `recording-level-rels` — rels of recordings on a release
- `release-group-level-rels` — release only
- `work-level-rels` — rels of works linked to recordings

Example: who wrote each song on a release —
`release/<mbid>?inc=recordings+recording-level-rels+work-rels
+work-level-rels+artist-rels`.

JSON shape: `relations` array, each with `type`, `direction`,
`target-type`, the target object (keyed by target type, e.g. `artist`),
`attributes` (names), `attribute-values`, `attribute-ids`,
`attribute-credits` (e.g. "guitar" credited as "Fender Stratocaster").

`genre-rels` is not the entity's genres — use `inc=genres`.

## Browse

`GET /<result-entity>?<linked-entity>=<mbid>&limit=&offset=&inc=`.
Only directly linked entities (not via relationships). Order is fixed per
linked type; sort client-side if needed.

- **area**: collection
- **artist**: area, collection, recording, release, release-group, work
- **collection**: area, artist, editor, event, label, place, recording,
  release, release-group, work
- **event**: area, artist, collection, event, place
- **genre, instrument, series**: collection
- **label**: area, collection, release
- **place**: area, collection
- **recording**: artist, collection, release, work
- **release**: area, artist, collection, label, track, track_artist,
  recording, release-group
- **release-group**: artist, collection, release
- **work**: artist, collection

`release?track_artist=<mbid>` returns releases where the artist is on a
track credit but not the release credit (complements `artist=`).

### Browse `inc=`

- **area, artist, event, instrument, label, place, series, work**: aliases
- **recording**: artist-credits, isrcs
- **release**: artist-credits, labels, recordings, release-groups, media,
  discids, isrcs (with recordings)
- **release-group**: artist-credits
- **url**: relationship incs only

All entities also take `annotation tags user-tags genres user-genres`,
plus `*-rels`. All except area, place, release, series take
`ratings user-ratings`.

### Paging

- Only browse pages. `limit` default 25, max 100. Response carries
  `<entity>-count` and `<entity>-offset`.
- **Releases**: each page is capped at 500 total tracks (at least one
  full release is always returned), so pages may be shorter than `limit`.
  Advance `offset` by the number of items received, not by `limit`.

## Type and status filters

Usable on browse and on lookups including releases/release-groups.
Combine values with `|`.

- `status`: official, promotion, bootleg, pseudo-release, withdrawn,
  cancelled (releases only)
- `type` primary: album, single, ep, broadcast, other
- `type` secondary: audio drama, audiobook, compilation, demo, dj-mix,
  field recording, interview, live, mixtape/street, remix, soundtrack,
  spokenword
- `release-group-status=website-default|all` — only on
  `release-group?artist=`; `website-default` hides groups containing only
  promo/bootleg/pseudo releases (matches the website's overview).

Examples:
- `release?artist=<mbid>&status=bootleg&type=live`
- `release-group?artist=<mbid>&type=album|ep`

## Non-MBID lookups

Return lists (clashes possible), unpaged, all matches.

- `discid/<discid>?inc=` — releases; same incs as release lookup.
  Returns a CD stub (`cdstub`, artists only, no credits) if no release
  matches; `cdstubs=no` suppresses. `toc=` enables fuzzy TOC matching
  when the disc ID is unknown (skipped if a CD stub is found). Use
  `discid/-?toc=...` for TOC-only search; `media-format=all` to match
  non-CD media. TOC format:
  `1+<track-count>+<leadout-offset>+<offset1>+<offset2>...`
  (sectors; track 1 usually starts at 150).
- `isrc/<isrc>?inc=` — recordings; recording incs.
- `iswc/<iswc>?inc=` — works; work incs.
- `url?resource=<url>` — URL entity by its text; URL-encode the value
  (double-encode if it already contains escapes or a query string).
  404 if unknown. Repeat `resource` up to 100 times to get a
  `url-list`; unknown ones are skipped. Add `inc=artist-rels` etc. to
  find what the URL is attached to.

## Collections (read)

- `collection/<mbid>` — description
- `collection/<mbid>/releases` (or areas, artists, ...) — summary
- `release?collection=<mbid>` — contents (browse, paged)
- `collection?editor=<name>` — a user's public collections;
  add `inc=user-collections` (auth) for private ones
- `genre/all?limit=&offset=` — all genres; `fmt=txt` gives names only,
  newline-separated, unpaged

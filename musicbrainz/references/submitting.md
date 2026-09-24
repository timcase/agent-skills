# Submitting data (auth required)

Only tags/genres, ratings, barcodes, ISRCs, and collection membership can
be written via the API. Everything else goes through the website editor.

## Rules for every write

- Authenticate with OAuth2 (preferred;
  <https://musicbrainz.org/doc/Development/OAuth2>) or HTTP digest over
  HTTPS using a token from <https://musicbrainz.org/account/applications>
  in place of the password. Digest auth is deprecated and removed
  August 2027 — use OAuth for anything new.
- XML only. `Content-Type: application/xml; charset=utf-8`.
- Add `client=<app>-<version>` to the **URL** (not body): the
  application's name and version, not a library's; version must not
  contain `-`. E.g. `client=example.app-0.4.7`.
- Root element: `<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">`.
  Validate against the Relax NG schema:
  <https://github.com/metabrainz/mmd-schema/blob/master/schema/musicbrainz_mmd-2.0.rng>
- These act on a real user's account or open public edits. Confirm with
  the user before sending.

## Tags and genres — `POST /ws/2/tag?client=...`

```xml
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <artist-list>
    <artist id="a16d1433-ba89-4f72-a47b-a370add0bb56">
      <user-tag-list>
        <user-tag vote="upvote"><name>jpop</name></user-tag>
        <user-tag vote="downvote"><name>pop</name></user-tag>
        <user-tag vote="withdraw"><name>rock</name></user-tag>
      </user-tag-list>
    </artist>
  </artist-list>
  <recording-list>...</recording-list>
</metadata>
```

**Always set `vote`.** Without any `vote` attribute the submitted list
*replaces* all of the user's upvoted tags on that entity (unlisted
upvotes are withdrawn; downvotes kept). `withdraw` removes a prior vote.

## Ratings — `POST /ws/2/rating?client=...`

```xml
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <artist-list>
    <artist id="455641ea-fff4-49f6-8fb4-49f961d8f1ad">
      <user-rating>100</user-rating>
    </artist>
  </artist-list>
</metadata>
```

Scale 0–100 (20 per star). Not supported for area, place, release,
series.

## Barcodes — `POST /ws/2/release/?client=...`

```xml
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <release-list>
    <release id="047ea202-b98d-46ae-97f7-0180a20ee5cf">
      <barcode>4050538793819</barcode>
    </release>
  </release-list>
</metadata>
```

GTIN (EAN/UPC) only; bad checksums and 2/5-digit add-ons are rejected.
Creates one edit in the queue — not applied immediately.

## ISRCs — `POST /ws/2/recording/?client=...`

```xml
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <recording-list>
    <recording id="b9991644-7275-44db-bc43-fff6c6b4ce69">
      <isrc-list count="1"><isrc id="JPB600601201"/></isrc-list>
    </recording>
  </recording-list>
</metadata>
```

## Collections

```
PUT    /ws/2/collection/<coll>/releases/<mbid>;<mbid>?client=...
DELETE /ws/2/collection/<coll>/releases/<mbid>?client=...
```

Swap `releases` for areas, artists, events, labels, places, recordings,
release-groups, or works to match the collection type. Up to ~400 MBIDs
per request, `;`-separated (16 KB URI limit).

## curl sketch (digest)

```bash
curl --digest -u "$MB_USER:$MB_TOKEN" \
  -H 'Content-Type: application/xml; charset=utf-8' \
  -H 'User-Agent: gk-music-tools/1.0 ( gk@karmacrash.com )' \
  --data-binary @tags.xml \
  'https://musicbrainz.org/ws/2/tag?client=myapp-1.0'
```

With OAuth, replace `--digest -u` with
`-H "Authorization: Bearer $MB_OAUTH_TOKEN"`.

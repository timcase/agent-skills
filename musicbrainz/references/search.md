# Search

`GET /<entity>?query=<lucene>&limit=&offset=&fmt=json`

- `limit` 1–100 (default 25), `offset` for paging.
- Response: `count` (total), `offset`, list keyed by plural entity, each
  item has `score` (0–100).
- Lucene syntax: `field:value`, quoted phrases, `AND`/`OR`/`NOT`,
  parentheses, `*` wildcards, `~` fuzzy, ranges `date:[1990 TO 1999]`.
  Escape `+ - && || ! ( ) { } [ ] ^ " ~ * ? : \ /` inside terms.
- Unfielded terms search the entity's default field(s), usually name/alias.
- `dismax=true` switches to a simple parser: plain text only, no Lucene
  operators — good for raw user input.
- `*accent` fields match diacritics exactly; plain fields are
  accent-insensitive.

Search is the only way from a name to an MBID. Pick by score, then verify
with disambiguation (`disambiguation` / `comment`), country, dates, or
type. Never assume the top hit is right when scores are close.

## Fields by entity

- **annotation**: entity, id, name, text, type
- **area**: aid, alias, area, areaaccent, begin, comment, end, ended, iso,
  iso1, iso2, iso3, sortname, tag, type
- **artist**: alias, primary_alias, area, arid, artist, artistaccent, begin,
  beginarea, comment, country, end, endarea, ended, gender, ipi, isni,
  sortname, tag, type
- **cdstub**: added, artist, barcode, comment, discid, title, tracks
- **event**: alias, aid, area, arid, artist, begin, comment, end, ended, eid,
  event, eventaccent, pid, place, tag, type
- **instrument**: alias, comment, description, iid, instrument,
  instrumentaccent, tag, type
- **label**: alias, area, begin, code, comment, country, end, ended, ipi,
  isni, label, labelaccent, laid, release_count, sortname, tag, type
- **place**: address, alias, area, begin, comment, end, ended, lat, long,
  place, placeaccent, pid, type
- **recording**: alias, arid, artist, artistname, comment, country,
  creditname, date, dur, firstreleasedate, format, isrc, number, position,
  primarytype, qdur, recording, recordingaccent, reid, release, rgid, rid,
  secondarytype, status, tag, tid, tnum, tracks, tracksrelease, type, video
- **release**: alias, arid, artist, artistname, asin, barcode, catno, comment,
  country, creditname, date, discids, discidsmedium, format, laid, label,
  lang, mediumid, mediums, packaging, primarytype, quality, release,
  releasegroup, releasegroupaccent, releases, rgid, rid, status, tag, type
- **release-group**: alias, arid, artist, artistname, comment, creditname,
  firstreleasedate, primarytype, reid, release, releasegroup,
  releasegroupaccent, releases, rgid, secondarytype, status, tag, type
- **series**: alias, comment, series, seriesaccent, sid, tag, type
- **tag**: tag
- **url**: url, resource
- **work**: alias, arid, artist, comment, iswc, lang, primarytype,
  secondarytype, tag, type, work, workaccent, wid

Field notes: `arid`/`reid`/`rgid`/`rid`/`wid`/`laid`/`aid`/`pid`/`eid`
are MBIDs of artist/release/release-group/recording/work/label/area/
place/event. `artist` matches the combined credit string, `artistname`
the individual artist names, `creditname` the as-credited names. `dur`
is milliseconds; `qdur` is quantized duration (dur/2000) for fuzzy
length matches. `tnum` is track number, `number` the free-text track
number. `country` is ISO 3166-1 alpha-2.

## Examples

```
artist?query=artist:"Nine Inch Nails" AND type:group
release-group?query=releasegroup:"Year Zero" AND arid:<artist-mbid>
recording?query=recording:"Hurt" AND artist:"Johnny Cash"
    AND primarytype:album AND status:official
recording?query=isrc:USIR20400274
release?query=barcode:0602498646539
release?query=catno:"WARPCD111" AND label:Warp
work?query=iswc:T-010.475.727-8
label?query=label:ubiktune
```

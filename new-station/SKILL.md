---
name: new-station
description: Create a new lysn.bar radio station web player (PWA on
  Vercel at <name>.lysn.bar) from an existing AzuraCast station, using the
  shared core. Use when the user wants to add, launch or scaffold a new
  station site.
---

# New station

The stations live in the lysn repo at `~/Sites/lysn`; run every command
below from there. Each station is a folder (`<shortcode>/`) holding
config, markup, a theme and icons. Behavior lives in `core/`. Read the
root `CLAUDE.md` first.
Hard Bop 24 and EclecticFM are the reference stations, and
`docs/superpowers/plans/2026-10-02-eclecticfm.md` is the worked example
with exact commands.

Work through these in order. Steps marked **(user)** wait for the user.

1. **Inputs.** Get the AzuraCast shortcode, the display name, the
   subdomain (default `<shortcode>.lysn.bar`), and the station's music
   description file (for example `eclecticfm/EclecticFM.md`). Check that
   the station exists and note its id:
   `curl -s https://radio.lysn.bar/api/stations`.
2. **Mounts.** Every station streams Opus 128 at `/radio.opus` (the
   default mount) and MP3 320 at `/radio.mp3`. Use the azuracast skill
   with `$LYSN_API_KEY`.
   - Read the mounts: `GET /api/station/<id>/mounts`.
   - MP3: set `autodj_bitrate` to 320 on `/radio.mp3`.
   - Opus: register `/radio.opus` with **AutoDJ off**, then run
     `core/apply-opus-nometa <id> "<Name>"`. That installs the
     metadata-free Opus output; `core/liquidsoap/opus-nometa.liq`
     explains why tagged Opus breaks players. Never print the source
     password or save it to a file.
   - **(user)** Confirm, then restart the station once with
     `POST /api/station/<id>/restart`. It interrupts listeners.
   - Check that both streams return 200: Opus as `application/ogg` with
     no `title=` in `ffprobe -show_entries format_tags`, MP3 with
     `icy-br: 320`.
3. **Scaffold.** Run `node core/new-station.mjs <shortcode> "<Name>"`.
   It refuses a station that lacks either mount.
4. **Look and feel.** **(user)** Use superpowers:brainstorming with the
   visual companion. Show 3 distinct directions drawn from the music
   description, using the station's real now-playing art. Then show a
   full-page mockup of the chosen one. Check every text color pair
   against WCAG AA.
5. **Icons.** **(user)** Give Noun Project search terms that fit the
   station, and the palette as hex values without `#`. Wait for the user
   to save a Noun Project SVG (plain or coloured, any background shape)
   under `<shortcode>/assets/appicon/noun_project/`. Then make the five
   source files with `appicon` (`~/bin/appicon`, no external sites):
   `appicon <glyph.svg> <shortcode> --fg <hex> --bg <hex>
   --out <shortcode>/assets/appicon`, and show the user the contact sheet
   it prints (`/tmp/appicon-<shortcode>.png`). Then run
   `core/make-icons <shortcode> '<icon bg hex>'` and look at the maskable
   PNG: the art must sit inside the central 80% circle.
6. **Placeholder art.** **(user)** The sleeve for tracks with no cover,
   served by AzuraCast and used by the player when a cover fails to load
   (`STATION.fallbackArt`). Run
   `core/make-placeholder <shortcode> '<icon bg hex>'`. It draws the icon
   art on that colour, unless the user has saved a designed image as
   `assets/placeholder.{png,jpg,jpeg,webp}`. Show the user
   `src/icons/<shortcode>-placeholder.jpg`; once they approve it, run
   `core/set-default-art <shortcode>`, which uploads it as the station's
   Default Album Art and checks that it took. Re-run both after any
   change to the icon or the supplied image.
7. **Theme.** Write `src/player.css`, and fonts in `src/fonts/` if used
   (self-hosted, `font-display: optional`).
   - Base the house sleeve on the icon art, as a CSS data URI.
   - Set `theme-color` and the manifest colors.
   - Keep the history rows fixed-height, with the list's `min-height`
     reserved, so nothing shifts when history loads.
   - Never add `player.js` or `sw.js` to `src/`; the build refuses it.
8. **Verify locally.** Run `core/serve <shortcode>` and repeat Task 4
   Step 9 of the plan above: no console errors, playback, the forced Opus
   404 falling back to MP3, copy buttons, manifest, offline shell,
   reduced motion. The extension-driven Chrome cannot play media; drive
   headless Chrome over CDP with `--autoplay-policy=no-user-gesture-required`
   instead. Run `node --test core/test/`.
9. **Commit** the station folder.
10. **Vercel.** Create the project and domain as in Task 7 of the plan:
    Root Directory `<shortcode>`, Git `timcase/lysn`, domain
    `<subdomain>`.
11. **DNS.** Create a Cloudflare A record `<subdomain>` pointing to
    `76.76.21.21`, `proxied: false`, `ttl: 1` (cloudflare skill).
12. **Deploy.** **(user)** Confirm, then push `main`. Check that the
    domain serves the station.
13. **Lighthouse.** Run mobile Lighthouse on the new domain and compare
    it with Hard Bop 24's scores. LCP is the cover art, so check that
    `fetchpriority` and `preconnect` are intact if LCP regresses.
14. **(user)** Ask the user to check iOS on a device: play, switch to
    another audio app, return. Playback should resume within about 2
    seconds.

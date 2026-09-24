#!/usr/bin/env python3
"""Rate-limited MusicBrainz WS/2 client (JSON, read-only).

Usage:
  mb.py search <entity> <lucene-query> [--limit N] [--offset N]
  mb.py lookup <entity> <mbid> [--inc a+b]
  mb.py browse <entity> --by <linked-entity> <mbid> [--inc a+b]
               [--type T] [--status S] [--limit N] [--offset N] [--all]
  mb.py get <path> [key=value ...]     # e.g. get isrc/USRC17607839

Output is JSON on stdout. MB_USER_AGENT overrides the built-in
User-Agent. Requests are spaced at least 1.1s
apart across invocations (via a timestamp file) and 503s are retried with
backoff.
"""

import argparse
import json
import os
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request

BASE = os.environ.get("MB_BASE_URL", "https://musicbrainz.org/ws/2/")
UA = os.environ.get("MB_USER_AGENT",
                    "gk-music-tools/1.0 ( gk@karmacrash.com )")
MIN_INTERVAL = 1.1
STAMP = os.path.join(tempfile.gettempdir(), "mb_skill_last_request")

# Keys holding the result list in browse responses, per entity.
LIST_KEYS = {
    "area": "areas", "artist": "artists", "collection": "collections",
    "event": "events", "genre": "genres", "instrument": "instruments",
    "label": "labels", "place": "places", "recording": "recordings",
    "release": "releases", "release-group": "release-groups",
    "series": "series", "work": "works",
}


def throttle():
    try:
        wait = MIN_INTERVAL - (time.time() - os.path.getmtime(STAMP))
        if wait > 0:
            time.sleep(wait)
    except OSError:
        pass
    with open(STAMP, "w"):
        pass


def request(path, params):
    params = {k: v for k, v in params.items() if v not in (None, "")}
    params["fmt"] = "json"
    url = BASE + path.lstrip("/") + "?" + urllib.parse.urlencode(
        params, safe="+|")
    req = urllib.request.Request(
        url, headers={"User-Agent": UA, "Accept": "application/json"})
    for attempt in range(5):
        throttle()
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                return json.load(resp)
        except urllib.error.HTTPError as e:
            if e.code == 503 and attempt < 4:
                time.sleep(2 ** attempt * 2)
                continue
            body = e.read().decode("utf-8", "replace")
            sys.exit(f"HTTP {e.code} for {url}\n{body}")
    sys.exit(f"giving up on {url}")


def browse_all(entity, params):
    """Page through a browse. Advance offset by items actually returned
    (release pages are capped at 500 tracks, so may be short)."""
    key = LIST_KEYS.get(entity, entity + "s")
    params = dict(params, limit=100, offset=int(params.get("offset") or 0))
    items, total = [], None
    while True:
        data = request(entity, params)
        page = data.get(key, [])
        total = data.get(f"{entity}-count", total)
        items.extend(page)
        params["offset"] += len(page)
        if not page or (total is not None and params["offset"] >= total):
            break
        print(f"fetched {params['offset']}/{total}", file=sys.stderr)
    return {f"{entity}-count": total, key: items}


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawTextHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("search")
    s.add_argument("entity")
    s.add_argument("query")
    s.add_argument("--limit", type=int)
    s.add_argument("--offset", type=int)
    s.add_argument("--dismax", action="store_true")

    lk = sub.add_parser("lookup")
    lk.add_argument("entity")
    lk.add_argument("mbid")
    lk.add_argument("--inc")
    lk.add_argument("--type")
    lk.add_argument("--status")

    b = sub.add_parser("browse")
    b.add_argument("entity")
    b.add_argument("--by", nargs=2, metavar=("LINKED", "MBID"),
                   required=True)
    b.add_argument("--inc")
    b.add_argument("--type")
    b.add_argument("--status")
    b.add_argument("--release-group-status")
    b.add_argument("--limit", type=int)
    b.add_argument("--offset", type=int)
    b.add_argument("--all", action="store_true",
                   help="fetch every page")

    g = sub.add_parser("get")
    g.add_argument("path")
    g.add_argument("params", nargs="*", metavar="key=value")

    a = p.parse_args()
    if a.cmd == "search":
        out = request(a.entity, {"query": a.query, "limit": a.limit,
                                 "offset": a.offset,
                                 "dismax": "true" if a.dismax else None})
    elif a.cmd == "lookup":
        out = request(f"{a.entity}/{a.mbid}",
                      {"inc": a.inc, "type": a.type, "status": a.status})
    elif a.cmd == "browse":
        params = {a.by[0]: a.by[1], "inc": a.inc, "type": a.type,
                  "status": a.status, "limit": a.limit, "offset": a.offset,
                  "release-group-status": a.release_group_status}
        out = (browse_all(a.entity, params) if a.all
               else request(a.entity, params))
    else:
        out = request(a.path, dict(kv.split("=", 1) for kv in a.params))
    json.dump(out, sys.stdout, indent=2, ensure_ascii=False)
    print()


if __name__ == "__main__":
    main()

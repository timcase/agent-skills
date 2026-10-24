#!/usr/bin/env python3
"""WingTask REST API client (stdlib only).

Usage:
  wt.py get <path> [key=value ...] [--all]
  wt.py post <path> [JSON | -] [--all]     # --all: /tasks/query only
  wt.py patch <path> <JSON | ->
  wt.py delete <path>

Paths are relative to the API base, e.g. /tasks or /lists/<id>/tasks.
Reads the token from WT_TOKEN; WT_BASE_URL overrides the base URL.
Prints the JSON response on stdout. With --all, follows
pagination.next_cursor and prints {"data": [...every item...]}.

Errors print HTTP status, error.code, error.message, error.details
and X-Request-Id on stderr, then exit 1. 429s and retryable 409s wait
for Retry-After and back off exponentially; 503s on safe requests are
retried the same way. When X-RateLimit-Remaining reaches 0, the next
request waits for X-RateLimit-Reset. -v logs every X-Request-Id.
"""

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid as uuidlib

BASE = os.environ.get("WT_BASE_URL",
                      "https://app.wingtask.com/api/v1").rstrip("/")
MAX_ATTEMPTS = 5
# 409 codes that mean "nothing happened, try again shortly".
RETRY_409 = {"mutation_in_progress", "annotation_timestamp_conflict"}

VERBOSE = False
_reset_at = 0.0  # epoch seconds to wait for once the window is spent


class ApiError(Exception):
    def __init__(self, status, code, message, details, request_id,
                 headers):
        super().__init__(f"{status} {code}")
        self.status, self.code, self.message = status, code, message
        self.details, self.request_id = details, request_id
        self.headers = headers

    def report(self):
        lines = [f"HTTP {self.status} {self.code}: {self.message}"]
        for field, problems in (self.details or {}).items():
            lines.append(f"  {field}: {'; '.join(problems)}")
        if self.headers.get("Location"):
            lines.append(f"  Location: {self.headers['Location']}")
        lines.append(f"X-Request-Id: {self.request_id or '-'}")
        return "\n".join(lines)


def log(msg):
    if VERBOSE:
        print(msg, file=sys.stderr)


def token():
    tok = os.environ.get("WT_TOKEN", "").strip()
    if not tok:
        sys.exit("WT_TOKEN is not set. Create a token in WingTask under "
                 "Settings > API Tokens and export it as WT_TOKEN.")
    return tok


def note_rate_limit(headers):
    global _reset_at
    remaining = headers.get("X-RateLimit-Remaining")
    reset = headers.get("X-RateLimit-Reset")
    if remaining is not None and reset and int(remaining) <= 0:
        _reset_at = float(reset)


def wait_for_window():
    delay = _reset_at - time.time()
    if delay > 0:
        log(f"rate limit window spent; waiting {delay:.0f}s")
        time.sleep(delay + 0.5)


def retry_delay(headers, attempt):
    try:
        base = max(1.0, float(headers.get("Retry-After") or 1))
    except ValueError:
        base = 1.0
    return base * (2 ** attempt)


def send_once(method, url, body):
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {token()}")
    req.add_header("Accept", "application/json")
    if data is not None:
        req.add_header("Content-Type", "application/json")
    wait_for_window()
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            headers = resp.headers
            raw = resp.read()
            status = resp.status
    except urllib.error.HTTPError as e:
        headers, raw, status = e.headers, e.read(), e.code
    note_rate_limit(headers)
    rid = headers.get("X-Request-Id")
    log(f"{method} {url} -> {status} (X-Request-Id: {rid})")
    payload = None
    if raw:
        try:
            payload = json.loads(raw)
        except ValueError:
            payload = {"raw": raw.decode("utf-8", "replace")}
    if status >= 400:
        err = (payload or {}).get("error") or {}
        raise ApiError(status, err.get("code", "unknown"),
                       err.get("message", raw.decode("utf-8", "replace")),
                       err.get("details"), rid, headers)
    return payload, headers


def request(method, path, params=None, body=None, safe=False):
    """Send a request, retrying only where a retry cannot double-apply.

    safe: the request has no side effects, or repeating it is harmless.
    """
    url = BASE + "/" + path.lstrip("/")
    if params:
        url += "?" + urllib.parse.urlencode(params)
    for attempt in range(MAX_ATTEMPTS):
        try:
            return send_once(method, url, body)
        except ApiError as e:
            if attempt and e.code == "task_already_exists":
                # An earlier attempt of this create landed; return it.
                loc = e.headers.get("Location", "").rstrip("/")
                return request("GET", "/tasks/" + loc.rsplit("/", 1)[-1],
                               safe=True)
            retryable = (
                e.status == 429
                or (e.status == 409 and e.code in RETRY_409)
                or (e.status == 503 and safe))
            if not retryable or attempt == MAX_ATTEMPTS - 1:
                raise
            delay = retry_delay(e.headers, attempt)
            log(f"{e.status} {e.code}; retrying in {delay:.0f}s")
            time.sleep(delay)


def fetch_all(method, path, params, body):
    """Follow cursors with the request otherwise unchanged. Restart from
    the first page once if the cursor or search snapshot expires."""
    for restart in range(2):
        items, cursor = [], None
        try:
            while True:
                if method == "GET":
                    p = dict(params, **({"cursor": cursor} if cursor
                                        else {}))
                    page, _ = request("GET", path, p, safe=True)
                else:
                    b = dict(body, **({"cursor": cursor} if cursor
                                      else {}))
                    page, _ = request("POST", path, body=b, safe=True)
                items.extend(page.get("data") or [])
                pag = page.get("pagination") or {}
                if not pag.get("has_more"):
                    return {"data": items}
                cursor = pag["next_cursor"]
        except ApiError as e:
            if e.status != 410 or restart:
                raise
            log(f"410 {e.code}; restarting from the first page")


def read_body(arg):
    if arg is None:
        return None
    text = sys.stdin.read() if arg == "-" else arg
    try:
        return json.loads(text)
    except ValueError as e:
        sys.exit(f"invalid JSON body: {e}")


def main():
    global VERBOSE
    ap = argparse.ArgumentParser(
        description="WingTask REST API client",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__)
    ap.add_argument("method", choices=["get", "post", "patch", "delete"])
    ap.add_argument("path")
    ap.add_argument("args", nargs="*",
                    help="get: key=value params; post/patch: JSON or -")
    ap.add_argument("--all", action="store_true",
                    help="follow pagination and merge every page")
    ap.add_argument("-v", "--verbose", action="store_true",
                    help="log each request and its X-Request-Id")
    a = ap.parse_args()
    VERBOSE = a.verbose
    method = a.method.upper()
    path = "/" + a.path.lstrip("/")

    params, body = {}, None
    if method == "GET":
        for kv in a.args:
            if "=" not in kv:
                sys.exit(f"expected key=value, got {kv!r}")
            k, v = kv.split("=", 1)
            params[k] = v
    else:
        if len(a.args) > 1:
            sys.exit("pass the JSON body as a single argument")
        body = read_body(a.args[0] if a.args else None)
        if method == "PATCH" and body is None:
            sys.exit("PATCH needs a JSON body")
        if method == "POST" and body is None:
            body = {}
    create = method == "POST" and path.rstrip("/") == "/tasks"
    if create and isinstance(body, dict) and "uuid" not in body:
        # A client-generated UUID makes the create safe to retry.
        body["uuid"] = str(uuidlib.uuid4())

    query = method == "POST" and path.rstrip("/") == "/tasks/query"
    if a.all and not (method == "GET" or query):
        sys.exit("--all works with GET and POST /tasks/query only")

    try:
        if a.all:
            out = fetch_all(method, path, params, body)
        else:
            out, _ = request(method, path, params, body,
                             safe=method == "GET" or query or create)
    except ApiError as e:
        sys.exit(e.report())
    if out is not None:
        json.dump(out, sys.stdout, indent=2)
        print()


if __name__ == "__main__":
    main()

# Building an app on the WingTask API

Use this file when writing application code, not when calling the API
for the user with `scripts/wt.py`. `scripts/wt.py` is a working Python
reference for the same behavior: retries, pagination, and errors.

## Checklist

- Base URL `https://app.wingtask.com/api/v1`. Load the token
  server-side from env or a secret store. Never ship it to a browser
  or mobile bundle, log it, or commit it. If a browser UI is needed,
  proxy through a backend.
- Use a read-only token unless the app writes. Treat 403 `forbidden`
  as "this token cannot write", not as a retryable error.
- Wrap every call in one client function that:
  - sends `Authorization: Bearer`, `Accept: application/json`, and
    `Content-Type: application/json` when there is a body
  - parses `{ "error": { code, message, details? } }` into a typed
    error, logs `X-Request-Id`, and shows `message` to the user
  - waits for `X-RateLimit-Reset` (epoch seconds) when
    `X-RateLimit-Remaining` hits 0, shared across all callers that
    use the same token
  - on 429, waits for `Retry-After`, then backs off exponentially on
    later attempts, up to a cap
- Generate a `uuid` for every `POST /tasks` and reuse it on retry. A
  409 `task_already_exists` after a retry means the first attempt
  worked; follow its `Location` header.
- Paginate with an async iterator that freezes the request and only
  swaps `cursor`. On 410 `cursor_expired`, restart from page 1.
- Store and display timestamps as UTC. Convert to the user's
  `time_zone` from `GET /me` for display. When sending times, either
  include an offset or deliberately rely on the WingTask time zone.
- For date-only values, send local midnight (`2026-09-22T00:00:00`)
  with `<field>_precision: "date"`. Datetime precision at local
  midnight is rejected.
- Keep `meta.undo_operation_id` from mutations if the app offers undo.
  Pass it as `expected_operation_id` to `POST /undos`.

## Error codes to branch on

| HTTP | `error.code` | App behavior |
|---|---|---|
| 400 | `invalid_parameter` | bug: fix the request |
| 400 | `invalid_cursor` | request changed mid-crawl: restart paging |
| 401 | `unauthenticated` | token missing/revoked: ask user for a new one |
| 403 | `forbidden` | read-only token on a write: explain, don't retry |
| 404 | `record_not_found` | stale ID: refresh local state |
| 409 | `mutation_in_progress` | retry after `Retry-After` (2s) |
| 409 | `annotation_timestamp_conflict` | retry after `Retry-After` (1s) |
| 409 | `task_already_exists` | fetch `Location` (idempotent create) |
| 409 | `invalid_transition` | e.g. done on a done task: show message |
| 409 | `nothing_to_undo`, `undo_conflict` | show message, refresh undo list |
| 409 | `undo_diverged` | `details` maps task uuid to changed props |
| 410 | `cursor_expired` | restart pagination/search from page 1 |
| 413 | `request_too_large` | body > 1 MiB: split the work |
| 415 | `unsupported_media_type` | bug: send `application/json` |
| 422 | `validation_failed` | show `details` per field/path |
| 429 | `rate_limited` | `Retry-After`, then exponential backoff |
| 500 | `internal_error` | report with `X-Request-Id`; no blind retry |
| 503 | `service_unavailable` | retry reads/idempotent writes with backoff |

Re-check the spec's `components.responses` when adding handling, in
case codes have been added.

## TypeScript sketch

```ts
const BASE = "https://app.wingtask.com/api/v1";

export class WingTaskError extends Error {
  constructor(public status: number, public code: string,
              message: string, public requestId: string | null,
              public details?: Record<string, string[]>,
              public headers?: Headers) { super(message); }
}

let resetAt = 0; // share per token in multi-instance deployments
const sleep = (ms: number) => new Promise(r => setTimeout(r, ms));

export async function wt<T>(method: string, path: string,
                            body?: unknown, attempt = 0): Promise<T> {
  if (Date.now() < resetAt) await sleep(resetAt - Date.now());
  const res = await fetch(BASE + path, {
    method,
    headers: {
      Authorization: `Bearer ${process.env.WT_TOKEN}`,
      Accept: "application/json",
      ...(body === undefined
        ? {} : { "Content-Type": "application/json" }),
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const rid = res.headers.get("X-Request-Id");
  if (res.headers.get("X-RateLimit-Remaining") === "0") {
    resetAt = Number(res.headers.get("X-RateLimit-Reset")) * 1000;
  }
  if (res.status === 204) return undefined as T;
  const json = await res.json();
  if (res.ok) return json as T;

  const { code, message, details } = json.error;
  console.error(`WingTask ${res.status} ${code} request_id=${rid}`);
  const retryable = res.status === 429 ||
    code === "mutation_in_progress" ||
    code === "annotation_timestamp_conflict";
  if (retryable && attempt < 4) {
    const base = Number(res.headers.get("Retry-After") ?? 1);
    await sleep(base * 1000 * 2 ** attempt);
    return wt<T>(method, path, body, attempt + 1);
  }
  throw new WingTaskError(res.status, code, message, rid, details,
                          res.headers);
}

type Page<T> = {
  data: T[];
  pagination: { has_more: boolean; next_cursor: string | null };
};

// GET collections: freeze the query and only change the cursor.
export async function* pages<T>(path: string,
                                params: Record<string, string> = {}) {
  let cursor: string | null = null;
  do {
    const q = new URLSearchParams(
      cursor ? { ...params, cursor } : params);
    const page: Page<T> = await wt("GET", `${path}?${q}`);
    yield* page.data;
    cursor = page.pagination.has_more
      ? page.pagination.next_cursor : null;
  } while (cursor);
}
```

For `POST /tasks/query`, use the same loop with `cursor` in the JSON
body instead of the query string.

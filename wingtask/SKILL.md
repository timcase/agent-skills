---
name: wingtask
description: "Work with the WingTask REST API: query/create/update/complete tasks, annotations, saved lists, contexts, UDAs, projects, tags, search, undo. Use for 'WingTask', WT_TOKEN, or building apps on app.wingtask.com/api."
---

# WingTask REST API

WingTask is a hosted Taskwarrior service. The REST API is at
`https://app.wingtask.com/api/v1`, and API changes sync to the user's
Taskwarrior devices like web app changes do.

**The OpenAPI spec is the source of truth:**
`https://app.wingtask.com/api/docs/openapi.json`. Never guess
endpoints or field names. Schemas use `additionalProperties: false`,
so unknown fields are rejected. Pull exact shapes with:

```bash
curl -s https://app.wingtask.com/api/docs/openapi.json \
  | jq '.components.schemas.TaskCreate'
curl -s https://app.wingtask.com/api/docs/openapi.json \
  | jq '.paths["/tasks"].get.parameters'
```

## Rules

- **Auth**: `Authorization: Bearer <token>`. Users create tokens in
  WingTask under Settings > API Tokens. The token is in `$WT_TOKEN`.
  Never echo it, log it, put it in client-side code, or commit it.
- **Permissions**: each operation's `x-permission` is `read` or
  `write`. Use a read-only token unless the task writes. A read-only
  token gets 403 `forbidden` on writes. `POST /tasks/query` is a read.
- **Rate limit**: 100 requests per token per UTC minute. Watch
  `X-RateLimit-Remaining` and `X-RateLimit-Reset` (epoch seconds). On
  429, wait `Retry-After`, then back off exponentially. Never retry
  immediately or in a tight loop. A full `--all` crawl of a large
  account can use most of a minute's budget.
- **Pagination**: while `pagination.has_more`, repeat the identical
  request with `cursor=<pagination.next_cursor>`. Changing filters,
  sort, `context_id`, or `limit` mid-crawl gives 400
  `invalid_cursor`. Never build or parse cursors. `limit` is 1-100,
  default 50. 410 `cursor_expired` means restart from page 1.
- **Time**: responses are UTC (`...Z`). Input timestamps without an
  offset use the user's time zone from `GET /me`. Task date fields
  need a full `YYYY-MM-DDTHH:MM:SS`. For a date-only value, send local
  midnight with `<field>_precision: "date"`. Datetime precision at
  local midnight is rejected.
- **Errors**: `{"error": {"code", "message", "details"?}}`. Branch on
  `code`, show `message` to the user, and report `X-Request-Id`.
- **Confirm before destructive writes** (delete task/list/UDA, bulk
  edits, undo). Deleted tasks can be restored with `.../undelete`.

## Helper script

`scripts/wt.py` (stdlib Python) applies the rules above. It reads
`WT_TOKEN`, retries 429s and retryable 409s per `Retry-After` with
exponential backoff, retries 503s only for safe requests, and follows
cursors with `--all`. Errors print status, code, message, details,
and `X-Request-Id` to stderr and exit 1. The rate-limit-window wait
only applies within one process, so prefer one `--all` call over many
separate calls.

```bash
wt.py get /me
wt.py get /tasks status=pending project=Home limit=100 --all
wt.py post /tasks/query "$(cat filter.json)" --all
wt.py post /tasks '{"description": "Buy milk", "tags": ["errands"]}'
wt.py patch /tasks/<uuid> '{"due": "2026-10-20T00:00:00",
  "due_precision": "date"}'
wt.py post /tasks/<uuid>/done
wt.py delete /tasks/<uuid>
wt.py get /search q=dentist
```

Add `-v` to log each request's `X-Request-Id`. `wt.py post /tasks`
adds a client `uuid` so a retried create can't make a duplicate.
Pipe to `jq` to trim output.

## Endpoints

| Area | Endpoints |
|---|---|
| Account | `GET /me` (email, `time_zone`) |
| Tasks | `GET/POST /tasks`, `GET/PATCH/DELETE /tasks/{uuid}` |
| Query | `POST /tasks/query`: JSON filter, see below |
| State | `POST /tasks/{uuid}/done`, `/undone`, `/undelete` (body `{}`) |
| Annotations | `POST /tasks/{uuid}/annotations`, |
| | `PATCH/DELETE /tasks/{uuid}/annotations/{annotation_id}` |
| Lists | `GET/POST /lists`, `GET/PATCH/DELETE /lists/{id}`, |
| | `GET /lists/{id}/tasks` |
| UDAs | `GET/POST /udas`, `GET/PATCH/DELETE /udas/{id}` |
| Projects/tags | `GET /projects`, `GET /tags` (pending counts) |
| Search | `GET /search?q=`: tasks, lists, projects, tags |
| Undo | `GET /undos`, `POST /undos` |

## Things that trip people up

- `GET /tasks` simple filters: `status`, `description`, `project`,
  `tag`, `priority`, `context_id`, `sort`. For OR, date ranges, UDAs,
  or multiple tags, use `POST /tasks/query` and put
  `limit`/`cursor` in the body. Read `references/filters.md` for the
  filter grammar, operators, sort names, and examples. Lists use the
  same filter format.
- `status` defaults to `pending`. Ask for `completed`, `waiting`,
  `deleted`, or `all` explicitly. In task objects, waiting is a
  boolean `waiting`, not a status value.
- **Contexts are lists with `context: true`.** Find a context's `id`
  via `GET /lists`, then pass `context_id=<id>` to tasks, projects,
  tags, or search. Toggle with `PATCH /lists/{id} {"context": true}`.
- IDs: tasks use UUIDs. Lists are `lst-…`, UDAs `uda-…`, and undo
  groups `ue-…`. An annotation's id is its UTC entry timestamp
  (`2026-10-01T17:03:00Z`).
- Writes return `{data, meta: {undo_operation_id, changed}}`.
  `changed: false` means the request was a no-op. To undo a specific
  change, pass `{"expected_operation_id": "<undo_operation_id>"}` to
  `POST /undos`. Without it, the latest group is undone, which may be
  someone else's change. Undo 409s: `nothing_to_undo`,
  `undo_conflict`, `undo_diverged` (`details` lists changed tasks).
- `PATCH /tasks/{uuid}` needs at least one field. Set a field to
  `null` to clear it. `tags` is sent as a full array (there are no
  add/remove operations), so read, modify, and write. UDA values go in
  `udas: {name: value}`.
- `GET /search` with blank `q` is 422, not 400.
- 409 `mutation_in_progress` and `annotation_timestamp_conflict` are
  transient. Retry after `Retry-After`. 409 `invalid_transition`
  means the action makes no sense for the task's state.

## Building an application

When writing app code against the API rather than calling it
directly, read `references/app-client.md`. It has an implementation
checklist, a table of every error code with how to handle it, and a
TypeScript client and pagination sketch.

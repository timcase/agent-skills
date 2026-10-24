# JSON filters

Used by `POST /tasks/query` (`filter`) and by saved lists
(`POST/PATCH /lists`, `filter`). Condensed from the
`POST /tasks/query` description in the OpenAPI spec; check there if
something here looks wrong.

## Contents

- Shape
- Fields
- Operators
- Query body and sorts
- Examples

## Shape

```json
{ "operator": "and", "rules": [
  { "type": "rule", "field": "project", "operator": "eq",
    "value": "Home" },
  { "type": "group", "operator": "or", "rules": [ ... ] }
] }
```

- The root group may omit `type`. **Nested groups must have
  `"type": "group"`**, or they are treated as rules.
- Rules always have `"type": "rule"`. Set/unset operators take no
  `value`; omit the key.
- An empty `and` group matches every task. An empty `or` group is a
  422 error.
- Limits: nesting depth 10 and 100 rules total.
- Invalid filters get 422 `validation_failed` with `details` keyed by
  path, e.g. `filter.rules[1].operator`.

## Fields

- **Text**: `description`, `project`, `project_name`, `priority`,
  `parent`
- **Status**: `status`
- **Tags**: `tags`
- **Annotations**: `annotations`
- **Date**: `due`, `scheduled`, `scheduled_end`, `wait`, `until`,
  `start`, `end`, `created_at` (or `entry`), `updated_at` (or
  `modified`)
- **UDAs**: by UDA `name`. Numeric and date UDAs use their type; the
  rest are text.

Statuses: `pending`, `waiting`, `completed`, `deleted`, `recurring`.

## Operators

- **Text**: `eq`, `neq`/`not_eq`, `contains`, `does_not_contain`,
  `starts_with`, `ends_with` (string); `in`, `not_in` (string list)
- **Numeric**: `eq`, `neq`/`not_eq`, `gt`, `gte`, `lt`, `lte`
  (number); `in`, `not_in` (number list); `between` (`[low, high]`)
- **Date**: `before`, `after`, `lt`, `gt`, `gte`, `lte`, `on` (ISO 8601
  date or datetime); `between` (two of them); `before_relative`,
  `after_relative`, `on_relative` (phrase: `"today"`, `"tomorrow"`,
  `"now"`)
- **Tags**: `has_tag`, `without_tag` (tag); `has_all_tags`,
  `has_any_tag`, `without_any_tag`, `without_all_tags` (tag list);
  `has_no_tags` (no value)
- **Annotations**: `contains` (string)
- **Status**: `eq`, `neq`/`not_eq` (status); `in`, `not_in` (list)
- **Set or unset** (every kind except status): `present`,
  `not_empty`, `not_nil`, `empty`, `nil` (no value)

Dates without an offset are read in the user's WingTask time zone
(`GET /me`). A date with no time means midnight. `on` matches the
whole day, and a date-only upper bound in `between` includes its whole
day.

## Query body and sorts

`POST /tasks/query` body: `filter` (required), `status` (`pending`
default, `waiting`, `completed`, `deleted`, `all`), `context_id`,
`sort`, `limit` (1-100), `cursor`. Page with `limit`/`cursor` in the
**body**, not the URL.

A `status` rule inside `filter` turns off the `pending` default. A
top-level `status` that the filter's status rules can never match is
a 422.

Sorts (also valid for `GET /tasks`, `GET /lists/{id}/tasks`, and a
list's `default_sort`): `created_at_desc` (default),
`created_at_asc`, `description_asc`, `description_desc`,
`highest_priority`, `lowest_priority`, `due_soonest`, `due_latest`,
`scheduled_soonest`, `scheduled_latest`, `end_desc`, `end_asc`,
`uda:<name>:asc`, `uda:<name>:desc`.

## Examples

Due by end of today, overdue first:

```json
{ "filter": { "operator": "and", "rules": [
    { "type": "rule", "field": "due", "operator": "before_relative",
      "value": "today" } ] },
  "sort": "due_soonest" }
```

Errands or shopping with no due date:

```json
{ "filter": { "operator": "and", "rules": [
    { "type": "rule", "field": "tags", "operator": "has_any_tag",
      "value": ["errands", "shopping"] },
    { "type": "rule", "field": "due", "operator": "nil" } ] } }
```

High priority, or work tasks mentioning a report:

```json
{ "filter": { "operator": "or", "rules": [
    { "type": "rule", "field": "priority", "operator": "eq",
      "value": "H" },
    { "type": "group", "operator": "and", "rules": [
      { "type": "rule", "field": "tags", "operator": "has_tag",
        "value": "work" },
      { "type": "rule", "field": "description",
        "operator": "contains", "value": "report" } ] } ] } }
```

Completed in the first week of October, newest first:

```json
{ "filter": { "operator": "and", "rules": [
    { "type": "rule", "field": "end", "operator": "between",
      "value": ["2026-10-01", "2026-10-07"] } ] },
  "status": "completed", "sort": "end_desc" }
```

Numeric UDA `estimate` between 1 and 3, 20 per page:

```json
{ "filter": { "operator": "and", "rules": [
    { "type": "rule", "field": "estimate", "operator": "between",
      "value": [1, 3] } ] },
  "limit": 20 }
```

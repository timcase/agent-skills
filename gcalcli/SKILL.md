---
name: gcalcli
description: Work with Google Calendar via the gcalcli CLI. Use to view agendas, search events, add/quick-add/edit/delete events, import ics files, find conflicts, or bulk update via TSV. Triggers on 'gcalcli', 'my calendar', 'schedule a meeting'.
---

# gcalcli

CLI for Google Calendar. Run `gcalcli <cmd> --help` for full options.

## Ground rules

- Put `--calendar "Name"` AFTER the subcommand, not before (global form is
  brittle). Repeatable for read commands; exactly one for write commands.
- Always prefer machine-readable output when parsing: `--json` or `--tsv`,
  plus `--nocolor` (global flag, goes before the subcommand).
- Never use interactive flows: `edit` and `delete` prompt per event, and `add`
  prompts for missing fields. Use the non-interactive routes below.
- Confirm with the user before any write (add, delete, agendaupdate, import).
  Show the exact command or event details first.
- If auth fails, tell the user to run `gcalcli init` (needs a client id, see
  README); do not attempt it.

## Reading

```bash
gcalcli list                          # calendars and access roles
gcalcli --nocolor agenda "today" "+7d" --json --details all
gcalcli agenda --tsv --details id --details time --details title
gcalcli search "standup" "2026-01-01" "2026-03-01" --json
gcalcli conflicts ["text"] [start] [end]   # default: now +30 days
gcalcli updates "2026-09-01" --json   # changed since datetime
gcalcli --nocolor calw "today" 2      # week view, 2 weeks (--monday)
gcalcli --nocolor calm                # month view (--noweekend)
```

- Dates accept ISO (`2026-09-21`), times (`3pm`), and fuzzy text (`tomorrow`,
  `next friday`, `+3d`). `start`/`end` are positional and optional.
- `--details` is repeatable: id, time, length, url, conference, title,
  location, description, calendar, email, attendees, action, reminders,
  attachments, end, all. Use `--details id` whenever an ID is needed later.
- `--nodeclined` and `--nostarted` filter noise.
- Agenda's default range is today onward; pass explicit start and end for
  anything else.

## Creating

Quick natural-language add (single calendar required):

```bash
gcalcli quick --calendar "Work" "Lunch with Sam tomorrow 12:30pm for 1h"
```

Detailed add; pass every field plus `--noprompt` to avoid prompts:

```bash
gcalcli add --calendar "Work" --noprompt \
  --title "Design review" --when "2026-09-22 14:00" --duration 45 \
  --where "Room 4" --description "Agenda: ..." \
  --who a@example.com --who b@example.com \
  --reminder "10m popup" --reminder "1d email"
```

- Use `--end "<time>"` instead of `--duration` (mutually exclusive).
- `--allday` ignores the time part; `--duration` then means days.
- Without `--reminder`, use `--default-reminders` for calendar defaults;
  otherwise no reminders are created. Reminder form: `TIME [popup|email|sms]`
  with TIME suffix w/d/h/m (minutes by default).
- `--color` sets the event color.

Import ics/vcal (file arg or stdin, single calendar):

```bash
gcalcli import --calendar "Work" --dump invite.ics   # preview only
gcalcli import --calendar "Work" invite.ics
```

## Editing and deleting (non-interactive)

Avoid `gcalcli edit` / `gcalcli delete` from an agent. Instead:

1. Get the event ID: `gcalcli agenda ... --tsv --details id --details time
   --details title`.
2. Write a TSV file with a header row and run
   `gcalcli agendaupdate --calendar "Work" file.tsv` (or stdin).

TSV columns are the `--tsv` field names: `id`, `start_date`, `start_time`,
`end_date`, `end_time`, `length`, `title`, `location`, `description`,
`attendees`, `action`. Tab-separated; encode newlines as `\n`.

`action` per row: `patch` (default; empty `id` becomes an insert), `insert`,
`delete`, `ignore`.

```
id	title	start_date	start_time	action
abc123	New title	2026-09-22	15:00	patch
def456				delete
```

- Don't mix `length` with `end_date`/`end_time` in one file.
- Read-only fields (e.g. `calendar`, `email`) are checked against the current
  event on patch and error if they differ; omit them.
- Round-trip trick: export with `agenda --tsv --details all`, edit the rows,
  feed back in. Keep only the columns you intend to change plus `id`.
- `gcalcli delete "text" [start] [end] --iamaexpert` skips confirmation.
  Last resort; only with an unambiguous, narrow query the user approved.

## Other

- `gcalcli remind 10 'notify-send -u critical %s'` runs a command if an event
  starts within N minutes (`%s` = start time + title). Suited to cron.
- `gcalcli config edit` opens `config.toml` (default/ignore calendars,
  week-start). Override the location with `$GCALCLI_CONFIG`.
- `gcalcli --refresh <cmd>` or `gcalcli util reset-cache` fixes stale data
  (e.g. new calendars not appearing).
- `gcalcli util inspect-auth` shows token metadata.

# Taskwarrior Attributes

## Core Attributes

### description
Main task text. Searchable by default.
```bash
task add Buy milk
task add "Call John about project"
```

### status
Task state: `pending`, `completed`, `deleted`, `waiting`, `recurring`
```bash
task status:pending list
task status:completed list
```

### project
Hierarchical organization using dot notation.
```bash
task add Fix bug project:Work.Backend
task project:Home list
task project.startswith:Work list
```

### tags
Arbitrary labels. Use `+` to add, `-` to remove.
```bash
task add Task +work +urgent
task 42 modify +important
task 42 modify -urgent
task +home list
```

### priority
Task importance: `H` (High), `M` (Medium), `L` (Low), or none
```bash
task add Task priority:H
task 42 modify priority:M
task priority:H list
```

## Date Attributes

### due
When task is due.
```bash
task add Task due:tomorrow
task add Task due:2024-12-31
task due.before:eom list
```

### scheduled
When task becomes actionable.
```bash
task add Task scheduled:friday
task scheduled.before:now list
```

### wait
Hides task until specified date.
```bash
task add Task wait:later
task add Task wait:2024-06-01
task +WAITING list
```

### until
Task auto-deletes after this date.
```bash
task add Temporary task until:eom
task add Task recur:daily until:2024-12-31
```

### entry
When task was created (set automatically).
```bash
task entry.after:2024-01-01 list
```

### end
When task was completed or deleted (set automatically).
```bash
task end.after:2024-01-01 status:completed list
```

### modified
Last modification time (set automatically).
```bash
task modified.after:yesterday list
```

## Special Attributes

### depends
Comma-separated task IDs/UUIDs this task depends on.
```bash
task add Task depends:42
task add Task depends:5,7,9
task 42 modify depends:-5       # Remove dependency on 5
```

### recur
Recurrence frequency.
```bash
task add Pay rent due:1st recur:monthly
task add Exercise recur:daily
task add Meeting recur:weekly
```

### urgency
Calculated priority score (read-only, but can filter).
```bash
task urgency.over:10 list
task urgency.under:5 list
```

### uuid
Unique identifier (set automatically).
```bash
task uuid:ebeeab00-ccf8-464b-8b58-f7f2d606edfb info
```

### id
Temporary numeric ID in current working set (changes over time).
```bash
task 42 done
task 1-10 modify priority:H
```

## Virtual Tags

Virtual tags represent task metadata. Cannot be added/removed directly.

### Status Virtual Tags
- **PENDING** - Task is pending
- **COMPLETED** - Task is completed
- **DELETED** - Task is deleted
- **WAITING** - Task status is waiting

### Activity Virtual Tags
- **ACTIVE** - Task has been started
- **READY** - Actionable (unscheduled or scheduled < now, not waiting)
- **BLOCKED** - Blocked by dependencies
- **BLOCKING** - Blocks other tasks
- **UNBLOCKED** - Not blocked

### Time Virtual Tags
- **OVERDUE** - Past due date
- **DUE** - Due within 7 days (configurable via rc.due)
- **TODAY** - Due today
- **TOMORROW** - Due tomorrow
- **YESTERDAY** - Was due yesterday
- **WEEK** - Due this week
- **MONTH** - Due this month
- **QUARTER** - Due this quarter
- **YEAR** - Due this year

### Content Virtual Tags
- **ANNOTATED** - Has annotations
- **TAGGED** - Has tags
- **PRIORITY** - Has a priority set
- **PROJECT** - Has a project
- **SCHEDULED** - Has scheduled date
- **UNTIL** - Has until date
- **UDA** - Has any UDA values

### Recurrence Virtual Tags
- **TEMPLATE** - Is a recurrence template
- **INSTANCE** - Is a recurrence instance
- **CHILD** - Has a parent (deprecated in 2.6.0)
- **PARENT** - Is a parent (deprecated in 2.6.0)

### Other Virtual Tags
- **LATEST** - Newest added task
- **ORPHAN** - Has orphaned UDA values

## Special Tags

Special tags affect task behavior:

### +next
Elevates urgency (appears on 'next' report).
```bash
task 42 modify +next
```

### +nocolor
Disables color rules for this task.
```bash
task 42 modify +nocolor
```

### +nonag
Suppresses nag messages when completing.
```bash
task 42 modify +nonag
```

### +nocal
Task won't appear on calendar.
```bash
task 42 modify +nocal
```

## Examples

### Creating Tasks
```bash
task add Buy groceries +errands due:saturday
task add Write report project:Work priority:H
task add Meeting scheduled:tomorrow +work +meeting
```

### Filtering by Attributes
```bash
task project:Home priority:H list
task +urgent status:pending list
task due.before:eom and -BLOCKED list
```

### Modifying Attributes
```bash
task 42 modify priority:H
task 42 modify project:Work.Backend
task 42 modify +urgent +important
task 42 modify due:friday scheduled:tomorrow
```

### Using Virtual Tags
```bash
task +OVERDUE list
task +ACTIVE list
task +BLOCKING list
task +READY and project:Work list
```

### Dependencies
```bash
task add Design depends:42
task add Code depends:43,44
task +BLOCKED list
task +BLOCKING list
```

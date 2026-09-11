# Taskwarrior Recurrence

## Recurrence Syntax

Recurring tasks require `recur` and typically `due`:
```bash
task add Pay rent due:1st recur:monthly
task add Exercise due:tomorrow recur:daily
```

## Frequency Formats

### Daily
```bash
recur:daily
recur:day
recur:1day
recur:2days
recur:1da
recur:3da
recur:P1D         # ISO-8601 format
```

### Weekdays Only
```bash
recur:weekdays    # Mon-Fri, skips weekends
```

### Weekly
```bash
recur:weekly
recur:1wk
recur:2wks
recur:biweekly
recur:fortnight   # Every 2 weeks
recur:P1W         # ISO-8601 format
```

### Monthly
```bash
recur:monthly
recur:month
recur:1mo
recur:2mo
recur:P1M         # ISO-8601 format
```

### Quarterly
```bash
recur:quarterly
recur:1qtr
recur:2qtrs
recur:P3M         # ISO-8601 format (3 months)
```

### Yearly
```bash
recur:annual
recur:yearly
recur:1yr
recur:2yrs
recur:biannual    # Every 2 years
recur:biyearly
recur:P1Y         # ISO-8601 format
```

### Semiannual
```bash
recur:semiannual  # Every 6 months
recur:P6M         # ISO-8601 format
```

## Until Date

Limits recurrence to specific date:
```bash
task add Pay bills due:1st recur:monthly until:2025-12-31
task add Daily standup recur:daily until:eoy
```

Without `until`, recurrence continues indefinitely.

## Parent and Child Tasks

### Template (Parent)
- Created when recurring task is added
- Has status `recurring`
- Holds recurrence definition
- Not shown in most reports
- Visible with `task recurring` or `task all`

### Instance (Child)
- Generated from template
- Appears as regular pending task
- When completed, next instance is created
- Has virtual tag `+INSTANCE`

```bash
# Create recurring task (creates template)
task add Exercise recur:daily due:tomorrow

# View template
task recurring list

# Complete instance (generates next)
task 42 done
```

## Recurrence Behavior

### Instance Creation
- First instance created immediately
- Next instance created when current is completed/deleted
- Instance inherits all attributes from template except:
  - ID (new ID assigned)
  - UUID (new UUID assigned)
  - Entry date (set to creation time)
  - Due date (calculated from recurrence)

### Modifying Recurrence
```bash
# Modify template (affects future instances)
task recurring modify priority:H

# Modify single instance
task 42 modify +special
```

### Stopping Recurrence
```bash
# Delete template (stops all future instances)
task recurring delete

# Add until date
task recurring modify until:eom
```

## Virtual Tags

- **+TEMPLATE** - Is the recurring template
- **+INSTANCE** - Is a generated instance
- **+PARENT** - Has children (deprecated 2.6.0)
- **+CHILD** - Has parent (deprecated 2.6.0)

## Examples

### Daily Tasks
```bash
task add Take vitamins recur:daily due:today
task add Backup files recur:daily due:23:00
```

### Weekly Tasks
```bash
task add Team meeting recur:weekly due:friday
task add Grocery shopping recur:weekly due:saturday
```

### Monthly Tasks
```bash
task add Pay rent recur:monthly due:1st
task add Monthly report recur:monthly due:eom
```

### Yearly Tasks
```bash
task add Birthday recur:yearly due:2024-06-15
task add Tax filing recur:yearly due:2024-04-15
```

### With Until
```bash
task add Gym recur:daily due:tomorrow until:2024-12-31
task add Project standup recur:weekdays until:eom
```

## Important Notes

1. **Sync Consideration**: Only one client should have `recurrence=on` to avoid duplicates
2. **Completion Required**: Next instance only created when current is completed/deleted
3. **Template Persistence**: Template remains in database until explicitly deleted
4. **Modification Scope**: Changes to template don't affect existing instances
5. **Until Behavior**: Tasks stop generating after until date

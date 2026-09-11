# Taskwarrior Dates

## Date Format Configuration

The `dateformat` configuration variable controls date parsing and display:
```bash
task config dateformat Y-M-D
task config dateformat m/d/Y
```

## ISO-8601 Format

Full ISO-8601 date-time format is always supported:
```bash
task add Task due:2024-03-14T22:30:00Z
task add Task due:2024-12-25T00:00:00
```

## Exact Dates

Specify exact dates in configured format:
```bash
task add Task due:7/14/2024
task add Task due:2024-07-14
```

## Relative Dates

### Now
```bash
task add Task due:now
task add Task scheduled:now
```

### Today/Yesterday/Tomorrow
```bash
task add Task due:today
task add Task due:yesterday
task add Task due:tomorrow
```

### Weekdays
Next occurrence of specified weekday:
```bash
task add Task due:friday
task add Task due:mon
task add Task due:saturday
```

### Day Number with Ordinal
```bash
task add Task due:23rd      # 23rd of current/next month
task add Task due:1st       # 1st of next month
```

### Time Offsets
```bash
task add Task due:3wks      # 3 weeks from now
task add Task due:1day      # 1 day from now
task add Task due:9hrs      # 9 hours from now
task add Task due:30min     # 30 minutes from now
```

## Start/End of Period

### Week Boundaries
- **sow** - Start of work week (Monday)
- **eow** - End of work week (Friday)
- **soww** - Start of week (Sunday or Monday, configurable)
- **eoww** - End of work week (Friday)
- **socw** - Start of calendar week (Sunday or Monday, configurable)
- **eocw** - End of calendar week (Saturday or Sunday)

```bash
task add Task due:eow       # End of work week
task add Task due:sow       # Start of work week
```

### Month/Quarter/Year
- **som** - Start of month
- **eom** - End of month
- **soq** - Start of quarter
- **eoq** - End of quarter
- **soy** - Start of year
- **eoy** - End of year

```bash
task add Task due:eom       # End of current month
task add Task due:som       # Start of next month
task due.before:eoq list    # Due before end of quarter
```

## Special Values

### Later/Someday
Sets wait date to far future (12/30/9999):
```bash
task add Task wait:later
task add Task wait:someday
```

## Predictable Holidays

```bash
task add Task due:goodfriday
task add Task due:easter
task add Task due:eastermonday
task add Task due:ascension
task add Task due:pentecost
task add Task due:midsommar
task add Task due:midsommarafton
task add Task due:juhannus
```

## Date Calculations

Dates can be used in calc command:
```bash
task calc now + 8d              # 8 days from now
task calc eom                   # End of month date
task calc 2024-01-01 + 30d      # 30 days after date
```

## Date Modifiers in Filters

### before/after
```bash
task due.before:eom list        # Due before end of month
task due.after:today list       # Due after today
task entry.after:2024-01-01 list
```

### by (inclusive)
```bash
task due.by:eoy list            # Due by end of year (inclusive)
```

### Comparison Operators
```bash
task 'due < eom' list           # Due before end of month
task 'due >= today' list        # Due today or later
task 'entry > 2024-01-01' list
```

## Examples

```bash
# Task due tomorrow at end of day
task add Task due:tomorrow

# Task due at end of current week
task add Task due:eow

# Task scheduled for next Monday
task add Task scheduled:monday

# Task waiting until next month
task add Task wait:som

# Task due in 2 weeks
task add Task due:2wks

# Task due on the 15th
task add Task due:15th

# Filter tasks due this month
task due.by:eom list

# Filter tasks created in last week
task entry.after:eow-1wk list
```

## Date Comparison

When filtering:
- `=` operator: Dates equal if same day (time ignored)
- `==` operator: Exact equality including time
- `before`/`after`: Exclusive comparison
- `by`: Inclusive comparison (same as `<=`)

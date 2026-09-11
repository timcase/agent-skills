# Taskwarrior Filters

## Filter Basics

Filters select which tasks a command operates on. Multiple filters are combined with implicit `and`:
```bash
task project:Home +weekend garden list
# Means: project:Home AND +weekend AND description contains 'garden'
```

## Attribute Modifiers

### Comparison Modifiers
- **before** (synonyms: under, below) - Less than comparison
- **after** (synonyms: over, above) - Greater than comparison
- **by** - Same as before but inclusive (<=)

```bash
task due.before:eom list           # Due before end of month
task priority.before:M list        # Priority less than M (so L)
task urgency.over:10 list          # Urgency greater than 10
task due.by:eoy list               # Due by end of year (inclusive)
```

### Equality Modifiers
- **is** (synonym: equals) - Exact match
- **isnt** (synonym: not) - Not equal
- **none** - Attribute has no value
- **any** - Attribute has any value

```bash
task priority.is:H list            # Exactly priority H
task priority.isnt:L list          # Not priority L
task priority.none: list           # No priority set
task project.any: list             # Has any project
```

### String Matching Modifiers
- **has** (synonym: contains) - Substring match
- **hasnt** - Does not contain substring
- **startswith** (synonym: left) - Starts with string
- **endswith** (synonym: right) - Ends with string
- **word** - Contains whole word
- **noword** - Does not contain whole word

```bash
task description.has:bug list           # Description contains 'bug'
task description.hasnt:meeting list     # No 'meeting' in description
task project.startswith:Home list       # Project starts with 'Home'
task description.endswith:today list    # Description ends with 'today'
task description.word:foo list          # Contains word 'foo' (not 'food')
task description.noword:bar list        # Doesn't contain word 'bar'
```

## Logical Operators

### AND (implicit)
Default operator between filter terms:
```bash
task project:Home +urgent list
# Same as: task project:Home and +urgent list
```

### OR
Requires parentheses to avoid precedence issues:
```bash
task '( project:Home or project:Garden )' list
task '( priority:H or priority:M )' and +urgent list
```

### XOR (exclusive or)
One or the other, but not both:
```bash
task '( project:Home xor +urgent )' list
```

### NOT (!)
Negation operator:
```bash
task '! project:Home' list
task '! ( +work or +personal )' list
```

## Pattern Matching

### Regular Expressions
Patterns enclosed in slashes:
```bash
task /bug-[0-9]+/ list                  # Match bug-123, bug-456, etc.
task /[Cc]at|[Dd]og/ list               # Match cat, Cat, dog, or Dog
task description.has:/^URGENT/ list     # Starts with URGENT
```

### Simple Patterns
Text without modifiers searches description and annotations:
```bash
task meeting list                   # Contains 'meeting'
task 'urgent task' list             # Contains 'urgent task'
```

## Filter Examples

### By Status
```bash
task status:pending list            # Pending tasks
task status:completed list          # Completed tasks
task status:deleted list            # Deleted tasks
task status:waiting list            # Waiting tasks
```

### By Date
```bash
task due:today list                 # Due today
task due.before:tomorrow list       # Due before tomorrow
task due.after:eow list             # Due after end of week
task scheduled.before:now list      # Scheduled in past
task entry.after:2024-01-01 list    # Created after date
```

### By Priority
```bash
task priority:H list                # High priority
task priority.not:L list            # Not low priority
task priority.none: list            # No priority
task priority.any: list             # Any priority set
```

### By Project
```bash
task project:Work list              # Project Work
task project.startswith:Home list   # Projects starting with Home
task project.none: list             # No project
task project.any: list              # Any project
```

### By Tags
```bash
task +work list                     # Has tag 'work'
task -urgent list                   # Doesn't have tag 'urgent'
task tags.none: list                # No tags
task tags.any: list                 # Has any tags
```

### By Dependencies
```bash
task +BLOCKED list                  # Blocked by dependencies
task +BLOCKING list                 # Blocking other tasks
task +UNBLOCKED list                # Not blocked
task depends.none: list             # No dependencies
```

### By Virtual Tags
```bash
task +PENDING list                  # Pending status
task +COMPLETED list                # Completed status
task +ACTIVE list                   # Started tasks
task +OVERDUE list                  # Overdue tasks
task +DUE list                      # Due within 7 days
task +TODAY list                    # Due today
task +TOMORROW list                 # Due tomorrow
task +WEEK list                     # Due this week
task +MONTH list                    # Due this month
task +YEAR list                     # Due this year
task +READY list                    # Actionable (unscheduled or scheduled < now)
task +WAITING list                  # Waiting tasks
task +SCHEDULED list                # Has scheduled date
task +ANNOTATED list                # Has annotations
```

### By ID/UUID
```bash
task 42 list                        # Task with ID 42
task 1,3,5 list                     # Tasks 1, 3, and 5
task 1-10 list                      # Tasks 1 through 10
task 1-5,10,15-20 list              # Multiple ranges
task UUID list                      # Specific UUID
```

### Complex Filters
```bash
# High priority work tasks due this week
task project:Work priority:H +WEEK list

# Home or garden tasks that are not blocked
task '( project:Home or project:Garden )' and -BLOCKED list

# Urgent tasks without a project
task +urgent and project.none: list

# Tasks due before end of month, high or medium priority
task due.before:eom and '( priority:H or priority:M )' list

# Active tasks or overdue tasks
task '( +ACTIVE or +OVERDUE )' list

# Tasks with 'bug' in description, not completed
task /bug/ and status:pending list
```

## Special Filter Cases

### Empty Filter
No filter matches all tasks (requires confirmation):
```bash
task modify +review
# Prompts: "This command has no filter, and will modify all tasks. Are you sure?"
```

### Negating Filters
```bash
task project.not:Work list          # Not in Work project
task -urgent list                   # Doesn't have urgent tag
task priority.isnt:H list           # Priority is not H
```

### Multiple Attributes
```bash
task +home +urgent project:Personal list
task due.before:eom priority:H -BLOCKED list
```

## Operator Precedence

Parentheses are required when using OR or XOR to avoid precedence issues with report filters:
```bash
# WRONG - will not work as expected
task project:Home or project:Garden list

# CORRECT - isolates OR from report filter
task '( project:Home or project:Garden )' list
```

The list report has filter `status:pending` which gets combined with AND, making the wrong example:
```
status:pending and project:Home or project:Garden
```
This is parsed as `(status:pending and project:Home) or project:Garden` which matches ALL Garden tasks.

## Filter Shortcuts

### Equivalent Expressions
```bash
task foo list
task /foo/ list
task description.contains:foo list
task description.has:foo list
task 'description ~ foo' list
# All equivalent - search for 'foo' in description
```

### Default Behavior
- Bare text searches description and annotations
- Multiple terms are ANDed together
- Reports may have built-in filters that combine with your filter

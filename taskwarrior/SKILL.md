---
name: taskwarrior
description: Comprehensive task management using Taskwarrior CLI - add, modify, filter, complete, and sync tasks with support for projects, tags, priorities, due dates, dependencies, recurrence, and custom attributes (UDAs). Use when managing tasks, todos, or task lists including operations like creating tasks with attributes, filtering/querying tasks by project/tag/status/date, completing/deleting tasks, bulk operations on multiple tasks, task dependencies and blocking, recurring tasks, urgency-based prioritization, and syncing tasks with a task server.
---

# Taskwarrior

Manage tasks using the Taskwarrior command-line interface. This skill provides comprehensive task management capabilities including adding, modifying, filtering, completing, and syncing tasks with rich attribute support.

## Quick Start

### Basic Syntax

```bash
task <filter> <command> <mods>
```

- **filter**: Select which tasks (by ID, project, tag, attribute, etc.)
- **command**: What to do (add, list, modify, done, delete, sync, etc.)
- **mods**: Changes to apply (project:X, +tag, due:tomorrow, priority:H, etc.)

### Common Examples

```bash
# Add a task
task add Fix parser bug due:tomorrow priority:H +bugfix

# List tasks
task project:Home list
task +work status:pending list
task overdue

# Complete a task
task 15 done

# Modify a task
task 23 modify due:friday priority:M

# Bulk operations
task +important modify scheduled:tomorrow
task project:HomeGardening done

# Sync
task sync
```

## Core Operations

### Adding Tasks

```bash
# Basic task
task add Description text

# With attributes
task add Review code priority:H due:tomorrow +review project:Development

# With multiple tags
task add Buy groceries +home +shopping due:eow

# With dependencies
task add Deploy feature depends:42,43 due:friday
```

For complex planning workflows, break down the plan into individual tasks and add each with appropriate attributes.

### Modifying Tasks

```bash
# Single task
task 15 modify due:tomorrow priority:H

# Multiple tasks by filter
task +important modify scheduled:tomorrow
task project:Work modify priority:M

# Add/remove tags
task 23 modify +urgent -later

# Change project
task 10-15 modify project:NewProject
```

### Filtering and Listing

Filters select tasks based on attributes. Combine multiple criteria:

```bash
# By project/tag
task project:Home list
task +work list
task project:Development +bugfix list

# By status
task status:pending list
task completed list
task overdue

# By date
task due.before:eom list
task scheduled:today list

# Complex filters
task '(project:Home or project:Garden)' +important list
task 'priority:H and due.before:eow' list
```

**See [filters.md](filters.md) for complete filter syntax and operators.**

### Completing and Deleting Tasks

```bash
# Complete tasks
task 15 done
task 20-25 done
task project:OldProject done

# Delete tasks
task 42 delete
task overdue delete  # Confirms before deleting

# Start/stop tasks
task 15 start
task 15 stop
```

### Syncing Tasks

```bash
# Sync with task server
task sync
```

Ensure sync is configured (`taskrc` settings) before first use.

## Working with Attributes

### Projects

Hierarchical organization using dot notation:

```bash
task add Implement feature project:Work.Development.Backend
task add Write tests project:Work.Development.Backend.Tests

# Filter by project hierarchy
task project:Work list                    # All Work tasks
task project:Work.Development list        # Development tasks
task project.startswith:Work list         # Same as above
```

**See [projects.md](projects.md) for project functionality details.**

### Tags

Arbitrary words for categorization:

```bash
# Add with tags
task add Task description +urgent +review +home

# Filter by tags
task +urgent list
task +work -waiting list
task tags.any: list  # Any tasks with tags
```

### Priorities

```bash
# Set priority: H (High), M (Medium), L (Low), or none
task add High priority task priority:H
task 15 modify priority:M
task priority: list  # Tasks without priority
```

### Due Dates and Scheduling

```bash
# Due dates
task add Task due:tomorrow
task add Task due:2024-12-31
task add Task due:eom  # End of month

# Scheduled dates (when task becomes actionable)
task add Task scheduled:monday

# Wait dates (hide until date)
task add Task wait:nextweek
```

**See [dates.md](dates.md) for date formats and relative dates.**

### Dependencies

Tasks can block other tasks:

```bash
# Create dependency (task 10 depends on task 5 and 6)
task 10 modify depends:5,6

# View blocking relationships
task blocking  # Tasks blocking others
task blocked   # Tasks that are blocked

# Remove dependency
task 10 modify depends:-5  # Remove dependency on task 5
```

**See [dependencies.md](dependencies.md) for dependency management.**

### Recurring Tasks

```bash
# Create recurring task
task add Pay bills due:eom recur:monthly until:eoy

# Frequency options: daily, weekly, monthly, quarterly, annual
# Or ISO-8601 durations: P1D, P2W, P1M, P3M, P1Y
task add Daily standup due:9am recur:daily
task add Sprint review due:friday recur:2weeks
```

**See [recurrence.md](recurrence.md) for recurrence patterns.**

### Annotations

Add notes to tasks:

```bash
task 15 annotate Met with team, discussed approach
task 15 annotate Updated timeline based on feedback
```

## Advanced Features

### User Defined Attributes (UDAs)

Custom attributes beyond built-in ones:

```bash
# Configuration (in .taskrc)
uda.estimate.type=string
uda.estimate.label=Size Estimate
uda.estimate.values=huge,large,medium,small,trivial,

# Use in tasks
task add Task estimate:large
task estimate:small list
```

**See [udas.md](udas.md) for UDA configuration and types.**

### Urgency-Based Prioritization

Taskwarrior calculates urgency automatically based on multiple factors:

```bash
# View urgency
task list  # Sorted by urgency by default
task 15 info  # Shows urgency breakdown

# Customize urgency coefficients
task config urgency.due.coefficient 15.0
task config urgency.user.tag.important.coefficient 10.0
```

**See [urgency.md](urgency.md) for urgency formula and customization.**

### Bulk Operations

Work with multiple tasks efficiently:

```bash
# Modify multiple tasks by filter
task project:Old modify project:New
task +later -important modify scheduled:nextmonth
task 'due.before:today and status:pending' modify due:tomorrow

# Complete multiple tasks
task project:Sprint23 done
task +cleanup status:pending done

# Delete by filter
task status:deleted and end.before:2023-01-01 purge
```

## Workflow Patterns

### Planning Workflow

When asked to create a plan and add tasks:

1. Generate the plan (break down into steps)
2. Create tasks for each step with appropriate attributes:
   - Set `project:` for grouping
   - Add descriptive tags
   - Set priorities if specified
   - Establish dependencies where steps must be sequential

Example:
```bash
# User asks: "Create plan for implementing PWA and add tasks under project:WingTask:PwaInstall with +claude tag"

task add Research PWA requirements project:WingTask.PwaInstall +claude priority:H due:monday
task add Create service worker project:WingTask.PwaInstall +claude depends:123
task add Add manifest.json project:WingTask.PwaInstall +claude depends:123
task add Test offline functionality project:WingTask.PwaInstall +claude +testing depends:124,125
```

### Filtering Workflow

When asked to find and operate on tasks:

1. Construct appropriate filter
2. Preview what will be affected (if modifying/deleting)
3. Execute the operation

Example:
```bash
# User asks: "Find overdue tasks and delete them"

# First show what will be deleted
task overdue list

# Then delete
task overdue delete
```

### Bulk Modification Workflow

When asked to modify multiple tasks:

1. Build filter to select tasks
2. Apply modifications with `modify` command
3. Confirm results

Example:
```bash
# User asks: "Schedule all +important tasks for tomorrow using scheduled field"

task +important modify scheduled:tomorrow
```

## References

This skill includes detailed reference documentation for specific topics. Load these as needed:

- **[quick-reference.md](quick-reference.md)** - Command quick reference and common patterns
- **[filters.md](filters.md)** - Filter syntax, attribute modifiers, logical operators
- **[attributes.md](attributes.md)** - Core attributes, virtual tags, special tags
- **[dates.md](dates.md)** - Date formats, relative dates, calculations
- **[projects.md](projects.md)** - Project hierarchy and functionality
- **[dependencies.md](dependencies.md)** - Task dependencies and blocking
- **[recurrence.md](recurrence.md)** - Recurring task patterns
- **[udas.md](udas.md)** - User Defined Attributes configuration
- **[urgency.md](urgency.md)** - Urgency calculation and customization

## Key Principles

1. **Filters are powerful** - Master filter syntax for efficient task management
2. **Combine attributes** - Use project + tags + priority + dates for organization
3. **Preview before bulk operations** - Run `list` with filter before `modify`/`delete`
4. **Use hierarchical projects** - Organize with dot notation (Project.Subproject)
5. **Leverage urgency** - Let Taskwarrior prioritize based on multiple factors
6. **Dependencies model workflows** - Use `depends:` for sequential work
7. **Tags for flexible categorization** - Unlike projects, tasks can have many tags

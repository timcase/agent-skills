# Taskwarrior Quick Reference

## Basic Syntax
```
task <filter> <command> <mods>
```

## Common Read Commands

### Reports
- `task` - Default report (usually next)
- `task list` - Standard listing of pending tasks
- `task next` - Most urgent tasks
- `task active` - Started tasks
- `task completed` - Completed tasks
- `task all` - All tasks including deleted
- `task blocked` - Tasks blocked by dependencies
- `task blocking` - Tasks blocking other tasks
- `task waiting` - Tasks waiting until date
- `task overdue` - Tasks past due date
- `task recurring` - Recurring tasks
- `task ls` - Short listing
- `task long` - Detailed listing
- `task minimal` - Minimal listing

### Information
- `task <id> info` - All data and metadata for a task
- `task projects` - List all projects with counts
- `task tags` - List all tags used
- `task summary` - Task status by project
- `task count` - Count matching tasks

### Utility
- `task calendar` - Calendar with due tasks
- `task stats` - Task statistics
- `task colors` - Show all colors
- `task columns` - Show all columns
- `task commands` - List all commands
- `task help` - Show help

## Common Write Commands

### Create
- `task add <description> <mods>` - Add new task
- `task log <description> <mods>` - Add completed task

### Modify
- `task <filter> modify <mods>` - Modify tasks
- `task <filter> append <text>` - Append to description
- `task <filter> prepend <text>` - Prepend to description
- `task <filter> annotate <text>` - Add annotation
- `task <filter> denotate <pattern>` - Remove annotation

### State Changes
- `task <filter> done` - Mark complete
- `task <filter> delete` - Delete task
- `task <filter> start` - Start task
- `task <filter> stop` - Stop task

### Other
- `task <filter> duplicate <mods>` - Duplicate task
- `task <filter> edit` - Edit in text editor
- `task undo` - Undo last action
- `task sync` - Synchronize with server

## Common Patterns

### Basic Task
```bash
task add Buy milk
task add Buy milk due:tomorrow priority:H
task add Buy milk project:Home +errands
```

### Filtering
```bash
task project:Home list
task +work priority:H list
task due.before:eom list
task /pattern/ list
```

### Modifying
```bash
task 42 modify priority:H
task 42 modify +urgent
task 42 modify due:tomorrow
task 42 done
```

### Multiple Tasks
```bash
task 1,3,5-10 modify priority:H
task 1-5 delete
task +work done
```

### Dependencies
```bash
task add Write report depends:42
task 42 modify depends:5,7,9
```

### Recurrence
```bash
task add Pay rent due:1st recur:monthly until:2025-12-31
task add Exercise due:tomorrow recur:daily
```

### Contexts
```bash
task context define work project:Work
task context work
task context none
```

### Searching
```bash
task /bug/ list                    # Description contains 'bug'
task description.has:bug list      # Same as above
task project.startswith:Home list  # Project starts with 'Home'
```

### Complex Filters
```bash
task '( project:Home or +personal )' and priority:H list
task due.before:eom and -BLOCKED list
```

### Reports and Export
```bash
task export > tasks.json
task import tasks.json
task <filter> ids              # Get task IDs
task <filter> uuids            # Get task UUIDs
```

## Attribute Shortcuts

### Priority
- `priority:H` - High
- `priority:M` - Medium
- `priority:L` - Low
- `priority:` - No priority

### Status
- `status:pending`
- `status:completed`
- `status:deleted`
- `status:waiting`

### Dates
- `due:today`
- `due:tomorrow`
- `due:eow` - End of week
- `due:eom` - End of month
- `scheduled:friday`
- `wait:later`

### Common Filters
- `+TAG` - Has tag
- `-TAG` - Doesn't have tag
- `project:NAME` - Has project
- `description.contains:TEXT` - Description contains text

## Configuration
```bash
task config <name> <value>     # Set config
task config <name>             # Remove config
task show <substring>          # Show config
```

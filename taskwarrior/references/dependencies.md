# Taskwarrior Dependencies

## depends Attribute

Tasks can depend on other tasks using the `depends` attribute.

### Adding Dependencies
```bash
# Single dependency by ID
task add Code feature depends:42

# Multiple dependencies
task add Deploy depends:5,7,9

# By UUID
task add Task depends:ebeeab00-ccf8-464b-8b58-f7f2d606edfb
```

### Removing Dependencies
```bash
# Remove specific dependency
task 42 modify depends:-5

# Remove all dependencies
task 42 modify depends:
```

### Modifying Dependencies
```bash
# Add to existing
task 42 modify depends:10,11

# Replace all
task 42 modify depends:1,2,3
```

## Dependency Relationships

### Blocked Tasks
A task with dependencies is **blocked** until all dependencies are completed.
- Cannot start blocked tasks (by convention)
- Appears in `task blocked` report
- Has virtual tag `+BLOCKED`

```bash
task +BLOCKED list              # Show blocked tasks
task 42 info                    # Shows what blocks it
```

### Blocking Tasks
A task that other tasks depend on is **blocking**.
- Shows in `task blocking` report
- Has virtual tag `+BLOCKING`
- Indicates tasks depend on its completion

```bash
task +BLOCKING list             # Show blocking tasks
```

## Virtual Tags

### +BLOCKED
Task has unfinished dependencies:
```bash
task +BLOCKED list
task -BLOCKED list              # Same as +UNBLOCKED
```

### +BLOCKING
Task is blocking other tasks:
```bash
task +BLOCKING list
```

### +UNBLOCKED
Task has no blocking dependencies:
```bash
task +UNBLOCKED list
task -BLOCKED list              # Equivalent
```

## Dependency Chain Examples

### Simple Chain
```bash
# Create tasks
task add Design project:Website
task add Code project:Website depends:1
task add Test project:Website depends:2
task add Deploy project:Website depends:3
```

### Multiple Dependencies
```bash
# Task depends on multiple others
task add Integration depends:5,6,7

# Multiple tasks depend on one
task add Foundation
task add Wall1 depends:1
task add Wall2 depends:1
task add Roof depends:2,3
```

### Viewing Dependencies
```bash
# Show what blocks a task
task 42 info

# Show all blocked tasks
task +BLOCKED list

# Show all tasks blocking others
task +BLOCKING list

# Show unblocked tasks
task +UNBLOCKED list
```

## Dependency Management

### Checking Status
```bash
task blocked                    # All blocked tasks
task blocking                   # All tasks blocking others
task unblocked                  # All unblocked tasks
task 42 info                    # Shows dependencies
```

### Modifying Chains
```bash
# Add dependency to existing task
task 42 modify depends:10

# Remove from chain
task 42 modify depends:-5

# Clear all dependencies
task 42 modify depends:
```

### Completing Dependencies
When you complete a blocking task, dependent tasks become unblocked:
```bash
task 5 done
# Tasks that depended on 5 are now unblocked
```

## Urgency Impact

Dependencies affect urgency calculation:
- **+BLOCKING** increases urgency (coefficient: 8.0)
- **+BLOCKED** decreases urgency (coefficient: -5.0)

```bash
# Blocking tasks are more urgent
task +BLOCKING list

# Blocked tasks are less urgent
task +BLOCKED list
```

## Best Practices

1. **Use IDs carefully**: IDs change; UUIDs are permanent
2. **Check before completing**: Verify nothing depends on task
3. **View chains**: Use `task info` to understand relationships
4. **Avoid circular dependencies**: Task A depends on B, B depends on A
5. **Keep chains manageable**: Too many dependencies become complex

## Common Workflows

### Project Dependencies
```bash
task add Requirements project:App
task add Design project:App depends:1
task add Backend project:App depends:2
task add Frontend project:App depends:2
task add Testing project:App depends:3,4
task add Deploy project:App depends:5
```

### Review Workflow
```bash
task add Write document
task add Review document depends:1
task add Incorporate feedback depends:2
task add Publish depends:3
```

### Parallel Tasks
```bash
task add Setup infrastructure
task add Write code depends:1
task add Write tests depends:1
task add Integration depends:2,3
```

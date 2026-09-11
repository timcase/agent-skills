# Taskwarrior Urgency Formula

## Overview

Taskwarrior uses an urgency calculation to help prioritize tasks. The urgency value is a weighted sum of various task attributes, allowing you to focus on the most important work. Tasks with higher urgency values appear first in most reports.

The urgency system is completely configurable - you can adjust coefficients, add custom rules for specific projects or tags, and even disable components entirely.

## The Formula

The urgency value for a task is calculated as:

**Urgency = Σ (component_value × coefficient)**

Where each component contributes based on whether the task has that attribute and how it's valued.

## Default Coefficients

| Component | Coefficient | Component Value | Description |
|-----------|-------------|-----------------|-------------|
| **next tag** | 15.0 | 1.0 if tagged `+next` | Special high-priority tag |
| **due** | 12.0 | 0.2 to 1.0 | Based on how overdue/upcoming |
| **blocking** | 8.0 | 1.0 if blocking other tasks | Task blocks others |
| **priority H** | 6.0 | 1.0 if priority:H | High priority |
| **scheduled** | 5.0 | 1.0 if scheduled < now | Past scheduled time |
| **active** | 4.0 | 1.0 if started | Task has been started |
| **priority M** | 3.9 | 1.0 if priority:M | Medium priority |
| **age** | 2.0 | 0.0 to 1.0 | Based on age/age_max |
| **priority L** | 1.8 | 1.0 if priority:L | Low priority |
| **annotations** | 1.0 | 0.0 to 1.0 | Based on annotation count |
| **tags** | 1.0 | 0.0 to 1.0 | Based on number of tags |
| **project** | 1.0 | 1.0 if has project | Task has a project |
| **waiting** | -3.0 | 1.0 if waiting | Reduces urgency |
| **blocked** | -5.0 | 1.0 if blocked | Reduces urgency |

## Component Value Calculations

### Due Date (`urgency_due`)
The due date component uses a sophisticated algorithm:

- **≥ 7 days overdue**: 1.0 (maximum urgency)
- **-14 to +7 days**: Linear scale from 0.2 to 1.0
  - Formula: `((days_overdue + 14.0) * 0.8 / 21.0) + 0.2`
- **> 14 days in future**: 0.2 (minimum urgency)

### Age (`urgency_age`)
Age is calculated as a fraction of the maximum age:
- **Formula**: `age_in_days / urgency.age.max`
- **Default max age**: 365 days
- **Range**: 0.0 (new task) to 1.0 (365+ days old)

### Annotations (`urgency_annotations`)
Based on the number of annotations:
- **0 annotations**: 0.0
- **1 annotation**: 0.8
- **2 annotations**: 0.9
- **3+ annotations**: 1.0

### Tags (`urgency_tags`)
Based on the number of tags (excluding special tags):
- **0 tags**: 0.0
- **1 tag**: 0.8
- **2 tags**: 0.9
- **3+ tags**: 1.0

### Binary Components
These components are either 0.0 or 1.0:
- **project**: 1.0 if task has a project, 0.0 otherwise
- **active**: 1.0 if task is started (`task start`), 0.0 otherwise
- **scheduled**: 1.0 if scheduled time has passed, 0.0 otherwise
- **waiting**: 1.0 if task status is waiting, 0.0 otherwise
- **blocked**: 1.0 if task is blocked by dependencies, 0.0 otherwise
- **blocking**: 1.0 if task blocks other tasks, 0.0 otherwise
- **priority**: 1.0 for the set priority level, 0.0 otherwise

## Example Calculations

### Example 1: "Get the milk due:tomorrow pro:Cookies +home +groceries"

| Component | Value | Coefficient | Contribution |
|-----------|-------|-------------|--------------|
| project | 1.0 | 1.0 | 1.0 |
| tags (2) | 0.9 | 1.0 | 0.9 |
| due (tomorrow) | 0.719 | 12.0 | 8.63 |
| age (new) | ~0.003 | 2.0 | ~0.006 |
| **Total** | | | **≈10.53** |

### Example 2: "Review code priority:H +work" (1 week old)

| Component | Value | Coefficient | Contribution |
|-----------|-------|-------------|--------------|
| priority H | 1.0 | 6.0 | 6.0 |
| tags (1) | 0.8 | 1.0 | 0.8 |
| age (7 days) | 0.019 | 2.0 | 0.038 |
| **Total** | | | **≈6.84** |

### Example 3: "Blocked task depends:123 +waiting"

| Component | Value | Coefficient | Contribution |
|-----------|-------|-------------|--------------|
| tags (1) | 0.8 | 1.0 | 0.8 |
| blocked | 1.0 | -5.0 | -5.0 |
| age (assume 30 days) | 0.082 | 2.0 | 0.164 |
| **Total** | | | **≈-4.04** |

## Customization Options

### Modifying Default Coefficients
```bash
# Increase importance of due dates
task config urgency.due.coefficient 15.0

# Disable age-based urgency
task config urgency.age.coefficient 0.0

# Make blocked tasks even less urgent
task config urgency.blocked.coefficient -10.0
```

### Project-Specific Urgency
```bash
# Make "Work" project tasks more urgent
task config urgency.user.project.Work.coefficient 5.0

# Reduce urgency for "Someday" project
task config urgency.user.project.Someday.coefficient -2.0
```

### Tag-Specific Urgency
```bash
# Make tasks tagged "important" more urgent
task config urgency.user.tag.important.coefficient 10.0

# Reduce urgency for "research" tasks
task config urgency.user.tag.research.coefficient -1.0
```

### Custom UDA Coefficients
```bash
# If you have a custom "effort" UDA with values S/M/L
task config urgency.uda.effort.S.coefficient 0.1
task config urgency.uda.effort.M.coefficient 0.5
task config urgency.uda.effort.L.coefficient 1.0
```

## Special Features

### Urgency Inheritance
Set `urgency.inherit=1` to make tasks inherit the highest urgency value from tasks they block:
```bash
task config urgency.inherit 1
```

### Age Maximum
Control how age affects urgency:
```bash
# Tasks reach maximum age urgency after 180 days instead of 365
task config urgency.age.max 180

# Disable age ceiling (tasks can become infinitely urgent with age)
task config urgency.age.max 0
```

### Viewing Urgency Breakdown
To see how urgency is calculated for a specific task:
```bash
task <id> info
```

The info command shows the urgency value and breaks down each contributing component.

## Configuration Variables

All urgency-related configuration variables:

```
urgency.active.coefficient=4.0
urgency.age.coefficient=2.0
urgency.age.max=365
urgency.annotations.coefficient=1.0
urgency.blocked.coefficient=-5.0
urgency.blocking.coefficient=8.0
urgency.due.coefficient=12.0
urgency.inherit=0
urgency.project.coefficient=1.0
urgency.scheduled.coefficient=5.0
urgency.tags.coefficient=1.0
urgency.uda.priority.H.coefficient=6.0
urgency.uda.priority.L.coefficient=1.8
urgency.uda.priority.M.coefficient=3.9
urgency.user.tag.next.coefficient=15.0
urgency.waiting.coefficient=-3.0
```

## Tips for Tuning Urgency

1. **Start with defaults** - The default coefficients work well for most users
2. **Adjust gradually** - Small changes can have big effects on task ordering
3. **Use negative coefficients** - Reduce urgency for low-priority areas
4. **Monitor with reports** - Use `task next` and `task list` to see the effects
5. **Test with real tasks** - Create sample tasks to validate your coefficients
6. **Document your changes** - Keep track of customizations for consistency

The urgency system is one of Taskwarrior's most powerful features for task prioritization. Experiment with different coefficients to match your personal workflow and priorities.
# Project Field/Attribute Functionality in Taskwarrior

The project field is a core attribute in Taskwarrior that provides hierarchical organization of tasks.

## Key Features

### Hierarchical Structure
Projects support a dot-notation hierarchy (e.g., `home.garden`, `work.reports.quarterly`):
- Parent projects automatically track tasks from their sub-projects
- The hierarchy is visualized with indentation in reports
- The dot (`.`) is the only supported delimiter for project hierarchy

### Display Styles
The project column supports three display styles (`ColProject.cpp:46`):
- **full**: Shows complete project path (e.g., `home.garden`)
- **parent**: Shows only top-level project (e.g., `home` from `home.garden`)  
- **indented**: Shows hierarchy with indentation

### Project Commands
- `task projects` - Lists all projects with task counts (`CmdProjects.cpp`)
- `task summary` - Shows project summary with pending/completed counts
- `task _projects` - Internal command for project completion

### Filtering Options
Projects support various filter modifiers (`CmdHelp.cpp:125-128`):
- `project.none:` - Tasks without a project
- `project.any:` - Tasks with any project
- `project.is:x` - Exact match for project x
- `project.isnt:x` - Not matching project x
- `project.has:x` - Pattern match
- `project.hasnt:x` - Pattern non-match

### Project Progress Tracking
Automatic calculation of project completion (`feedback.cpp:188`):
- Shows "Project X is Y% complete (Z tasks remaining)"
- Progress aggregates up the hierarchy

### Configuration Options
- `default.project` - Default project for new tasks
- `urgency.project.coefficient` - Urgency weight for projects
- `urgency.user.project.<name>.coefficient` - Custom urgency per project
- `list.all.projects` - Include completed tasks in project listings
- `color.project.none` - Color for tasks without projects

### Helper Functions
Project hierarchy utilities (`util.cpp`):
- `indentProject()` - Formats project hierarchy with indentation
- `extractParents()` - Extracts all parent projects from a path

### Project Sorting
Projects are sorted hierarchically in reports (`sort.cpp`):
- Parent projects appear before their children
- Task counts aggregate up the hierarchy
- Hierarchical sorting maintains project relationships

## Implementation Details

The project system uses dot-notation exclusively for hierarchy. While the utility functions accept a delimiter parameter, all calls throughout the codebase use the dot character, and there is no configuration option to change this delimiter.

Projects integrate with Taskwarrior's urgency calculation system, allowing both global and per-project urgency coefficients to influence task prioritization.
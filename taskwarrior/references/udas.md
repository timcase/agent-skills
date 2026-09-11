# User Defined Attributes (UDA) in Taskwarrior

## UDA Configuration Attributes

Each UDA can be configured with the following attributes:

### 1. uda.<name>.type (REQUIRED)
- **Valid values:** `string`, `numeric`, `date`, `duration`, `uuid`
- **Description:** Defines the data type for the UDA

### 2. uda.<name>.label
- **Default:** Uses the UDA name if not specified
- **Description:** Sets the display label for the UDA in reports

### 3. uda.<name>.values
- **Applicable to:** `string` type UDAs only
- **Format:** Comma-separated list of allowed values
- **Note:** Order matters - defines sort order from highest to lowest
- **Example:** `huge,large,medium,small,trivial,` (note the trailing comma allows empty values)

### 4. uda.<name>.default
- **Description:** Sets the default value when a task is created without specifying this UDA
- **Validation:** Must be a valid value according to the UDA's type and allowed values

### 5. uda.<name>.indicator
- **Description:** Character/string to show in the indicator column
- **Default:** `U`

## UDA Type Details

### string
- Stores text values
- Can have restricted values via `.values` attribute
- Values are sorted in the order specified in `.values`

### numeric
- Stores numeric values (integers or decimals)
- Validates input as numeric
- Can be used for sorting numerically

### date
- Stores date values
- Follows configured dateformat
- Validates input as valid date

### duration
- Stores time duration values
- Accepts formats like: `1day`, `33min+18s`
- Stored internally in ISO 8601 duration format (e.g., `P1D`, `PT33M18S`)

### uuid
- Stores UUID values
- Used for referencing other tasks or entities

## Built-in UDA: Priority

Taskwarrior includes one built-in UDA:

**priority**
- Type: `string`
- Label: `Priority`
- Values: `H,M,L,` (High, Medium, Low, or empty)
- Urgency coefficients:
  - H: 6.0
  - M: 3.9
  - L: 1.8

## UDA Urgency Configuration

UDAs can affect task urgency:
- **urgency.uda.<name>.coefficient** - Coefficient when UDA is present
- **urgency.uda.<name>.<value>.coefficient** - Coefficient for specific values

## UDA Color Configuration

UDAs can have custom colors:
- **color.uda.<name>** - Color when UDA is present
- **color.uda.<name>.<value>** - Color for specific values
- **color.uda.<name>.none** - Color when UDA is absent

## UDA Orphans

UDAs that exist in task data but are no longer defined in configuration are called "orphans". They are preserved but cannot be modified.

## Example UDA Configurations

### Example 1: Estimate UDA
```
uda.estimate.type=string
uda.estimate.label=Size Estimate
uda.estimate.values=huge,large,medium,small,trivial,
```

### Example 2: Bug ID UDA
```
uda.bugid.type=numeric
uda.bugid.label=Bug ID
```

### Example 3: Due Date Extension UDA
```
uda.review.type=date
uda.review.label=Review Date
```

### Example 4: Time Estimate UDA
```
uda.duration.type=duration
uda.duration.label=Time Estimate
uda.duration.default=1h
```
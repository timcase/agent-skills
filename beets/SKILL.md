---
name: beets
description: "Manage music libraries with beets CLI. Use for: importing music, fixing metadata/tags, querying the library, organizing files, fetching album art, analyzing ReplayGain, or configuring beets. Triggers on 'beet', 'import music', or 'fix tags'."
---

# Beets CLI Skill

Beets (CLI: `beet`) organizes music libraries, fixes metadata, and manages music files.

**Installed version:** 2.0.0
**Active plugins:** fetchart, replaygain, today

## Quick Reference

| Task | Command |
|------|---------|
| Import music | `beet import /path/to/music` |
| Search library | `beet list artist:name` |
| Edit metadata | `beet modify field=value query` |
| Move files | `beet move -d /dest query` |
| Fetch album art | `beet fetchart query` |
| Update from files | `beet update query` |
| Write tags to files | `beet write query` |
| Remove items | `beet remove query` |
| Library stats | `beet stats` |
| Show config | `beet config` |

## Query Syntax

Queries filter tracks or albums:

```bash
# Field match
beet list artist:Beatles
beet list album:"Dark Side"
beet list genre:jazz year:2020

# Album-level queries (use -a flag)
beet list -a albumartist:Radiohead

# Substring match (default)
beet list title:love          # matches any title containing "love"

# Exact match
beet list year::2023          # exactly 2023

# Path output
beet list -p artist:Bach      # print file paths

# Custom format
beet list -f '$artist - $title ($year)' genre:classical
```

## Importing Music

```bash
# Standard import (interactive, copies files)
beet import /path/to/new/music

# Move files instead of copy
beet import -m /path/to/music

# Non-interactive (auto-accept best match)
beet import -q /path/to/music

# Import without changing tags
beet import -A /path/to/music

# Preview what would be imported
beet import --pretend /path/to/music

# Re-tag already imported items
beet import -L query
```

## Modifying Metadata

```bash
# Set field on matching tracks
beet modify genre=Jazz artist:Miles

# Set multiple fields
beet modify genre=Jazz year=1959 album:"Kind of Blue"

# Modify albums (not individual tracks)
beet modify -a label="Columbia" albumartist:Miles

# Skip confirmation prompt
beet modify -y genre=Electronic artist:Aphex

# Modify and move files to reflect new metadata
beet modify -m year=1959 album:"Kind of Blue"
```

## Moving & Organizing Files

```bash
# Move matching items to destination
beet move -d /new/path artist:name

# Copy instead of move
beet move -c -d /backup artist:name

# Preview moves without executing
beet move -p -d /new/path artist:name

# Export (copy without updating DB paths)
beet move -e -d /export/path genre:Classical
```

## Fetching Album Art

```bash
# Fetch art for all albums
beet fetchart

# Fetch art for specific albums
beet fetchart albumartist:Radiohead

# Force re-fetch even if art exists
beet fetchart -f artist:name
```

## ReplayGain Analysis

```bash
# Analyze all tracks
beet replaygain

# Analyze specific tracks
beet replaygain artist:name

# Force re-analysis
beet replaygain -f query
```

## Updating & Writing Tags

```bash
# Update library from changed files on disk
beet update

# Update specific items
beet update artist:name

# Preview what would change
beet update -p

# Write beets metadata back to file tags
beet write artist:name
```

## Removing Items

```bash
# Remove from library (keeps files)
beet remove artist:name

# Remove and delete files
beet remove -d artist:name

# Remove albums
beet remove -a albumartist:name
```

## Configuration

```bash
# Show current config
beet config

# Edit config file
beet config -e

# Show config file paths
beet config -p

# Show all fields available for queries
beet fields
```

## Common Fields

Key item fields: `title`, `artist`, `album`, `albumartist`, `year`, `genre`, `track`, `disc`, `label`, `country`, `format`, `bitrate`, `path`, `added`

Key album fields: `album`, `albumartist`, `year`, `genre`, `label`, `country`, `style`, `catalognum`

## Tips

- Always use `-p` / `--pretend` to preview destructive operations before running them
- Use `beet list -p query` to verify what a query matches before modifying
- Queries are case-insensitive and match substrings by default
- Use `-a` flag on `list`/`modify`/`move`/`remove` to operate at album level
- For complex imports, use `-t` (timid) to confirm every action

#!/usr/bin/env bash
set -euo pipefail

DEST_DEFAULT="$HOME/.claude/skills"
CODEX_DEST_DEFAULT="$HOME/.codex/skills"

DEST="$DEST_DEFAULT"
FORCE="0"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="1password"

die() { echo "Error: $*" >&2; exit 1; }
info() { echo "==> $*" >&2; }

usage() {
  cat >&2 <<USAGE
Usage: $0 [options]

Symlinks this local skill directory into:
- ${DEST_DEFAULT}/$SKILL_NAME
- ${CODEX_DEST_DEFAULT}/$SKILL_NAME

Options:
  --dest <dir>   Primary destination base dir (default: $DEST_DEFAULT)
                 Also installs to $CODEX_DEST_DEFAULT
  --force        Replace existing destinations
  -h, --help     Show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dest)
      [[ $# -ge 2 ]] || die "--dest requires a value"
      DEST="$2"; shift 2;;
    --force)
      FORCE="1"; shift 1;;
    -h|--help)
      usage; exit 0;;
    *)
      die "Unknown argument: $1 (use --help)";;
  esac
done

SOURCE_PATH="$SCRIPT_DIR"
[[ -f "$SOURCE_PATH/SKILL.md" ]] || die "SKILL.md not found in $SOURCE_PATH"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

need_cmd mkdir
need_cmd ln
need_cmd rm

TARGET_BASES=("$DEST" "$CODEX_DEST_DEFAULT")
declare -A seen=()
UNIQUE_TARGET_BASES=()
for base in "${TARGET_BASES[@]}"; do
  [[ -n "${seen[$base]:-}" ]] && continue
  seen["$base"]=1
  UNIQUE_TARGET_BASES+=("$base")
done

install_symlink() {
  local base dest_path
  for base in "${UNIQUE_TARGET_BASES[@]}"; do
    mkdir -p "$base"
    dest_path="$base/$SKILL_NAME"

    if [[ -e "$dest_path" || -L "$dest_path" ]]; then
      if [[ "$FORCE" == "1" ]]; then
        info "Removing existing destination: $dest_path"
        rm -rf "$dest_path"
      else
        die "Destination already exists: $dest_path (use --force to replace)"
      fi
    fi

    info "Linking $SOURCE_PATH -> $dest_path"
    ln -s "$SOURCE_PATH" "$dest_path"
  done

  info "Installed symlinks for $SKILL_NAME to: ${UNIQUE_TARGET_BASES[*]}"
}

install_symlink
info "Done."

#!/usr/bin/env bash
set -euo pipefail

# install.sh
# Installs the "doctl" skill from timcase/agent-skills into ~/.claude/skills/doctl
#
# Behavior:
# - Default (recommended): clone repo once into ~/.claude/skills/agent-skills and symlink doctl
# - Supports --method=archive (no clone; streams folder via git archive)
# - Supports --force to replace existing destination
#
# Usage:
#   ./install.sh
#   ./install.sh --force
#   ./install.sh --method=archive
#   ./install.sh --dest ~/.claude/skills
#   ./install.sh --repo https://github.com/timcase/agent-skills.git --path doctl
#
# After install (clone method):
#   cd ~/.claude/skills/agent-skills && git pull

REPO_DEFAULT="https://github.com/timcase/agent-skills.git"
PATH_DEFAULT="doctl"
DEST_DEFAULT="$HOME/.claude/skills"
METHOD_DEFAULT="clone" # clone | archive

REPO="$REPO_DEFAULT"
SUBPATH="$PATH_DEFAULT"
DEST="$DEST_DEFAULT"
METHOD="$METHOD_DEFAULT"
FORCE="0"

die() { echo "Error: $*" >&2; exit 1; }
info() { echo "==> $*" >&2; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

usage() {
  cat >&2 <<EOF
Usage: $0 [options]

Options:
  --repo <url>          Repo URL (default: $REPO_DEFAULT)
  --path <subdir>       Subdirectory in repo to install (default: $PATH_DEFAULT)
  --dest <dir>          Destination base dir (default: $DEST_DEFAULT)
  --method <clone|archive>
                        Install method (default: $METHOD_DEFAULT)
  --force               Replace existing destination (~/.claude/skills/<path>)
  -h, --help            Show this help

Examples:
  $0
  $0 --force
  $0 --method=archive
  $0 --dest ~/.claude/skills
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      [[ $# -ge 2 ]] || die "--repo requires a value"
      REPO="$2"; shift 2;;
    --path)
      [[ $# -ge 2 ]] || die "--path requires a value"
      SUBPATH="$2"; shift 2;;
    --dest)
      [[ $# -ge 2 ]] || die "--dest requires a value"
      DEST="$2"; shift 2;;
    --method)
      [[ $# -ge 2 ]] || die "--method requires a value"
      METHOD="$2"; shift 2;;
    --method=*)
      METHOD="${1#*=}"; shift 1;;
    --force)
      FORCE="1"; shift 1;;
    -h|--help)
      usage; exit 0;;
    *)
      die "Unknown argument: $1 (use --help)";;
  esac
done

[[ "$METHOD" == "clone" || "$METHOD" == "archive" ]] || die "--method must be clone or archive"

need_cmd mkdir
need_cmd rm
need_cmd ln
need_cmd git

mkdir -p "$DEST"

# Normalize destination folder name based on SUBPATH leaf
# e.g. "skills/doctl" for "doctl", or "skills/foo" for "tools/foo"
LEAF="$(basename "$SUBPATH")"
DEST_PATH="$DEST/$LEAF"

remove_existing_dest_if_needed() {
  if [[ -e "$DEST_PATH" || -L "$DEST_PATH" ]]; then
    if [[ "$FORCE" == "1" ]]; then
      info "Removing existing destination: $DEST_PATH"
      rm -rf "$DEST_PATH"
    else
      die "Destination already exists: $DEST_PATH (use --force to replace)"
    fi
  fi
}

install_via_clone_and_symlink() {
  local repo_dir="$DEST/agent-skills"

  if [[ -d "$repo_dir/.git" ]]; then
    info "Repo already present at $repo_dir"
    info "Updating repo (git fetch)..."
    git -C "$repo_dir" fetch --prune --tags >/dev/null
  else
    info "Cloning repo into $repo_dir"
    git clone "$REPO" "$repo_dir" >/dev/null
  fi

  # Verify subpath exists inside repo
  [[ -d "$repo_dir/$SUBPATH" ]] || die "Subdirectory not found in repo: $SUBPATH"

  remove_existing_dest_if_needed

  info "Linking $repo_dir/$SUBPATH -> $DEST_PATH"
  ln -s "$repo_dir/$SUBPATH" "$DEST_PATH"

  info "Installed via clone+symlink."
  info "To update later: cd \"$repo_dir\" && git pull"
}

install_via_git_archive() {
  need_cmd tar

  remove_existing_dest_if_needed
  mkdir -p "$DEST_PATH"

  info "Installing via git archive (no local clone): $REPO:$SUBPATH"
  # Streams just the folder contents into DEST_PATH
  # Note: This installs files *inside* DEST_PATH, not DEST_PATH/<leaf>
  git archive --remote="$REPO" "HEAD:$SUBPATH" | tar -x -C "$DEST_PATH"

  info "Installed via git archive."
  info "To update later, re-run this script with --method=archive --force"
}

case "$METHOD" in
  clone) install_via_clone_and_symlink;;
  archive) install_via_git_archive;;
esac

info "Done."

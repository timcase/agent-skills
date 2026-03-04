#!/usr/bin/env bash
set -euo pipefail

# install.sh
# Installs the "s3cmd" skill from timcase/agent-skills into:
# - ~/.claude/skills/s3cmd (default destination family)
# - ~/.codex/skills/s3cmd  (always also installed)
#
# Behavior:
# - Default (recommended): clone repo once into ~/.claude/skills/agent-skills and symlink gh-cli
# - Supports --method=archive (no clone; streams folder via git archive)
# - Supports --force to replace existing destination
#
# Usage:
#   ./install.sh
#   ./install.sh --force
#   ./install.sh --method=archive
#   ./install.sh --dest ~/.claude/skills
#   ./install.sh --repo https://github.com/timcase/agent-skills.git --path s3cmd
#
# After install (clone method):
#   cd ~/.claude/skills/agent-skills && git pull

REPO_DEFAULT="https://github.com/timcase/agent-skills.git"
PATH_DEFAULT="s3cmd"
DEST_DEFAULT="$HOME/.claude/skills"
CODEX_DEST_DEFAULT="$HOME/.codex/skills"
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
  --dest <dir>          Primary destination base dir (default: $DEST_DEFAULT)
                        Also installs to $CODEX_DEST_DEFAULT
  --method <clone|archive>
                        Install method (default: $METHOD_DEFAULT)
  --force               Replace existing destinations in both target base dirs
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

declare -a TARGET_BASES=("$DEST" "$CODEX_DEST_DEFAULT")
declare -A _SEEN=()
declare -a UNIQUE_TARGET_BASES=()
for base in "${TARGET_BASES[@]}"; do
  [[ -n "${_SEEN[$base]:-}" ]] && continue
  _SEEN["$base"]=1
  UNIQUE_TARGET_BASES+=("$base")
done

# Normalize destination folder name based on SUBPATH leaf
# e.g. "skills/gh-cli" for "gh-cli", or "skills/foo" for "tools/foo"
LEAF="$(basename "$SUBPATH")"

remove_existing_dest_if_needed() {
  local dest_path="$1"
  if [[ -e "$dest_path" || -L "$dest_path" ]]; then
    if [[ "$FORCE" == "1" ]]; then
      info "Removing existing destination: $dest_path"
      rm -rf "$dest_path"
    else
      die "Destination already exists: $dest_path (use --force to replace)"
    fi
  fi
}

install_via_clone_and_symlink() {
  local base repo_dir dest_path
  for base in "${UNIQUE_TARGET_BASES[@]}"; do
    mkdir -p "$base"
    repo_dir="$base/agent-skills"
    dest_path="$base/$LEAF"

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

    remove_existing_dest_if_needed "$dest_path"

    info "Linking $repo_dir/$SUBPATH -> $dest_path"
    ln -s "$repo_dir/$SUBPATH" "$dest_path"
  done

  info "Installed via clone+symlink to: ${UNIQUE_TARGET_BASES[*]}"
  info "To update later: cd \"${UNIQUE_TARGET_BASES[0]}/agent-skills\" && git pull"
}

install_via_git_archive() {
  need_cmd tar

  local base dest_path
  for base in "${UNIQUE_TARGET_BASES[@]}"; do
    mkdir -p "$base"
    dest_path="$base/$LEAF"
    remove_existing_dest_if_needed "$dest_path"
    mkdir -p "$dest_path"

    info "Installing via git archive (no local clone): $REPO:$SUBPATH -> $dest_path"
    # Streams just the folder contents into DEST_PATH
    # Note: This installs files *inside* DEST_PATH, not DEST_PATH/<leaf>
    git archive --remote="$REPO" "HEAD:$SUBPATH" | tar -x -C "$dest_path"
  done

  info "Installed via git archive to: ${UNIQUE_TARGET_BASES[*]}"
  info "To update later, re-run this script with --method=archive --force"
}

case "$METHOD" in
  clone) install_via_clone_and_symlink;;
  archive) install_via_git_archive;;
esac

info "Done."

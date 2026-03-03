#!/usr/bin/env bash
set -euo pipefail

# install.sh
# Installs all skills in this repository by invoking each skill's installer.
#
# Usage:
#   ./install.sh
#   ./install.sh --force
#   ./install.sh --method=archive
#   ./install.sh --dest ~/.claude/skills
#   ./install.sh --repo https://github.com/timcase/agent-skills.git

REPO_DEFAULT="https://github.com/timcase/agent-skills.git"
DEST_DEFAULT="$HOME/.claude/skills"
METHOD_DEFAULT="clone" # clone | archive

REPO="$REPO_DEFAULT"
DEST="$DEST_DEFAULT"
METHOD="$METHOD_DEFAULT"
FORCE="0"

SKILLS=("gh-cli" "doctl" "s3cmd")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() { echo "Error: $*" >&2; exit 1; }
info() { echo "==> $*" >&2; }

usage() {
  cat >&2 <<EOF
Usage: $0 [options]

Installs all skills: gh-cli, doctl, s3cmd

Options:
  --repo <url>          Repo URL passed to each skill installer (default: $REPO_DEFAULT)
  --dest <dir>          Destination base dir (default: $DEST_DEFAULT)
  --method <clone|archive>
                        Install method (default: $METHOD_DEFAULT)
  --force               Replace existing destinations
  -h, --help            Show this help

Examples:
  $0
  $0 --force
  $0 --method=archive
  $0 --dest ~/.claude/skills
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      [[ $# -ge 2 ]] || die "--repo requires a value"
      REPO="$2"; shift 2;;
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

COMMON_ARGS=(--repo "$REPO" --dest "$DEST" --method "$METHOD")
if [[ "$FORCE" == "1" ]]; then
  COMMON_ARGS+=(--force)
fi

for skill in "${SKILLS[@]}"; do
  installer="$SCRIPT_DIR/$skill/install.sh"
  [[ -f "$installer" ]] || die "Missing installer: $installer"
  info "Installing skill: $skill"
  "$installer" "${COMMON_ARGS[@]}"
done

info "All skills installed."

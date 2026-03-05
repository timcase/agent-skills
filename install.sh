#!/usr/bin/env bash
set -euo pipefail

# install.sh
# Installs all skills in this repository by invoking each skill's installer.
# Each installer symlinks local skill directories into both:
# - ~/.claude/skills (or --dest override)
# - ~/.codex/skills
#
# Usage:
#   ./install.sh
#   ./install.sh --force
#   ./install.sh --dest ~/.claude/skills

DEST_DEFAULT="$HOME/.claude/skills"
DEST="$DEST_DEFAULT"
FORCE="0"

SKILLS=("gh-cli" "doctl" "s3cmd" "beets" "sentry" "cinc-client" "knife" "knup" "newrelic" "proton-pass" "postmark")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() { echo "Error: $*" >&2; exit 1; }
info() { echo "==> $*" >&2; }

usage() {
  cat >&2 <<USAGE
Usage: $0 [options]

Installs all skills: ${SKILLS[*]}

Options:
  --dest <dir>    Primary destination base dir (default: $DEST_DEFAULT)
                  Also installs to ~/.codex/skills
  --force         Replace existing destinations
  -h, --help      Show this help
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

COMMON_ARGS=(--dest "$DEST")
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

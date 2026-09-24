#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
SCRIPT_DIR="$REPO_ROOT/scripts"
HOME_DIR=${HOME:?HOME must be set}
CHECK_ONLY=${CHECK_ONLY:-0}

info() { printf '\n==> %s\n' "$*"; }
warn() { printf 'Warning: %s\n' "$*" >&2; }
fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
ask_yes_no() {
  local prompt=$1 default=${2:-Y} answer
  [[ -t 0 ]] || return 1
  if [[ $default == Y ]]; then read -r -p "$prompt [Y/n] " answer; answer=${answer:-Y};
  else read -r -p "$prompt [y/N] " answer; answer=${answer:-N}; fi
  [[ $answer =~ ^([Yy]|[Yy][Ee][Ss])$ ]]
}
backup_file() {
  local file=$1 backup
  [[ -e $file ]] || return 0
  backup="$file.backup.$(date -u +%Y%m%dT%H%M%SZ)"
  local suffix=0
  while [[ -e $backup ]]; do
    suffix=$((suffix + 1))
    backup="$file.backup.$(date -u +%Y%m%dT%H%M%SZ).$suffix"
  done
  cp -p -- "$file" "$backup"
  printf 'Backed up %s to %s\n' "$file" "$backup"
}
run() {
  if [[ $CHECK_ONLY == 1 ]]; then printf '[check]'; printf ' %q' "$@"; printf '\n'; else "$@"; fi
}

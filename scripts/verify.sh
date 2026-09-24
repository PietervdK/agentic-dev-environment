#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
source "$SCRIPT_DIR/lib/platform.sh"
status=0
check() {
  local label=$1
  shift
  if "$@" >/dev/null 2>&1; then printf 'ok      %s\n' "$label";
  else printf 'missing %s\n' "$label"; status=1; fi
}
has_command() { command -v "$1" >/dev/null 2>&1; }
git_identity_available() {
  [[ -n $(git config --global --get user.name || true) &&
     -n $(git config --global --get user.email || true) ]]
}
verify() {
  read_platform && printf 'Platform: %s %s\n' "$PLATFORM" "$PLATFORM_VERSION" || { printf 'Platform: unsupported\n'; status=1; }
  check 'Git' has_command git
  check 'Git identity' git_identity_available
  check 'GitHub CLI' has_command gh
  check 'GitHub CLI authentication' gh auth status
  check 'SSH config' test -f "$HOME_DIR/.ssh/config"
  check 'GitHub SSH public key' test -f "$HOME_DIR/.ssh/github_ai_dev_ed25519.pub"
  if command -v ssh >/dev/null; then
    local result=''; result=$(ssh -o BatchMode=yes -T git@github.com 2>&1 || true)
    [[ $result == *'successfully authenticated'* ]] && printf 'ok      GitHub SSH authentication\n' || { printf 'missing GitHub SSH authentication\n'; status=1; }
  fi
  check 'Codex CLI' has_command codex
  check 'Codex AGENTS.md' test -f "$HOME_DIR/.codex/AGENTS.md"
  check 'Codex skills' test -d "$HOME_DIR/.codex/skills"
  check 'Codex references' test -d "$HOME_DIR/.codex/references"
  if command -v nix >/dev/null; then printf 'ok      Nix available\n'; else printf 'optional Nix unavailable\n'; fi
  return "$status"
}
[[ ${BASH_SOURCE[0]} != "$0" ]] || verify

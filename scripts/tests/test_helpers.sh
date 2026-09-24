#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
source "$ROOT/scripts/lib/platform.sh"
source "$ROOT/scripts/lib/common.sh"

test_platform_detection() {
  [[ $(detect_platform Ubuntu 24.04) == ubuntu ]]
  [[ $(detect_platform Debian 12) == debian ]]
  [[ $(detect_platform Fedora 41) == fedora ]]
  [[ $(detect_platform Alpine 3.20) == unsupported ]]
}

test_codex_install_path_is_added_for_current_process() {
  local tmp
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' RETURN
  mkdir -p "$tmp/.local/bin"
  printf '#!/bin/sh\nprintf codex-test\n' > "$tmp/.local/bin/codex"
  chmod 755 "$tmp/.local/bin/codex"
  (
    HOME_DIR=$tmp
    unset CODEX_INSTALL_DIR
    PATH=/usr/bin:/bin
    ensure_codex_path
    [[ $(command -v codex) == "$tmp/.local/bin/codex" ]]
    [[ $(codex --version) == codex-test ]]
  )
}

test_codex_sync_preserves_custom_file() {
  local tmp
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' RETURN
  mkdir -p "$tmp/home/.codex/skills" "$tmp/source/skills/example" \
    "$tmp/source/skills/.system/private" "$tmp/source/skills/example/__pycache__"
  printf 'custom\n' > "$tmp/home/.codex/AGENTS.md"
  printf 'managed\n' > "$tmp/source/AGENTS.md"
  printf 'skill\n' > "$tmp/source/skills/example/SKILL.md"
  printf 'runtime\n' > "$tmp/source/skills/.system/private/SKILL.md"
  printf 'cache\n' > "$tmp/source/skills/example/__pycache__/data.pyc"
  CODEX_SOURCE_DIR="$tmp/source" CODEX_HOME_DIR="$tmp/home/.codex" \
    bash "$ROOT/scripts/setup-codex.sh" --sync --non-interactive >/dev/null
  [[ $(cat "$tmp/home/.codex/AGENTS.md") == custom ]]
  [[ -f "$tmp/home/.codex/skills/example/SKILL.md" ]]
  [[ ! -e "$tmp/home/.codex/skills/.system" ]]
  [[ ! -e "$tmp/home/.codex/skills/example/__pycache__" ]]
}

test_ssh_block_is_idempotent() {
  local tmp
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' RETURN
  SSH_CONFIG="$tmp/config" SSH_KEY_PATH="$tmp/key" bash -c \
    'source "$1/scripts/setup-github.sh"; update_ssh_config' _ "$ROOT"
  printf 'Host work\n    HostName example.test\n\n' > "$tmp/config"
  SSH_CONFIG="$tmp/config" SSH_KEY_PATH="$tmp/key" bash -c \
    'source "$1/scripts/setup-github.sh"; update_ssh_config' _ "$ROOT"
  rg -q 'Host work' "$tmp/config"
  rg -q 'HostName example.test' "$tmp/config"
  cp "$tmp/config" "$tmp/first"
  SSH_CONFIG="$tmp/config" SSH_KEY_PATH="$tmp/key" bash -c \
    'source "$1/scripts/setup-github.sh"; update_ssh_config' _ "$ROOT"
  cmp "$tmp/first" "$tmp/config"
  rm -rf "$tmp"
}

test_check_mode_is_read_only() {
  local tmp
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' RETURN
  HOME="$tmp" XDG_STATE_HOME="$tmp/state" "$ROOT/setup.sh" --check >/dev/null 2>&1
  [[ -z $(find "$tmp" -mindepth 1 -print -quit) ]]
}

test_platform_detection
test_codex_install_path_is_added_for_current_process
test_codex_sync_preserves_custom_file
test_ssh_block_is_idempotent
test_check_mode_is_read_only
printf 'Bootstrap helper tests passed.\n'

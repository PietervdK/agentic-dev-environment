#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
CODEX_SOURCE_DIR=${CODEX_SOURCE_DIR:-$REPO_ROOT/codex}
CODEX_HOME_DIR=${CODEX_HOME_DIR:-$HOME_DIR/.codex}

sync_tree() {
  local src=$1 dst=$2
  [[ -d $src ]] || return 0
  [[ $CHECK_ONLY == 1 ]] || mkdir -p "$dst"
  while IFS= read -r -d '' from; do
    [[ $from != "$src/skills/.system" && $from != "$src/skills/.system/"* ]] || continue
    [[ $from != */__pycache__ && $from != */__pycache__/* && $from != *.pyc ]] || continue
    local rel="$from" target="$dst/${from#"$src"/}"
    if [[ -d $from ]]; then
      [[ $CHECK_ONLY == 1 ]] || mkdir -p "$target"
      continue
    fi
    if [[ -e $target ]] && ! cmp -s "$from" "$target"; then
      if [[ ${NON_INTERACTIVE:-0} == 1 ]] || ! ask_yes_no "Replace differing Codex file $target? A backup will be made." N; then
        warn "Preserving custom Codex file: $target"
        continue
      fi
      backup_file "$target"
    fi
    if [[ ! -e $target ]] || ! cmp -s "$from" "$target"; then
      [[ $CHECK_ONLY == 1 ]] && { printf 'Would install %s\n' "$target"; continue; }
      install -D -m 644 "$from" "$target"
    fi
  done < <(find "$src" -mindepth 1 \( -type d -o -type f \) -print0)
}
setup_codex() {
  [[ $CHECK_ONLY == 1 ]] || mkdir -p "$CODEX_HOME_DIR"
  sync_tree "$CODEX_SOURCE_DIR" "$CODEX_HOME_DIR"
  if [[ ${1:-} == --sync ]]; then return; fi
  [[ $CHECK_ONLY == 1 ]] && return
  ensure_codex_path
  if command -v codex >/dev/null; then codex --version; else printf 'Codex CLI is not installed.\n'; fi
  if ! command -v codex >/dev/null && ask_yes_no 'Install Codex CLI using the official OpenAI installer?' Y; then
    local installer
    installer=$(mktemp)
    trap 'rm -f "$installer"' RETURN
    if ! curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 \
      'https://chatgpt.com/codex/install.sh' --output "$installer"; then
      warn 'Could not download the official Codex installer over HTTPS.'
      return 1
    fi
    printf 'Downloaded the documented OpenAI Codex installer from chatgpt.com/codex/install.sh.\n'
    sh "$installer"
    rm -f "$installer"
    trap - RETURN
    ensure_codex_path
  fi
  if command -v codex >/dev/null; then
    codex --version
    if ask_yes_no 'Start Codex for interactive ChatGPT authentication?' N; then codex; else printf 'Authenticate later by running: codex\n'; fi
  else
    warn "Codex was installed, but its command is still unavailable. Check CODEX_INSTALL_DIR (default: $HOME_DIR/.local/bin) and rerun setup."
  fi
}
[[ ${BASH_SOURCE[0]} != "$0" ]] || setup_codex "${1:-}"

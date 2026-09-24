#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
source "$SCRIPT_DIR/lib/platform.sh"

install_tools() {
  local missing=()
  for tool in git curl jq rg python3 gh; do command -v "$tool" >/dev/null || missing+=("$tool"); done
  if ((${#missing[@]} == 0)); then printf 'Common CLI tools are installed.\n'; return; fi
  read_platform || fail 'Unsupported Linux distribution. Install Git, curl, jq, ripgrep, and Python 3 manually.'
  local packages=(git curl jq ripgrep python3 python3-venv gh)
  case $PLATFORM in
    ubuntu|debian) run sudo apt-get update; run sudo apt-get install -y "${packages[@]}" shellcheck ;;
    fedora) run sudo dnf install -y git curl jq ripgrep python3 ShellCheck ;;
  esac
  command -v uv >/dev/null || printf 'Optional: install uv from https://docs.astral.sh/uv/getting-started/installation/ when needed.\n'
}
[[ ${BASH_SOURCE[0]} != "$0" ]] || install_tools

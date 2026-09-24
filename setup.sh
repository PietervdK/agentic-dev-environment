#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$ROOT/scripts/lib/common.sh"
source "$ROOT/scripts/lib/platform.sh"

usage() { printf 'Usage: ./setup.sh [--verify|--check]\n'; }
case ${1:-} in
  --verify) exec "$ROOT/scripts/verify.sh";;
  --check) CHECK_ONLY=1; export CHECK_ONLY;;
  -h|--help) usage; exit 0;;
  '') ;;
  *) usage >&2; exit 2;;
esac
[[ $EUID -ne 0 ]] || fail 'Do not run the bootstrap as root; it uses sudo only for system package commands.'
read_platform || fail 'Supported platforms: Ubuntu, Debian, and Fedora.'
printf 'Detected %s %s.\n' "$PLATFORM" "$PLATFORM_VERSION"
printf 'This setup can install common CLI tools, configure Git/GitHub SSH, install Codex, and sync repository-owned Codex guidance.\n'
printf 'It will not store credentials in this repository.\n'
if [[ $CHECK_ONLY != 1 ]] && ! ask_yes_no 'Continue setup?' Y; then exit 0; fi
CHECK_ONLY=$CHECK_ONLY "$ROOT/scripts/install-tools.sh"
CHECK_ONLY=$CHECK_ONLY "$ROOT/scripts/setup-git.sh"
if command -v gh >/dev/null; then
  if [[ $CHECK_ONLY == 1 ]]; then printf 'GitHub CLI authentication would be checked/configured.\n';
  elif gh auth status >/dev/null 2>&1; then printf 'GitHub CLI is authenticated.\n';
  elif ask_yes_no 'Authenticate GitHub CLI now?' N; then gh auth login --hostname github.com --git-protocol ssh --web
  else printf 'Authenticate later with: gh auth login\n'; fi
else printf 'GitHub CLI is unavailable. Install it from https://cli.github.com/\n'; fi
CHECK_ONLY=$CHECK_ONLY "$ROOT/scripts/setup-github.sh"
CHECK_ONLY=$CHECK_ONLY "$ROOT/scripts/setup-codex.sh"
if [[ $CHECK_ONLY == 1 ]]; then printf 'Optional Nix setup is available.\n';
elif ask_yes_no 'Nix installation is manual; would you like to see the steps for installing it and using the optional developer shell?' N; then "$ROOT/scripts/setup-nix.sh"; fi
if [[ $CHECK_ONLY == 1 ]]; then printf '\nCheck complete; no changes were made.\n'; else
  printf '\nSetup steps are complete. Run ./setup.sh --verify to check this environment.\n'
fi

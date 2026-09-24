#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
setup_nix() {
  if command -v nix >/dev/null; then printf 'Nix is installed: '; nix --version; return; fi
  printf 'Optional Nix installs a reproducible developer CLI shell. Official installer: https://nixos.org/download/\n'
  warn 'This bootstrap does not run a remote Nix installer automatically. Follow the official installation instructions, then use nix develop ./nix.'
}
[[ ${BASH_SOURCE[0]} != "$0" ]] || setup_nix

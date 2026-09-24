#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
setup_nix() {
  if command -v nix >/dev/null; then printf 'Nix is installed: '; nix --version; return; fi
  cat <<'EOF'
Nix installation is manual; this setup will not install it for you.

To enable the optional reproducible developer shell:
  1. Open the official installer instructions: https://nixos.org/download/
  2. Install Nix for your Linux distribution, following its interactive steps.
  3. Open a new terminal (or follow the installer instructions to load Nix).
  4. From this repository, run: nix develop ./nix

The developer shell provides the tools listed in nix/flake.nix. System packages
remain available, and Nix does not manage GitHub or Codex credentials.
EOF
}
[[ ${BASH_SOURCE[0]} != "$0" ]] || setup_nix

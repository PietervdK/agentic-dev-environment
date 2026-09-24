#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

setup_git() {
  command -v git >/dev/null || fail 'Git is missing. Run setup.sh to install it.'
  local name email current_name current_email
  current_name=$(git config --global --get user.name || true)
  current_email=$(git config --global --get user.email || true)
  if [[ -n $current_name && -n $current_email ]]; then
    printf 'Git identity: %s <%s>\n' "$current_name" "$current_email"
    setup_global_ignore
    return
  fi
  [[ -t 0 ]] || { warn 'Git identity is incomplete; configure user.name and user.email manually.'; setup_global_ignore; return; }
  read -r -p 'Git commit name: ' name
  read -r -p 'Git commit email (use the exact GitHub noreply address if preferred): ' email
  [[ -n $name && -n $email ]] || { warn 'Git identity left unchanged.'; setup_global_ignore; return; }
  [[ $CHECK_ONLY == 1 ]] || {
    [[ -z $current_name ]] || ask_yes_no 'Replace existing Git name?' N || name=$current_name
    [[ -z $current_email ]] || ask_yes_no 'Replace existing Git email?' N || email=$current_email
    git config --global user.name "$name"
    git config --global user.email "$email"
  }
  setup_global_ignore
}

setup_global_ignore() {
  local ignore_file="$HOME_DIR/.gitignore_global" configured
  configured=$(git config --global --get core.excludesfile || true)
  if [[ -n $configured ]]; then
    printf 'Global Git ignore file already configured: %s\n' "$configured"
    return
  fi
  [[ -t 0 ]] || return 0
  ask_yes_no 'Configure an optional global ignore for OS/editor noise?' N || return 0
  if [[ -e $ignore_file ]]; then
    warn "$ignore_file already exists and is not configured; leaving it untouched."
    return
  fi
  if [[ $CHECK_ONLY == 1 ]]; then printf 'Would create %s and configure core.excludesfile.\n' "$ignore_file"; return; fi
  cat > "$ignore_file" <<'EOF'
.DS_Store
Thumbs.db
*~
*.swp
*.swo
*.bak
EOF
  chmod 644 "$ignore_file"
  git config --global core.excludesfile "$ignore_file"
}

[[ ${BASH_SOURCE[0]} != "$0" ]] || setup_git

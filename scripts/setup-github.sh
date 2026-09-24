#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
SSH_DIR=${SSH_DIR:-$HOME_DIR/.ssh}
SSH_CONFIG=${SSH_CONFIG:-$SSH_DIR/config}
SSH_KEY_PATH=${SSH_KEY_PATH:-$SSH_DIR/github_ai_dev_ed25519}

update_ssh_config() {
  local begin='# BEGIN agentic-dev-environment GitHub' end='# END agentic-dev-environment GitHub'
  if [[ $CHECK_ONLY == 1 ]]; then printf 'Would update %s if no conflicting GitHub host exists.\n' "$SSH_CONFIG"; return; fi
  mkdir -p "$(dirname "$SSH_CONFIG")"
  chmod 700 "$(dirname "$SSH_CONFIG")"
  local existing=''
  [[ -f $SSH_CONFIG ]] && existing=$(cat "$SSH_CONFIG")
  if [[ $existing == *'Host github.com'* ]] && [[ $existing != *"$begin"* ]]; then
    warn "Existing Host github.com configuration found in $SSH_CONFIG; leaving it unchanged. Resolve it manually to avoid overriding another key."
    return
  fi
  if { [[ $existing == *"$begin"* ]] && [[ $existing != *"$end"* ]]; } || \
     { [[ $existing != *"$begin"* ]] && [[ $existing == *"$end"* ]]; }; then
    warn "Incomplete managed SSH block found in $SSH_CONFIG; leaving it unchanged for manual repair."
    return
  fi
  local block="$begin
Host github.com
    HostName github.com
    User git
    IdentityFile "$SSH_KEY_PATH"
    IdentitiesOnly yes
$end"
  local output=$existing
  if [[ $existing == *"$begin"* && $existing == *"$end"* ]]; then
    output=$(awk -v b="$begin" -v e="$end" -v replacement="$block" '
      $0 == b { print replacement; inside=1; next }
      $0 == e { inside=0; next }
      !inside { print }
    ' "$SSH_CONFIG")
  else
    [[ -z $output ]] || output+=$'\n\n'
    output+=$block
  fi
  if [[ -f $SSH_CONFIG ]] && [[ $output != "$existing" ]]; then backup_file "$SSH_CONFIG"; fi
  local temp
  temp=$(mktemp "$(dirname "$SSH_CONFIG")/.config.XXXXXX")
  printf '%s\n' "$output" > "$temp"
  chmod 600 "$temp"
  mv -- "$temp" "$SSH_CONFIG"
}

setup_ssh() {
  command -v ssh-keygen >/dev/null || { warn 'ssh-keygen unavailable; skipping SSH setup.'; return; }
  if [[ $CHECK_ONLY == 1 ]]; then
    [[ -f $SSH_KEY_PATH ]] || printf 'Would create Ed25519 key at %s\n' "$SSH_KEY_PATH"
    update_ssh_config
    return
  fi
  mkdir -p "$SSH_DIR"; chmod 700 "$SSH_DIR"
  if [[ ! -f $SSH_KEY_PATH ]]; then
    if [[ $CHECK_ONLY == 1 ]]; then printf 'Would create Ed25519 key at %s\n' "$SSH_KEY_PATH"; return; fi
    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -C "AI Development - $(hostname)"
    chmod 600 "$SSH_KEY_PATH"; chmod 644 "$SSH_KEY_PATH.pub"
  elif [[ ! -f $SSH_KEY_PATH.pub ]]; then
    warn "Private key exists without public key at $SSH_KEY_PATH.pub; skipping to avoid key changes."
    return
  else
    printf 'SSH key found: %s\n' "$SSH_KEY_PATH"
    ssh-keygen -lf "$SSH_KEY_PATH.pub" || { warn 'Could not inspect the existing public key.'; return; }
    if [[ -t 0 ]]; then
      printf 'Choose: [r] reuse, [n] create a new key, [s] skip SSH setup.\n'
      local choice new_key
      read -r -p 'Choice [r]: ' choice
      case ${choice:-r} in
        r|R) ;;
        s|S) return;;
        n|N)
          new_key="$SSH_KEY_PATH.$(date -u +%Y%m%dT%H%M%SZ)"
          [[ ! -e $new_key && ! -e $new_key.pub ]] || { warn 'Alternate key path already exists; skipping.'; return; }
          SSH_KEY_PATH=$new_key
          ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -C "AI Development - $(hostname)"
          chmod 600 "$SSH_KEY_PATH"; chmod 644 "$SSH_KEY_PATH.pub"
          ;;
        *) warn 'Unrecognized choice; skipping SSH setup.'; return;;
      esac
    fi
    chmod 600 "$SSH_KEY_PATH"
    chmod 644 "$SSH_KEY_PATH.pub"
  fi
  update_ssh_config
  if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
    if ask_yes_no 'Upload this public key to the authenticated GitHub account?' N; then
      local title="AI Development - $(hostname)"
      if ! gh ssh-key list 2>/dev/null | rg -Fq "$title"; then gh ssh-key add "$SSH_KEY_PATH.pub" --title "$title"; fi
    fi
  fi
  if ask_yes_no 'Verify GitHub SSH authentication now?' N; then
    local output status=0
    output=$(ssh -T git@github.com 2>&1) || status=$?
    if [[ $output == *'successfully authenticated'* ]]; then printf '%s\n' "$output"; else warn "GitHub SSH check did not authenticate (exit $status). Check key upload and account access."; fi
  fi
}
[[ ${BASH_SOURCE[0]} != "$0" ]] || setup_ssh

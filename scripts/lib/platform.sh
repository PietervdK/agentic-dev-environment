#!/usr/bin/env bash
detect_platform() {
  local name=${1:-} version=${2:-}
  case "${name,,}" in
    ubuntu) printf ubuntu;;
    debian) printf debian;;
    fedora) printf fedora;;
    *) printf unsupported;;
  esac
}
read_platform() {
  local name=unknown version=unknown
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    name=${ID:-${NAME:-unknown}}
    version=${VERSION_ID:-unknown}
  fi
  PLATFORM=$(detect_platform "$name" "$version")
  PLATFORM_VERSION=$version
  [[ $PLATFORM != unsupported ]] || return 1
}

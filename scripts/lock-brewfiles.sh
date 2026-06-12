#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREW_DIR="${ROOT_DIR}/brew"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: required command '$1' not found" >&2
    exit 1
  }
}

lock_file() {
  local file="$1"
  [[ -f "${file}" ]] || {
    echo "SKIP: missing ${file}"
    return
  }
  echo "→ locking $(basename "${file}")"
  brew bundle lock --file="${file}"
  echo "✓ locked $(basename "${file}")"
}

main() {
  require_cmd brew

  local file
  for file in "${BREW_DIR}"/Brewfile.*; do
    case "${file}" in
      *.lock.json) continue ;;
      *) lock_file "${file}" ;;
    esac
  done

  echo "Done."
}

main "$@"

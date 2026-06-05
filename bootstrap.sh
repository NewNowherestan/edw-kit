#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v xcode-select >/dev/null 2>&1; then
  echo "ERROR: xcode-select not found. This script targets macOS." >&2
  exit 1
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "ERROR: bootstrap.sh is macOS-only. Use install.sh directly on Linux." >&2
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  echo "→ installing Xcode Command Line Tools"
  xcode-select --install || true
  echo "⚠ complete Xcode CLI tools install, then re-run bootstrap.sh"
  exit 1
fi

if [[ "$(uname -m)" == "arm64" ]] && ! /usr/bin/arch -x86_64 /usr/bin/true >/dev/null 2>&1; then
  echo "→ installing Rosetta 2"
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "→ installing Homebrew"
  git -C "${ROOT_DIR}" submodule update --init submodules/homebrew-install
  NONINTERACTIVE=1 bash "${ROOT_DIR}/submodules/homebrew-install/install.sh"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

exec "${ROOT_DIR}/install.sh" "$@"

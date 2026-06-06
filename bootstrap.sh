#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
DEFAULT_PROFILE="terminal"

say() {
  printf '%s\n' "$*"
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

has_explicit_profile() {
  local next_is_profile=0
  for arg in "$@"; do
    if [[ "${next_is_profile}" -eq 1 ]]; then
      return 0
    fi
    case "${arg}" in
      -p|--profile) next_is_profile=1 ;;
      terminal|workstation|full|1|2|3) return 0 ;;
    esac
  done
  return 1
}

ensure_macos_requirements() {
  command -v xcode-select >/dev/null 2>&1 || die "xcode-select not found"

  if ! xcode-select -p >/dev/null 2>&1; then
    say "→ installing Xcode Command Line Tools"
    xcode-select --install || true
    die "finish Xcode CLI tools installation, then re-run bootstrap.sh"
  fi

  if [[ "$(uname -m)" == "arm64" ]] && ! /usr/bin/arch -x86_64 /usr/bin/true >/dev/null 2>&1; then
    say "→ installing Rosetta 2"
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  fi
}

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  command -v git >/dev/null 2>&1 || die "git is required to install Homebrew from the pinned submodule"

  say "→ installing Homebrew via pinned submodule"
  git -C "${ROOT_DIR}" submodule update --init submodules/homebrew-install
  NONINTERACTIVE=1 bash "${ROOT_DIR}/submodules/homebrew-install/install.sh"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi

  command -v brew >/dev/null 2>&1 || die "Homebrew installation completed but brew is still not in PATH"
}

main() {
  case "${OS}" in
    Darwin)
      DEFAULT_PROFILE="workstation"
      ensure_macos_requirements
      ;;
    Linux)
      DEFAULT_PROFILE="terminal"
      ;;
    *)
      die "unsupported platform: ${OS}"
      ;;
  esac


  ensure_brew

  if has_explicit_profile "$@"; then
    exec "${ROOT_DIR}/install.sh" "$@"
  fi

  exec "${ROOT_DIR}/install.sh" --profile "${DEFAULT_PROFILE}" "$@"
}

main "$@"

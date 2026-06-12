#!/usr/bin/env bash
# bootstrap.sh — fresh-machine entry point.
# Prepares platform prerequisites (Xcode CLT, Rosetta, Homebrew),
# then hands off to install.sh with a sensible default profile:
#   macOS → workstation, Linux → terminal.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

DEFAULT_PROFILE="terminal"

# Did the caller already pick a profile (positionally or via --profile)?
has_explicit_profile() {
  local next_is_profile=0
  for arg in "$@"; do
    if [[ "${next_is_profile}" -eq 1 ]]; then
      return 0
    fi
    case "${arg}" in
      -p|--profile) next_is_profile=1 ;;
      shell|terminal|workstation|full|0|1|2|3) return 0 ;;
    esac
  done
  return 1
}

ensure_macos_requirements() {
  command -v xcode-select >/dev/null 2>&1 || die "xcode-select not found"

  if ! xcode-select -p >/dev/null 2>&1; then
    log "→ installing Xcode Command Line Tools"
    xcode-select --install || true
    die "finish Xcode CLI tools installation, then re-run bootstrap.sh"
  fi

  if [[ "$(uname -m)" == "arm64" ]] && ! /usr/bin/arch -x86_64 /usr/bin/true >/dev/null 2>&1; then
    log "→ installing Rosetta 2"
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  fi
}

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  command -v git >/dev/null 2>&1 || die "git is required to install Homebrew from the pinned submodule"

  log "→ installing Homebrew via pinned submodule"
  git -C "${EDW_ROOT}" submodule update --init submodules/homebrew-install
  NONINTERACTIVE=1 bash "${EDW_ROOT}/submodules/homebrew-install/install.sh"

  # brew was just installed but isn't on PATH yet in this shell.
  local prefix
  for prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
    if [[ -x "${prefix}/bin/brew" ]]; then
      eval "$("${prefix}/bin/brew" shellenv)"
      break
    fi
  done

  command -v brew >/dev/null 2>&1 || die "Homebrew installed but brew is still not in PATH"
}

main() {
  case "${EDW_OS}" in
    Darwin)
      DEFAULT_PROFILE="workstation"
      ensure_macos_requirements
      ;;
    Linux)
      DEFAULT_PROFILE="terminal"
      ;;
    *)
      die "unsupported platform: ${EDW_OS}"
      ;;
  esac

  ensure_brew

  if has_explicit_profile "$@"; then
    exec "${EDW_ROOT}/install.sh" "$@"
  fi
  exec "${EDW_ROOT}/install.sh" --profile "${DEFAULT_PROFILE}" "$@"
}

main "$@"

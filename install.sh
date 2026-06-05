#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${HOME}/.local/state/edw-kit"
LOG_FILE="${LOG_DIR}/install.log"
TIER="${1:-1}"

mkdir -p "${LOG_DIR}"
touch "${LOG_FILE}"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "${LOG_FILE}"
}

run_step() {
  local title="$1"
  shift
  log "→ ${title}"
  "$@" >>"${LOG_FILE}" 2>&1
  log "✓ ${title}"
}

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    log "ERROR: required command '${cmd}' not found"
    exit 1
  fi
}

brew_bundle() {
  local file="$1"
  run_step "brew bundle ${file}" brew bundle --file="${ROOT_DIR}/${file}"
}

stow_tier() {
  local tier="$1"
  run_step "stow dotfiles/${tier}" stow --restow --target="${HOME}" --dir="${ROOT_DIR}" "dotfiles/${tier}"
}

ensure_oh_my_zsh_plugins() {
  local zsh_custom="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
  local plugins_dir="${zsh_custom}/plugins"

  if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    run_step "clone oh-my-zsh" git clone https://github.com/ohmyzsh/ohmyzsh.git "${HOME}/.oh-my-zsh"
  fi

  mkdir -p "${plugins_dir}"

  if [[ ! -d "${plugins_dir}/zsh-autosuggestions" ]]; then
    run_step "clone zsh-autosuggestions" git clone https://github.com/zsh-users/zsh-autosuggestions "${plugins_dir}/zsh-autosuggestions"
  fi

  if [[ ! -d "${plugins_dir}/zsh-syntax-highlighting" ]]; then
    run_step "clone zsh-syntax-highlighting" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${plugins_dir}/zsh-syntax-highlighting"
  fi
}

install_tier1() {
  brew_bundle "brew/Brewfile.tier1"
  require_cmd stow
  stow_tier "tier1"
  ensure_oh_my_zsh_plugins
}

install_tier2() {
  install_tier1
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log "SKIP: tier2 is macOS-only"
    return
  fi
  brew_bundle "brew/Brewfile.tier2"
  stow_tier "tier2"
}

install_tier3() {
  install_tier2
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log "SKIP: tier3 is macOS-only"
    return
  fi
  brew_bundle "brew/Brewfile.tier3"
}

main() {
  require_cmd git
  require_cmd brew

  case "${TIER}" in
    1) install_tier1 ;;
    2) install_tier2 ;;
    3) install_tier3 ;;
    *)
      log "Usage: $0 [1|2|3]"
      exit 1
      ;;
  esac

  log "Done. Log: ${LOG_FILE}"
}

main "$@"

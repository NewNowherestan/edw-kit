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

check_cmd_warn() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    log "WARN: command '${cmd}' not found in PATH"
  fi
}

brew_bundle() {
  local file="$1"
  run_step "brew bundle ${file}" brew bundle --file="${ROOT_DIR}/${file}"
}

brew_bundle_no_mas() {
  local file="$1"
  run_step "brew bundle ${file} (skip mas)" env HOMEBREW_BUNDLE_MAS_SKIP=1 brew bundle --file="${ROOT_DIR}/${file}"
}

stow_tier() {
  local tier_name="$1"
  run_step "stow dotfiles/${tier_name}" stow --restow --target="${HOME}" --dir="${ROOT_DIR}" "dotfiles/${tier_name}"
}

stow_host_overlay() {
  local host_name
  if [[ "$(uname -s)" == "Darwin" ]] && command -v scutil >/dev/null 2>&1; then
    host_name="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
  else
    host_name="$(hostname -s)"
  fi
  local host_dir="${ROOT_DIR}/dotfiles/hosts/${host_name}"
  if [[ -d "${host_dir}" ]]; then
    run_step "stow dotfiles/hosts/${host_name}" stow --restow --target="${HOME}" --dir="${ROOT_DIR}/dotfiles/hosts" "${host_name}"
  fi
}

ensure_oh_my_zsh_plugins() {
  local zsh_custom
  if [[ -n "${ZSH_CUSTOM:-}" ]]; then
    zsh_custom="${ZSH_CUSTOM}"
  else
    zsh_custom="${HOME}/.oh-my-zsh/custom"
  fi
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

post_install_checks() {
  local tier_name="$1"
  case "${tier_name}" in
    1)
      check_cmd_warn zsh
      check_cmd_warn tmux
      check_cmd_warn stow
      ;;
    2)
      if [[ "$(uname -s)" == "Darwin" ]]; then
        [[ -d "/Applications/AeroSpace.app" ]] || log "WARN: AeroSpace.app missing"
        [[ -d "/Applications/Karabiner-Elements.app" ]] || log "WARN: Karabiner-Elements.app missing"
      fi
      ;;
    3)
      if command -v mas >/dev/null 2>&1; then
        if ! mas account >/dev/null 2>&1; then
          log "WARN: App Store not signed in; skipping mas app installs"
        fi
      fi
      ;;
  esac
}

install_mas_apps() {
  local mas_app_1focus_id="1258530160"
  if ! command -v mas >/dev/null 2>&1; then
    return
  fi
  if mas account >/dev/null 2>&1; then
    run_step "mas install 1Focus" mas install "${mas_app_1focus_id}"
  else
    log "SKIP: mas install (App Store not signed in)"
  fi
}

install_tier1() {
  brew_bundle "brew/Brewfile.tier1"
  require_cmd stow
  stow_tier "tier1"
  ensure_oh_my_zsh_plugins
  post_install_checks 1
}

install_tier2() {
  install_tier1
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log "SKIP: tier2 is macOS-only"
    return
  fi
  brew_bundle "brew/Brewfile.tier2"
  stow_tier "tier2"
  post_install_checks 2
}

install_tier3() {
  install_tier2
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log "SKIP: tier3 is macOS-only"
    return
  fi
  brew_bundle_no_mas "brew/Brewfile.tier3"
  install_mas_apps
  post_install_checks 3
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

  stow_host_overlay
  log "Done. Log: ${LOG_FILE}"
}

main "$@"

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${HOME}/.local/state/edw-kit"
LOG_FILE="${STATE_DIR}/install.log"

PROFILE="terminal"
SKIP_BREW=0
SKIP_STOW=0
DRY_RUN=0

mkdir -p "${STATE_DIR}"
touch "${LOG_FILE}"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "${LOG_FILE}"
}

die() {
  log "ERROR: $*"
  exit 1
}

usage() {
  cat <<'EOF'
Usage:
  ./install.sh [PROFILE]
  ./install.sh --profile PROFILE [--dry-run] [--skip-brew] [--skip-stow]

Profiles:
  terminal      base shell + terminal tooling
  workstation   terminal + workstation layer (macOS-focused)
  full          workstation + full app layer

Compatibility aliases:
  1 -> terminal
  2 -> workstation
  3 -> full
EOF
}

normalize_profile() {
  case "$1" in
    1|terminal) echo "terminal" ;;
    2|workstation) echo "workstation" ;;
    3|full) echo "full" ;;
    *) return 1 ;;
  esac
}

run_step() {
  local label="$1"
  shift
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    log "DRY-RUN: ${label}"
    return
  fi
  log "→ ${label}"
  "$@" >>"${LOG_FILE}" 2>&1
  log "✓ ${label}"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command '$1' not found"
}

brew_bundle() {
  local file="$1"
  if [[ "${SKIP_BREW}" -eq 1 ]]; then
    log "SKIP: brew bundle ${file}"
    return
  fi
  require_cmd brew
  run_step "brew bundle ${file}" brew bundle --file="${ROOT_DIR}/${file}"
}

brew_bundle_no_mas() {
  local file="$1"
  if [[ "${SKIP_BREW}" -eq 1 ]]; then
    log "SKIP: brew bundle ${file} (no mas)"
    return
  fi
  require_cmd brew
  run_step "brew bundle ${file} (skip mas)" env HOMEBREW_BUNDLE_MAS_SKIP=1 brew bundle --file="${ROOT_DIR}/${file}"
}

stow_profile() {
  local profile_name="$1"
  local source_dir="${ROOT_DIR}/dotfiles/${profile_name}"
  [[ -d "${source_dir}" ]] || die "missing dotfiles profile directory: ${source_dir}"

  if [[ "${SKIP_STOW}" -eq 1 ]]; then
    log "SKIP: stow dotfiles/${profile_name}"
    return
  fi

  require_cmd stow
  run_step "stow dotfiles/${profile_name}" stow --restow --target="${HOME}" --dir="${ROOT_DIR}" "dotfiles/${profile_name}"
}

host_overlay() {
  if [[ "${SKIP_STOW}" -eq 1 ]]; then
    return
  fi

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

link_submodule() {
  local source="$1"
  local target="$2"
  if [[ -e "${target}" && ! -L "${target}" ]]; then
    log "WARN: ${target} exists and is not a symlink; keeping local version"
    return
  fi
  run_step "link $(basename "${target}")" ln -sfn "${source}" "${target}"
}

setup_terminal_plugins() {
  require_cmd git
  run_step "init shell-related submodules" \
    git -C "${ROOT_DIR}" submodule update --init \
      submodules/oh-my-zsh \
      submodules/zsh-autosuggestions \
      submodules/zsh-syntax-highlighting \
      submodules/zsh-auto-notify \
      submodules/zsh-you-should-use \
      submodules/fzf-tab

  local zsh_custom="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
  local plugins_dir="${zsh_custom}/plugins"
  mkdir -p "${plugins_dir}"

  link_submodule "${ROOT_DIR}/submodules/oh-my-zsh" "${HOME}/.oh-my-zsh"

  local plugin
  #TODO: use this list or for to init submodules as well
  for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-auto-notify zsh-you-should-use fzf-tab; do
      #TODO: cant we put this path directly into .gitmodules, so the ohmyzsh submodules will be installed directly into ohmyzsh? or even better, in the .gitmodules put them into dotfiles/termina/ right away... and make stow handle the links
    link_submodule "${ROOT_DIR}/submodules/${plugin}" "${plugins_dir}/${plugin}"
  done
}

install_mas_apps() {
  local app_1focus_id="1258530160"
  if ! command -v mas >/dev/null 2>&1; then
    log "SKIP: mas is not installed"
    return
  fi
  if ! mas account >/dev/null 2>&1; then
    log "SKIP: App Store not signed in"
    return
  fi
  run_step "mas install 1Focus" mas install "${app_1focus_id}"
}

install_terminal() {
  brew_bundle "brew/Brewfile.tier1"
  stow_profile "terminal"
  setup_terminal_plugins
}

install_workstation() {
  install_terminal
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log "SKIP: workstation layer is macOS-focused"
    return
  fi
  brew_bundle "brew/Brewfile.tier2"
  stow_profile "workstation"
}

install_full() {
  install_workstation
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log "SKIP: full layer is macOS-focused"
    return
  fi
  brew_bundle_no_mas "brew/Brewfile.tier3"
  install_mas_apps
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--profile)
        [[ $# -ge 2 ]] || die "missing value for $1"
        PROFILE="$(normalize_profile "$2")" || die "invalid profile: $2"
        shift 2
        ;;
      --skip-brew) SKIP_BREW=1; shift ;;
      --skip-stow) SKIP_STOW=1; shift ;;
      --dry-run) DRY_RUN=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *)
        PROFILE="$(normalize_profile "$1")" || die "invalid profile: $1"
        shift
        ;;
    esac
  done
}

main() {
  parse_args "$@"

  case "${PROFILE}" in
    terminal) install_terminal ;;
    workstation) install_workstation ;;
    full) install_full ;;
    *) die "unsupported profile: ${PROFILE}" ;;
  esac

  host_overlay
  log "Done (profile=${PROFILE}). Log: ${LOG_FILE}"
}

main "$@"

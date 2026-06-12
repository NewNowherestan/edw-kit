#!/usr/bin/env bash
# install.sh — apply a profile: brew packages + stowed dotfiles.
#
# Profiles are cumulative tiers, not per-app choices:
#   shell ⊂ terminal ⊂ workstation ⊂ full
#
# Each tier is defined below as a profile_* function composed from the
# building blocks in lib/steps.sh. To change what a tier does, edit its
# function; to change *how* steps run, edit lib/.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
source "${EDW_ROOT}/lib/steps.sh"

# ── Profiles ─────────────────────────────────────────────────────────────────

profile_shell() {
  stow_package "shell"            # oh-my-zsh core (pinned submodule)
}

profile_terminal() {
  profile_shell
  brew_bundle "terminal"
  brew_bundle "terminal_extras"
  stow_package "terminal"         # zsh, tmux, vim, starship, omz plugins
}

profile_workstation() {
  profile_terminal
  if ! is_macos; then
    log "SKIP: workstation layer is macOS-only"
    return 0
  fi
  brew_bundle "workstation"
  stow_package "workstation"      # ghostty, karabiner, aerospace
}

profile_full() {
  profile_workstation
  if ! is_macos; then
    log "SKIP: full layer is macOS-only"
    return 0
  fi
  brew_bundle "full" --no-mas
  mas_install "1Focus" "1258530160"
}

# ── CLI ──────────────────────────────────────────────────────────────────────

PROFILE="terminal"

usage() {
  cat <<'EOF'
Usage:
  ./install.sh [PROFILE]
  ./install.sh --profile PROFILE [--dry-run] [--skip-brew] [--skip-stow]

Profiles (cumulative):
  shell         oh-my-zsh core only
  terminal      shell + CLI tooling + terminal dotfiles
  workstation   terminal + macOS desktop layer
  full          workstation + GUI apps + App Store apps

Numeric aliases: 0=shell 1=terminal 2=workstation 3=full
EOF
}

normalize_profile() {
  case "$1" in
    0|shell) echo "shell" ;;
    1|terminal) echo "terminal" ;;
    2|workstation) echo "workstation" ;;
    3|full) echo "full" ;;
    *) return 1 ;;
  esac
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

  log "Starting (profile=${PROFILE}). Log: ${EDW_LOG_FILE}"

  "profile_${PROFILE}"
  stow_host_overlay
  run_step_optional "reload running environment" "${EDW_ROOT}/scripts/reload-env.sh"

  log "Done (profile=${PROFILE}). Log: ${EDW_LOG_FILE}"
  log "Next: run 'exec zsh' (or ./scripts/doctor.sh to verify)"
}

main "$@"

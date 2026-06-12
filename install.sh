#!/usr/bin/env bash
# install.sh — apply a profile: an ordered list of tiers.
#
# Profiles are cumulative, managed by tier, not by app:
#   shell ⊂ terminal ⊂ workstation ⊂ full
#
# Each tier lives self-contained in tiers/<name>/ (Brewfile, dotfiles/,
# optional before.sh / after.sh hooks, optional macos-only marker); the
# engine that applies one is lib/steps.sh. A hosts/<hostname>/ overlay,
# same shape, is applied last when present.
#
# The highest profile ever installed is recorded in
# ~/.local/state/edw-kit/profile so `make sync` can re-align the machine.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
source "${EDW_ROOT}/lib/steps.sh"

# ── Profiles ─────────────────────────────────────────────────────────────────

profile_tiers() {
  case "$1" in
    shell)       echo "shell" ;;
    terminal)    echo "shell terminal" ;;
    workstation) echo "shell terminal workstation" ;;
    full)        echo "shell terminal workstation full" ;;
    *) return 1 ;;
  esac
}

profile_rank() {
  case "$1" in
    shell) echo 0 ;;
    terminal) echo 1 ;;
    workstation) echo 2 ;;
    full) echo 3 ;;
    *) echo -1 ;;
  esac
}

# Remember the highest profile this machine has seen, for `make sync`.
record_profile() {
  local new="$1"
  local current=""
  [[ -f "${EDW_PROFILE_FILE}" ]] && current="$(cat "${EDW_PROFILE_FILE}")"
  if [[ -z "${current}" ]] || \
     [[ "$(profile_rank "${new}")" -gt "$(profile_rank "${current}")" ]]; then
    [[ "${DRY_RUN}" -eq 1 ]] || echo "${new}" >"${EDW_PROFILE_FILE}"
    log "recorded profile: ${new}"
  fi
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

  local tier
  for tier in $(profile_tiers "${PROFILE}"); do
    apply_tier "tiers/${tier}"
  done
  apply_host_tier
  record_profile "${PROFILE}"
  run_step_optional "reload running environment" "${EDW_ROOT}/scripts/reload-env.sh"

  log "Done (profile=${PROFILE}). Log: ${EDW_LOG_FILE}"
  log "Next: run 'exec zsh' (or ./scripts/doctor.sh to verify)"
}

main "$@"

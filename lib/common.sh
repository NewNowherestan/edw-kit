# lib/common.sh — logging, error handling, and step execution.
# Sourced by every entry point; must stay bash 3.2 compatible
# (fresh macOS has no bash 4 until Homebrew is installed).

# Guard against double-sourcing.
[[ -n "${EDW_COMMON_LOADED:-}" ]] && return 0
EDW_COMMON_LOADED=1

EDW_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EDW_STATE_DIR="${HOME}/.local/state/edw-kit"
EDW_LOG_FILE="${EDW_STATE_DIR}/install.log"
EDW_OS="$(uname -s)"

# Flags shared across entry points; parse_common_args sets these.
DRY_RUN=0

mkdir -p "${EDW_STATE_DIR}"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "${EDW_LOG_FILE}"
}

warn() {
  log "WARN: $*"
}

die() {
  log "ERROR: $*"
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command '$1' not found"
}

is_macos() {
  [[ "${EDW_OS}" == "Darwin" ]]
}

# Run a command as a logged step. Honors --dry-run.
# Usage: run_step "human label" cmd arg...
run_step() {
  local label="$1"
  shift
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    log "DRY-RUN: ${label}"
    return 0
  fi
  log "→ ${label}"
  "$@" >>"${EDW_LOG_FILE}" 2>&1
  log "✓ ${label}"
}

# Like run_step, but a failure is logged and skipped instead of aborting.
run_step_optional() {
  local label="$1"
  shift
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    log "DRY-RUN: ${label}"
    return 0
  fi
  log "→ ${label}"
  if "$@" >>"${EDW_LOG_FILE}" 2>&1; then
    log "✓ ${label}"
  else
    warn "step failed (continuing): ${label}"
  fi
}

#!/usr/bin/env bash
# sync.sh — daily driver: align this machine with the repo.
# Re-applies the highest profile this machine has ever installed
# (recorded by install.sh in ~/.local/state/edw-kit/profile).
#
# Typical morning: git pull && make sync
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

[[ -f "${EDW_PROFILE_FILE}" ]] ||
  die "no recorded profile yet — run ./install.sh <profile> once first"
PROFILE="$(cat "${EDW_PROFILE_FILE}")"

# Honor --dry-run for our own steps too, not just install.sh's.
for arg in "$@"; do
  [[ "${arg}" == "--dry-run" ]] && DRY_RUN=1
done

log "Syncing profile '${PROFILE}'"

run_step "update submodules" \
  git -C "${EDW_ROOT}" submodule update --init --recursive

exec "${EDW_ROOT}/install.sh" --profile "${PROFILE}" "$@"

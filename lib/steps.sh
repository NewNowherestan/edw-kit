# lib/steps.sh — tier application engine. Requires lib/common.sh.
#
# A tier is a self-contained directory (tiers/<name>, or hosts/<hostname>):
#   tiers/<name>/
#     Brewfile        packages (optional; Brewfile.extras etc. also picked up)
#     dotfiles/       stowed into $HOME, mirroring its layout (optional)
#     before.sh       hook run before packages (optional)
#     after.sh        hook run after stow (optional)
#     macos-only      marker file: skip this tier entirely on Linux (optional)
#
# Mac App Store entries (`mas "..."`) in Brewfiles are always skipped during
# `brew bundle` — they abort the run when no account is signed in. Install
# them from the tier's after.sh via mas_install instead.

# Flags consumed here; set by install.sh arg parsing.
SKIP_BREW=0
SKIP_STOW=0

# apply_tier <dir-relative-to-repo-root>   e.g. "tiers/terminal", "hosts/mbp"
apply_tier() {
  local tier_rel="$1"
  local tier_dir="${EDW_ROOT}/${tier_rel}"
  [[ -d "${tier_dir}" ]] || die "missing tier directory: ${tier_rel}"

  if [[ -f "${tier_dir}/macos-only" ]] && ! is_macos; then
    log "SKIP: ${tier_rel} is macOS-only"
    return 0
  fi

  log "── tier: ${tier_rel}"
  tier_hook "${tier_rel}" before
  tier_brew "${tier_rel}"
  tier_stow "${tier_rel}"
  tier_hook "${tier_rel}" after
}

# Hooks are bash scripts that may source lib/common.sh + lib/steps.sh
# (EDW_ROOT is exported for them) to reuse log/run_step/mas_install.
tier_hook() {
  local tier_rel="$1" phase="$2"
  local hook="${EDW_ROOT}/${tier_rel}/${phase}.sh"
  [[ -f "${hook}" ]] || return 0
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    log "DRY-RUN: ${tier_rel}/${phase}.sh"
    return 0
  fi
  log "→ ${tier_rel}/${phase}.sh"
  EDW_ROOT="${EDW_ROOT}" bash "${hook}"
  log "✓ ${tier_rel}/${phase}.sh"
}

tier_brew() {
  local tier_rel="$1"
  local file found=0
  for file in "${EDW_ROOT}/${tier_rel}"/Brewfile*; do
    [[ -f "${file}" ]] || continue
    case "${file}" in *.lock.json) continue ;; esac
    found=1
    if [[ "${SKIP_BREW}" -eq 1 ]]; then
      log "SKIP: brew bundle ${tier_rel}/$(basename "${file}")"
      continue
    fi
    [[ "${DRY_RUN}" -eq 1 ]] || require_cmd brew
    run_step "${tier_rel}: brew bundle $(basename "${file}")" \
      env HOMEBREW_BUNDLE_MAS_SKIP=1 brew bundle --verbose --file="${file}"
  done
  [[ "${found}" -eq 1 ]] || log "no Brewfile in ${tier_rel}"
}

tier_stow() {
  local tier_rel="$1"
  [[ -d "${EDW_ROOT}/${tier_rel}/dotfiles" ]] || return 0

  if [[ "${SKIP_STOW}" -eq 1 ]]; then
    log "SKIP: stow ${tier_rel}/dotfiles"
    return 0
  fi
  [[ "${DRY_RUN}" -eq 1 ]] || require_cmd stow
  run_step "${tier_rel}: stow dotfiles" \
    stow --verbose --adopt --restow --dir="${EDW_ROOT}/${tier_rel}" --target="${HOME}" dotfiles
  log "NOTE: stow --adopt may have pulled existing files into the repo — run 'git status' to review before committing."
}

# apply_host_tier — hosts/<hostname> is an ordinary tier applied last,
# so one repo can carry per-machine overrides without forking.
apply_host_tier() {
  local host_name
  if is_macos && command -v scutil >/dev/null 2>&1; then
    host_name="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
  else
    host_name="$(hostname -s)"
  fi

  if [[ -d "${EDW_ROOT}/hosts/${host_name}" ]]; then
    apply_tier "hosts/${host_name}"
  else
    log "no host overlay for '${host_name}' (hosts/${host_name})"
  fi
}

# mas_install <app-name> <app-id> — for use in tier after.sh hooks.
# Skips gracefully when mas or the App Store account is unavailable.
mas_install() {
  local app_name="$1" app_id="$2"
  if ! command -v mas >/dev/null 2>&1; then
    log "SKIP: mas not installed (${app_name})"
    return 0
  fi
  if ! mas account >/dev/null 2>&1; then
    log "SKIP: App Store not signed in (${app_name})"
    return 0
  fi
  run_step_optional "mas install ${app_name}" mas install "${app_id}"
}

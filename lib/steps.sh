# lib/steps.sh — installation building blocks: brew bundle, stow, mas.
# Each profile in install.sh is composed from these. Requires lib/common.sh.

# Flags consumed here; set by install.sh arg parsing.
SKIP_BREW=0
SKIP_STOW=0

# ── Homebrew ─────────────────────────────────────────────────────────────────

# brew_bundle <name> [--no-mas]
# <name> resolves to brew/Brewfile.<name>.
brew_bundle() {
  local name="$1"
  local file="${EDW_ROOT}/brew/Brewfile.${name}"
  [[ -f "${file}" ]] || die "missing Brewfile: ${file}"

  if [[ "${SKIP_BREW}" -eq 1 ]]; then
    log "SKIP: brew bundle ${name}"
    return 0
  fi
  [[ "${DRY_RUN}" -eq 1 ]] || require_cmd brew

  if [[ "${2:-}" == "--no-mas" ]]; then
    # App Store entries fail when not signed in; install them separately
    # via mas_install so a missing account doesn't abort the bundle.
    run_step "brew bundle ${name} (mas skipped)" \
      env HOMEBREW_BUNDLE_MAS_SKIP=1 brew bundle --verbose --file="${file}"
  else
    run_step "brew bundle ${name}" brew bundle --verbose --file="${file}"
  fi
}

# mas_install <app-name> <app-id>
# Installs a Mac App Store app, silently skipping when mas or the
# account is unavailable (CI, fresh machines, Linux).
mas_install() {
  local app_name="$1"
  local app_id="$2"

  if [[ "${SKIP_BREW}" -eq 1 ]]; then
    log "SKIP: mas install ${app_name}"
    return 0
  fi
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

# ── Stow ─────────────────────────────────────────────────────────────────────

# stow_package <name>
# Symlinks dotfiles/<name> into $HOME. Explicit --dir so this works
# regardless of cwd or .stowrc (which only serves manual stow calls).
stow_package() {
  local name="$1"
  local package_dir="${EDW_ROOT}/dotfiles/${name}"
  [[ -d "${package_dir}" ]] || die "missing dotfiles package: ${package_dir}"

  if [[ "${SKIP_STOW}" -eq 1 ]]; then
    log "SKIP: stow ${name}"
    return 0
  fi
  [[ "${DRY_RUN}" -eq 1 ]] || require_cmd stow
  run_step "stow ${name}" \
    stow --verbose --restow --dir="${EDW_ROOT}/dotfiles" --target="${HOME}" "${name}"
}

# stow_host_overlay
# Applies dotfiles/hosts/<hostname> on top of the profile packages,
# if such a directory exists. Lets one repo serve several machines.
stow_host_overlay() {
  if [[ "${SKIP_STOW}" -eq 1 ]]; then
    return 0
  fi

  local host_name
  if is_macos && command -v scutil >/dev/null 2>&1; then
    host_name="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
  else
    host_name="$(hostname -s)"
  fi

  local host_dir="${EDW_ROOT}/dotfiles/hosts/${host_name}"
  if [[ -d "${host_dir}" ]]; then
    [[ "${DRY_RUN}" -eq 1 ]] || require_cmd stow
    run_step "stow hosts/${host_name}" \
      stow --verbose --restow --dir="${EDW_ROOT}/dotfiles/hosts" --target="${HOME}" "${host_name}"
  else
    log "no host overlay for '${host_name}' (dotfiles/hosts/${host_name})"
  fi
}

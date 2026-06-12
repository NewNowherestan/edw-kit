#!/usr/bin/env bash
# doctor.sh — verify the kit is healthy on this machine.
# Checks core binaries, stowed symlinks, and submodules. Read-only.
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILURES=0

ok()   { printf '  ✓ %s\n' "$*"; }
bad()  { printf '  ✗ %s\n' "$*"; FAILURES=$((FAILURES + 1)); }
info() { printf '  · %s\n' "$*"; }
section() { printf '\n%s\n' "$*"; }

check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    ok "$1"
  else
    bad "$1 not found"
  fi
}

# Fully resolve symlinks in a path, portably (readlink -f is missing on
# older macOS; perl ships everywhere).
resolve_path() {
  readlink -f "$1" 2>/dev/null || perl -MCwd -e 'print Cwd::abs_path(shift)' "$1"
}

# A stowed file must resolve into this repo. The symlink may sit on any
# path component — stow folds whole directories when it can — so resolve
# the full path instead of inspecting the leaf.
check_link() {
  local target="${HOME}/$1"
  if [[ ! -e "${target}" ]]; then
    bad "~/$1 missing"
    return
  fi
  case "$(resolve_path "${target}")" in
    "${ROOT_DIR}"/*) ok "~/$1" ;;
    *) bad "~/$1 does not resolve into the kit (local file shadows it)" ;;
  esac
}

section "Core binaries (terminal tier)"
for cmd in zsh tmux stow git nvim fzf rg fd bat eza zoxide jq starship direnv; do
  check_cmd "${cmd}"
done

section "Stowed dotfiles"
for link in .zshrc .tmux.conf .vimrc .config/starship.toml .config/tmux/dynamic_layout.conf; do
  check_link "${link}"
done
if [[ "$(uname -s)" == "Darwin" ]]; then
  for link in .config/ghostty/config .config/karabiner/karabiner.json; do
    check_link "${link}"
  done
fi

section "Submodules"
while read -r status path _; do
  case "${status}" in
    -*) bad "submodule not initialized: ${path} (run: git submodule update --init --recursive)" ;;
    +*) info "submodule checked out at a different commit: ${path}" ;;
    *)  ok "${path}" ;;
  esac
done < <(git -C "${ROOT_DIR}" submodule status --recursive | awk '{print substr($1,1,1) " " $2}')

section "Homebrew bundle (terminal tier)"
if command -v brew >/dev/null 2>&1; then
  if brew bundle check --no-upgrade --file="${ROOT_DIR}/brew/Brewfile.terminal" >/dev/null 2>&1; then
    ok "all Brewfile.terminal dependencies satisfied"
  else
    info "some Brewfile.terminal entries missing (run: ./install.sh terminal)"
  fi
else
  bad "brew not found"
fi

printf '\n'
if [[ "${FAILURES}" -gt 0 ]]; then
  printf '%d problem(s) found.\n' "${FAILURES}"
  exit 1
fi
printf 'All good.\n'

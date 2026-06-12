#!/usr/bin/env bash
# reload-env.sh — nudge running apps to pick up freshly stowed configs.
# Safe to run anytime; every step is best-effort.
set -euo pipefail

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

# direnv: re-allow the repo's .envrc if we're inside it
if command -v direnv >/dev/null 2>&1 && [[ -f .envrc ]]; then
  log "Allowing direnv in current directory..."
  direnv allow
fi

# tmux: reload config in the current or all running sessions
if [[ -n "${TMUX:-}" ]]; then
  log "Reloading tmux configuration..."
  tmux source-file ~/.tmux.conf
elif command -v tmux >/dev/null 2>&1 && tmux ls >/dev/null 2>&1; then
  log "Reloading all tmux sessions..."
  tmux list-sessions -F '#S' | xargs -I{} tmux source-file -t {} ~/.tmux.conf
fi

# ghostty: reloads config on SIGUSR1
if pgrep -x "ghostty" >/dev/null 2>&1; then
  log "Reloading ghostty configuration..."
  killall -USR1 ghostty
fi

log "Reload complete."
log "zsh changes need a new shell: exec zsh (or 'omz reload' inside zsh)"

#!/usr/bin/env bash
# setup-env.sh - Post-install environment setup

set -e

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

log "Running post-install environment setup..."

# 1. direnv allow
if command -v direnv >/dev/null 2>&1; then
  if [[ -f .envrc ]]; then
    log "Allowing direnv in current directory..."
    direnv allow
  fi
fi

# 2. tmux reload
if [[ -n "$TMUX" ]]; then
  log "Reloading tmux configuration..."
  tmux source-file ~/.tmux.conf
elif command -v tmux >/dev/null 2>&1 && tmux ls >/dev/null 2>&1; then
  log "Reloading all tmux sessions..."
  tmux list-sessions -F '#S' | xargs -I{} tmux source-file -t {} ~/.tmux.conf
fi

# 3. ghostty reload (if running)
if pgrep -x "ghostty" >/dev/null 2>&1; then
  log "Reloading ghostty configuration..."
  # Ghostty reloads on SIGUSR1
  killall -USR1 ghostty
fi

# 4. omz reload / zsh reload
# Since we are in a subshell, we can't source into the parent shell.
# We will print a message to the user.
log "Environment setup complete."
log "To reload your shell, run: exec zsh"
log "Or use the OMZ alias if available: omz reload"

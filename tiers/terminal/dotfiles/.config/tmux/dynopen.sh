#!/usr/bin/env bash
# ~/.config/tmux/dynopen.sh
# Select the dynamic window, creating and initialising it if needed.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

SESS=$(tmux display-message -p '#S' 2>/dev/null)
SESS="${SESS:-main}"
WIN="dynamic"

# Already exists — just focus it
tmux select-window -t "${SESS}:${WIN}" 2>/dev/null && exit 0

# Create and init
tmux new-window -t "$SESS" -n "$WIN" -d
sleep 0.3
bash "$HOME/.config/tmux/autolayout.sh" "$SESS" "$WIN" init
tmux select-window -t "${SESS}:${WIN}"

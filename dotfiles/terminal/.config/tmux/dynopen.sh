#!/bin/sh
# ~/.config/tmux/dynopen.sh
TMUX_BIN=$(command -v tmux || echo /opt/homebrew/bin/tmux)
SESS=main
WIN=dynamic

$TMUX_BIN select-window -t "${SESS}:${WIN}" 2>/dev/null && exit 0

$TMUX_BIN new-window -t "$SESS" -n "$WIN" -d
sleep 0.3
/bin/bash "$HOME/.config/tmux/autolayout.sh" init
$TMUX_BIN select-window -t "${SESS}:${WIN}"

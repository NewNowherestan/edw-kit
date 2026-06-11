#!/usr/bin/env bash
# ~/.config/tmux/autolayout.sh
# Usage: autolayout.sh [init|auto]

SESSION="main"
WINDOW="dynamic"
W="${SESSION}:${WINDOW}"

WIDE=220   # cols threshold for LL pane
TALL=50    # rows threshold for H pane
CMATRIX="cmatrix -s -C cyan"

# ── helpers ───────────────────────────────────────────────────────────────────

pane_id()  { tmux list-panes -t "$W" -F '#{pane_id} #{pane_title}' 2>/dev/null | awk -v n="$1" '$2==n{print $1;exit}'; }
pane_cmd() { tmux list-panes -t "$W" -F '#{pane_id} #{pane_current_command}' 2>/dev/null | awk -v id="$1" '$1==id{print $2;exit}'; }

show() {
    local id=$(pane_id "$1")
    [[ $(pane_cmd "$id") == "cmatrix" ]] && tmux send-keys -t "$id" q "" && sleep 0.05
    [[ $(pane_cmd "$id") == "cmatrix" ]] && tmux send-keys -t "$id" "" ""
    tmux resize-pane -t "$id" $2 $3
}

hide() {
    local id=$(pane_id "$1")
    tmux resize-pane -t "$id" $2 1
    local cmd=$(pane_cmd "$id")
    [[ "$cmd" == "zsh" || "$cmd" == "bash" || "$cmd" == "sh" ]] && tmux send-keys -t "$id" "$CMATRIX" Enter
}

# ── init: create 4 named panes ───────────────────────────────────────────────

if [[ "$1" == "init" ]]; then
    # Create window if missing
    tmux list-windows -t "$SESSION" -F '#{window_name}' | grep -qx "$WINDOW" \
        || tmux new-window -t "$SESSION" -n "$WINDOW" -d
    sleep 0.2

    # Name first pane L
    first=$(tmux list-panes -t "$W" -F '#{pane_id}' | head -1)
    tmux select-pane -t "$first" -T L

    # Create R, H, LL if missing
    for name in R H LL; do
        [[ -z $(pane_id "$name") ]] || continue
        tmux split-window -t "$W" -h -d
        sleep 0.1
        new=$(tmux list-panes -t "$W" -F '#{pane_id}' | tail -1)
        tmux select-pane -t "$new" -T "$name"
    done
    # Fall through to layout
fi

# ── layout ────────────────────────────────────────────────────────────────────

COLS=$(tmux display -p -t "$W" '#{window_width}'  2>/dev/null)
ROWS=$(tmux display -p -t "$W" '#{window_height}' 2>/dev/null)
[[ -z "$COLS" || "$COLS" -eq 0 ]] && exit 0

# Tier flags
(( COLS >= WIDE )) && wide=1 || wide=0
(( ROWS >= TALL )) && tall=1 || tall=0

# Sizes
ll_w=$(( COLS / 4 ))
main_w=$(( COLS - ll_w - 1 ))
lr_w=$(( main_w / 2 ))
top_r=$(( ROWS * 6 / 10 ))
bot_r=$(( ROWS - top_r - 1 ))

if (( wide && tall )); then
    show LL -x $ll_w;  tmux resize-pane -t "$(pane_id LL)" -y $ROWS
    show L  -x $lr_w;  tmux resize-pane -t "$(pane_id L)"  -y $top_r
    show R  -x $lr_w;  tmux resize-pane -t "$(pane_id R)"  -y $top_r
    show H  -y $bot_r
    tmux display "Layout 4 — wide+full"

elif (( wide )); then
    show LL -x $ll_w;  tmux resize-pane -t "$(pane_id LL)" -y $ROWS
    show L  -x $lr_w;  tmux resize-pane -t "$(pane_id L)"  -y $ROWS
    show R  -x $lr_w;  tmux resize-pane -t "$(pane_id R)"  -y $ROWS
    hide H  -y
    tmux display "Layout 3 — wide"

elif (( tall )); then
    hide LL -x
    show L  -x $lr_w;  tmux resize-pane -t "$(pane_id L)"  -y $top_r
    show R  -x $lr_w;  tmux resize-pane -t "$(pane_id R)"  -y $top_r
    show H  -y $bot_r
    tmux display "Layout 2 — fullscreen"

else
    hide LL -x
    hide H  -y
    show L  -x $lr_w;  tmux resize-pane -t "$(pane_id L)"  -y $ROWS
    show R  -x $lr_w;  tmux resize-pane -t "$(pane_id R)"  -y $ROWS
    tmux display "Layout 1 — quick"
fi

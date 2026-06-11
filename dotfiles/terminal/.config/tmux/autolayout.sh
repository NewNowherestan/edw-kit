#!/usr/bin/env bash
# ~/.config/tmux/autolayout.sh
# Usage (from hook): autolayout.sh <session> <window> [init]
#
# Pane topology (session "main", window "dynamic"):
#
#   ┌──────┬────────┬────────┐
#   │      │   L    │   R    │
#   │  LL  ├────────┴────────┤
#   │      │        H        │
#   └──────┴─────────────────┘
#
# Layouts (based on cols × rows):
#   1  narrow + short  →  L | R  full height          (mac quake)
#   2  narrow + tall   →  L | R  top,  H bottom       (mac fullscreen)
#   3  wide   + short  →  LL | L | R  full height     (ultrawide quake)
#   4  wide   + tall   →  LL | L | R  top,  H bottom  (ultrawide fullscreen)

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

SESS="${1:-main}"
WIN="${2:-dynamic}"
W="$SESS:$WIN"

# Thresholds — tuned to your displays:
#   mac:        214 cols  (quake) / 58 rows  (fullscreen)
#   ultrawide:  638 cols  (quake) / 81 rows  (fullscreen)
WIDE_THRESHOLD=400   # anything above this = ultrawide
TALL_THRESHOLD=50    # anything above this = fullscreen

LOG="/tmp/autolayout.log"

log() { echo "$(date '+%H:%M:%S') $*" >> "$LOG"; }

notify() {
    local client
    client=$(tmux list-clients -F '#{client_name}' 2>/dev/null | head -1)
    [[ -n "$client" ]] && tmux display-message -c "$client" "$1" 2>/dev/null || true
}

[[ "$WIN" == "dynamic" ]] || exit 0
log "--- fired session=$SESS window=$WIN cmd=${3:-layout}"

# ── pane helpers ──────────────────────────────────────────────────────────────

pane_id() {
    tmux list-panes -t "$W" -F '#{pane_id} #{pane_title}' 2>/dev/null \
        | awk -v t="$1" '$2 == t { print $1; exit }'
}

pane_cmd() {
    tmux list-panes -t "$W" -F '#{pane_id} #{pane_current_command}' 2>/dev/null \
        | awk -v id="$1" '$1 == id { print $2; exit }'
}

# ── init ──────────────────────────────────────────────────────────────────────

init() {
    log "init start"

    # Ensure window exists
    tmux list-windows -t "$SESS" -F '#{window_name}' 2>/dev/null \
        | grep -qx "$WIN" \
        || tmux new-window -t "$SESS" -n "$WIN" -d
    sleep 0.5

    # Collapse to one pane
    local count
    count=$(tmux list-panes -t "$W" 2>/dev/null | wc -l | tr -d ' ')
    while (( count > 1 )); do
        local last; last=$(tmux list-panes -t "$W" -F '#{pane_id}' | tail -1)
        tmux kill-pane -t "$last" 2>/dev/null || true
        sleep 0.1
        count=$(tmux list-panes -t "$W" 2>/dev/null | wc -l | tr -d ' ')
    done

    # Capture sole pane → L
    local iL; iL=$(tmux list-panes -t "$W" -F '#{pane_id}' | head -1)
    tmux select-pane -t "$iL" -T L
    log "L = $iL"

    # Split off H (bottom 30%)
    local iH
    iH=$(tmux split-window -t "$iL" -v -d -p 30 -P -F '#{pane_id}')
    tmux select-pane -t "$iH" -T H
    log "H = $iH"
    sleep 0.1

    # Split off R (right 50% of L)
    local iR
    iR=$(tmux split-window -t "$iL" -h -d -p 50 -P -F '#{pane_id}')
    tmux select-pane -t "$iR" -T R
    log "R = $iR"
    sleep 0.1

    # Split off LL (insert left of L, 25% of full width)
    local iLL
    iLL=$(tmux split-window -t "$iL" -h -d -b -p 25 -P -F '#{pane_id}')
    tmux select-pane -t "$iLL" -T LL
    log "LL = $iLL"
    sleep 0.1

    log "init done — L=$iL R=$iR H=$iH LL=$iLL"

    # Wait for tmux to settle before resizing
    sleep 0.5
    layout
}

# ── layout ────────────────────────────────────────────────────────────────────

layout() {
    tmux list-windows -t "$SESS" -F '#{window_name}' 2>/dev/null \
        | grep -qx "$WIN" || { log "window not found"; return 0; }

    local cols rows
    cols=$(tmux display-message -p -t "$W" '#{window_width}'  2>/dev/null)
    rows=$(tmux display-message -p -t "$W" '#{window_height}' 2>/dev/null)
    [[ -z "$cols" || "$cols" -eq 0 ]] && { log "bad dimensions cols=$cols rows=$rows"; return 0; }

    log "layout cols=$cols rows=$rows"

    local iL iR iH iLL
    iL=$(pane_id L); iR=$(pane_id R); iH=$(pane_id H); iLL=$(pane_id LL)
    log "panes L=$iL R=$iR H=$iH LL=$iLL"

    if [[ -z "$iL" || -z "$iR" || -z "$iH" || -z "$iLL" ]]; then
        log "panes missing — run dynlayout-reinit"
        notify "⚠ panes missing — run: dynlayout-reinit"
        return 1
    fi

    local wide=0 tall=0
    (( cols >= WIDE_THRESHOLD )) && wide=1
    (( rows >= TALL_THRESHOLD )) && tall=1

    local ll_w lr_w top_r bot_r
    ll_w=$(( cols / 4 ))
    lr_w=$(( (cols - ll_w - 1) / 2 ))
    top_r=$(( rows * 6 / 10 ))
    bot_r=$(( rows - top_r - 1 ))

    if (( wide && tall )); then
        # Layout 4 — ultrawide fullscreen
        tmux resize-pane -t "$iLL" -x "$ll_w"  -y "$rows"
        tmux resize-pane -t "$iL"  -x "$lr_w"  -y "$top_r"
        tmux resize-pane -t "$iR"  -x "$lr_w"  -y "$top_r"
        tmux resize-pane -t "$iH"  -y "$bot_r"
        notify "◼◼◼◼ ultrawide fullscreen (${cols}x${rows})"

    elif (( wide )); then
        # Layout 3 — ultrawide quake
        tmux resize-pane -t "$iLL" -x "$ll_w"  -y "$rows"
        tmux resize-pane -t "$iL"  -x "$lr_w"  -y "$rows"
        tmux resize-pane -t "$iR"  -x "$lr_w"  -y "$rows"
        tmux resize-pane -t "$iH"  -y 1
        notify "◼◼◼ ultrawide quake (${cols}x${rows})"

    elif (( tall )); then
        # Layout 2 — mac fullscreen
        tmux resize-pane -t "$iLL" -x
        tmux resize-pane -t "$iL"  -x "$lr_w"  -y "$top_r"
        tmux resize-pane -t "$iR"  -x "$lr_w"  -y "$top_r"
        tmux resize-pane -t "$iH"  -y "$bot_r"
        notify "◼◼ mac fullscreen (${cols}x${rows})"

    else
        # Layout 1 — mac quake
        tmux resize-pane -t "$iLL" -x 1;
        tmux resize-pane -t "$iH"  -y 1;
        tmux resize-pane -t "$iL"  -x "$lr_w"  -y "$rows"
        tmux resize-pane -t "$iR"  -x "$lr_w"  -y "$rows"
        notify "◼ mac quake (${cols}x${rows})"
    fi

    log "layout done"
}

# ── entry ─────────────────────────────────────────────────────────────────────

case "${3:-layout}" in
    init) init   ;;
    *)    layout ;;
esac

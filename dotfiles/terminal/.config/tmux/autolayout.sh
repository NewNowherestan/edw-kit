#!/bin/bash
# ~/.config/tmux/autolayout.sh

SESS=main
WIN=dynamic
W="$SESS:$WIN"
WIDE=200
TALL=48

# ── tiny helpers ──────────────────────────────────────────────────────────────

pid() {
    tmux list-panes -t "$W" -F '#{pane_id} #{pane_title}' 2>/dev/null \
        | awk -v t="$1" '$2==t{print $1;exit}'
}

pcmd() {
    tmux list-panes -t "$W" -F '#{pane_id} #{pane_current_command}' 2>/dev/null \
        | awk -v id="$1" '$1==id{print $2;exit}'
}

name_last() {
    # name the most-recently-created pane in $W
    local last id
    last=$(tmux list-panes -t "$W" -F '#{pane_id}' 2>/dev/null | tail -1)
    tmux select-pane -t "$last" -T "$1"
}

notify() {
    tmux set -g status-right "#[fg=colour2,bold] $1 #[fg=default,nobold]"
    ( sleep 3 && tmux set -g status-right "%H:%M" ) &
}

kill_cmatrix() {
    [[ "$(pcmd "$1")" == "cmatrix" ]] || return 0
    tmux send-keys -t "$1" q ""
    sleep 0.1
    [[ "$(pcmd "$1")" == "cmatrix" ]] && tmux send-keys -t "$1" "" ""
}

maybe_cmatrix() {
    local c; c=$(pcmd "$1")
    [[ "$c" == "zsh" || "$c" == "bash" || "$c" == "sh" ]] \
        && tmux send-keys -t "$1" "cmatrix -s -C cyan" Enter
}

# ── init ──────────────────────────────────────────────────────────────────────

init() {
    # 1. make sure window exists
    tmux list-windows -t "$SESS" -F '#{window_name}' 2>/dev/null \
        | grep -qx "$WIN" \
        || tmux new-window -t "$SESS" -n "$WIN" -d
    sleep 0.3

    # 2. kill down to exactly 1 pane
    local count
    count=$(tmux list-panes -t "$W" 2>/dev/null | wc -l | tr -d ' ')
    while (( count > 1 )); do
        local last; last=$(tmux list-panes -t "$W" -F '#{pane_id}' | tail -1)
        tmux kill-pane -t "$last" 2>/dev/null
        sleep 0.05
        count=$(tmux list-panes -t "$W" 2>/dev/null | wc -l | tr -d ' ')
    done

    # 3. name sole pane → L
    local sole; sole=$(tmux list-panes -t "$W" -F '#{pane_id}' | head -1)
    tmux select-pane -t "$sole" -T L

    # 4. split L downward → H (bottom, full width)
    tmux split-window -t "$sole" -v -d -p 30
    sleep 0.1
    name_last H

    # 5. split L rightward → R
    tmux split-window -t "$sole" -h -d -p 50
    sleep 0.1
    name_last R

    # 6. split L leftward → LL  (-b = insert before/left of target)
    tmux split-window -t "$sole" -h -d -b -p 25
    sleep 0.1
    # LL is now left of L — it's NOT the last pane, it's the new left one
    # find it: the pane that isn't L, R, or H
    local ll_id
    ll_id=$(tmux list-panes -t "$W" -F '#{pane_id} #{pane_title}' \
        | awk '$2=="" || $2=="zsh" || $2=="bash" {print $1}' \
        | head -1)
    # simpler: it's the pane with no title yet (we named L, H, R already)
    ll_id=$(tmux list-panes -t "$W" -F '#{pane_id} #{pane_title}' \
        | awk '$2=="" {print $1; exit}')
    tmux select-pane -t "$ll_id" -T LL

    notify "init ok — L R H LL ready"
    layout
}

# ── layout ────────────────────────────────────────────────────────────────────

layout() {
    tmux list-windows -t "$SESS" -F '#{window_name}' 2>/dev/null \
        | grep -qx "$WIN" || return 0

    local cols rows
    cols=$(tmux display -p -t "$W" '#{window_width}'  2>/dev/null)
    rows=$(tmux display -p -t "$W" '#{window_height}' 2>/dev/null)
    [[ -z "$cols" || "$cols" -eq 0 ]] && return 0

    local iL iR iH iLL
    iL=$(pid L); iR=$(pid R); iH=$(pid H); iLL=$(pid LL)

    if [[ -z "$iL" || -z "$iR" || -z "$iH" || -z "$iLL" ]]; then
        notify "⚠ panes missing — C-a :dynlayout-reinit to reinit"
        return 1
    fi

    local wide=0 tall=0
    (( cols >= WIDE )) && wide=1
    (( rows >= TALL )) && tall=1

    local ll_w lr_w top_r bot_r
    ll_w=$(( cols / 4 ))
    lr_w=$(( (cols - ll_w - 1) / 2 ))
    top_r=$(( rows * 6 / 10 ))
    bot_r=$(( rows - top_r - 1 ))

    if (( wide && tall )); then
        kill_cmatrix "$iLL"; kill_cmatrix "$iH"
        tmux resize-pane -t "$iLL" -x "$ll_w"  -y "$rows"
        tmux resize-pane -t "$iL"  -x "$lr_w"  -y "$top_r"
        tmux resize-pane -t "$iR"  -x "$lr_w"  -y "$top_r"
        tmux resize-pane -t "$iH"  -y "$bot_r"
        notify "◼◼◼◼ wide+full"

    elif (( wide )); then
        kill_cmatrix "$iLL"; kill_cmatrix "$iH"
        tmux resize-pane -t "$iLL" -x "$ll_w"  -y "$rows"
        tmux resize-pane -t "$iL"  -x "$lr_w"  -y "$rows"
        tmux resize-pane -t "$iR"  -x "$lr_w"  -y "$rows"
        tmux resize-pane -t "$iH"  -y 1;  maybe_cmatrix "$iH"
        notify "◼◼◼ wide"

    elif (( tall )); then
        kill_cmatrix "$iH"
        tmux resize-pane -t "$iLL" -x 1;  maybe_cmatrix "$iLL"
        tmux resize-pane -t "$iL"  -x "$lr_w"  -y "$top_r"
        tmux resize-pane -t "$iR"  -x "$lr_w"  -y "$top_r"
        tmux resize-pane -t "$iH"  -y "$bot_r"
        notify "◼◼ fullscreen"

    else
        tmux resize-pane -t "$iLL" -x 1;  maybe_cmatrix "$iLL"
        tmux resize-pane -t "$iH"  -y 1;  maybe_cmatrix "$iH"
        tmux resize-pane -t "$iL"  -x "$lr_w"  -y "$rows"
        tmux resize-pane -t "$iR"  -x "$lr_w"  -y "$rows"
        notify "◼ quick"
    fi
}

# ── entry ─────────────────────────────────────────────────────────────────────

case "${1:-layout}" in
    init) init   ;;
    *)    layout ;;
esac

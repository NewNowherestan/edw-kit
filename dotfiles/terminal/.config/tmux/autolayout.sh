#!/usr/bin/env bash
set -u

# ~/.config/tmux/autolayout.sh
# Usage: autolayout.sh <session> <window> [init|layout|reinit]
#
# Managed pane topology:
#
#   ┌──────┬────────┬────────┐
#   │      │   L    │   R    │
#   │  LL  ├────────┴────────┤
#   │      │        H        │
#   └──────┴─────────────────┘
#
# Layouts:
#   1  narrow + short  →  L | R  full height
#   2  narrow + tall   →  L | R  top,  H bottom
#   3  wide   + short  →  LL | L | R  full height
#   4  wide   + tall   →  LL | L | R  top,  H bottom
#
# State model:
# - Pane identity is stored in pane user options, not pane titles.
# - Every managed pane gets:
#     @dyn_role = L | R | H | LL
#     @dyn_managed = 1
#     @dyn_window = <session>:<window>
#     @dyn_gen = <generation>
# - The window stores the active generation in @dyn_gen.
#
# This lets init/layout run in separate processes and still rediscover panes.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

SESS="${1:-main}"
WIN="${2:-dynamic}"
CMD="${3:-layout}"
W="$SESS:$WIN"

WIDE_THRESHOLD=400
TALL_THRESHOLD=50
LOG="/tmp/autolayout.log"

log() { echo "$(date '+%H:%M:%S') $*" >> "$LOG"; }

notify() {
    local client
    client=$(tmux list-clients -F '#{client_name}' 2>/dev/null | head -1)
    [[ -n "$client" ]] && tmux display-message -c "$client" "$1" 2>/dev/null || true
}

window_exists() {
    tmux list-windows -t "$SESS" -F '#{window_name}' 2>/dev/null | grep -qx "$WIN"
}

ensure_window() {
    window_exists && return 0
    tmux new-window -t "$SESS" -n "$WIN" -d
}

window_gen() {
    tmux show-options -v -w -t "$W" @dyn_gen 2>/dev/null || true
}

set_window_gen() {
    tmux set-option -w -t "$W" @dyn_gen "$1" >/dev/null
}

new_gen() {
    printf '%s-%s' "$(date +%Y%m%d%H%M%S)" "$$"
}

set_pane_meta() {
    local pane="$1" role="$2" gen="$3"
    tmux set-option -p -t "$pane" @dyn_role "$role" >/dev/null
    tmux set-option -p -t "$pane" @dyn_managed 1 >/dev/null
    tmux set-option -p -t "$pane" @dyn_window "$W" >/dev/null
    tmux set-option -p -t "$pane" @dyn_gen "$gen" >/dev/null
    tmux select-pane -t "$pane" -T "$role" >/dev/null 2>&1 || true
}

pane_id() {
    local role="$1"
    local gen
    gen=$(window_gen)
    [[ -n "$gen" ]] || return 0

    tmux list-panes -t "$W" -F '#{pane_id} #{@dyn_role} #{@dyn_gen} #{@dyn_managed}' 2>/dev/null |
        awk -v role="$role" -v gen="$gen" '$2 == role && $3 == gen && $4 == 1 { print $1; exit }'
}

managed_panes() {
    local gen
    gen=$(window_gen)
    [[ -n "$gen" ]] || return 0

    tmux list-panes -t "$W" -F '#{pane_id} #{@dyn_gen} #{@dyn_managed}' 2>/dev/null |
        awk -v gen="$gen" '$2 == gen && $3 == 1 { print $1 }'
}

clear_managed_panes() {
    local panes pane keep first
    mapfile -t panes < <(managed_panes)

    if ((${#panes[@]} == 0)); then
        return 0
    fi

    first="${panes[0]}"
    keep="$first"

    for pane in "${panes[@]:1}"; do
        tmux kill-pane -t "$pane" 2>/dev/null || true
    done

    if [[ -n "$keep" ]]; then
        tmux set-option -p -t "$keep" -u @dyn_role >/dev/null 2>&1 || true
        tmux set-option -p -t "$keep" -u @dyn_managed >/dev/null 2>&1 || true
        tmux set-option -p -t "$keep" -u @dyn_window >/dev/null 2>&1 || true
        tmux set-option -p -t "$keep" -u @dyn_gen >/dev/null 2>&1 || true
        tmux select-pane -t "$keep" -T '' >/dev/null 2>&1 || true
    fi
}

collapse_to_one_pane() {
    local count last
    count=$(tmux list-panes -t "$W" 2>/dev/null | wc -l | tr -d ' ')
    while (( count > 1 )); do
        last=$(tmux list-panes -t "$W" -F '#{pane_id}' 2>/dev/null | tail -1)
        [[ -n "$last" ]] || break
        tmux kill-pane -t "$last" 2>/dev/null || true
        count=$(tmux list-panes -t "$W" 2>/dev/null | wc -l | tr -d ' ')
    done
}

ensure_base_pane() {
    local base
    base=$(tmux list-panes -t "$W" -F '#{pane_id}' 2>/dev/null | head -1)
    if [[ -z "$base" ]]; then
        tmux split-window -t "$W" -d -P -F '#{pane_id}' >/dev/null
        base=$(tmux list-panes -t "$W" -F '#{pane_id}' 2>/dev/null | head -1)
    fi
    printf '%s\n' "$base"
}

create_layout() {
    local gen iL iLL iH iR
    gen=$(new_gen)
    set_window_gen "$gen"

    collapse_to_one_pane
    iL=$(ensure_base_pane)
    set_pane_meta "$iL" L "$gen"
    log "L = $iL"

    iLL=$(tmux split-window -t "$iL" -h -d -b -p 10 -P -F '#{pane_id}')
    set_pane_meta "$iLL" LL "$gen"
    log "LL = $iLL"

    iH=$(tmux split-window -t "$iL" -v -d -p 30 -P -F '#{pane_id}')
    set_pane_meta "$iH" H "$gen"
    log "H = $iH"

    iR=$(tmux split-window -t "$iL" -h -d -p 40 -P -F '#{pane_id}')
    set_pane_meta "$iR" R "$gen"
    log "R = $iR"

    log "init done — gen=$gen L=$iL R=$iR H=$iH LL=$iLL"
}

ensure_layout() {
    local iL iR iH iLL
    iL=$(pane_id L)
    iR=$(pane_id R)
    iH=$(pane_id H)
    iLL=$(pane_id LL)

    if [[ -n "$iL" && -n "$iR" && -n "$iH" && -n "$iLL" ]]; then
        return 0
    fi

    log "managed panes missing; rebuilding"
    clear_managed_panes
    create_layout
}

apply_layout() {
    local cols rows iL iR iH iLL

    window_exists || { log "window not found"; return 0; }

    cols=$(tmux display-message -p -t "$W" '#{window_width}' 2>/dev/null)
    rows=$(tmux display-message -p -t "$W" '#{window_height}' 2>/dev/null)
    [[ -z "$cols" || "$cols" -eq 0 ]] && { log "bad dimensions cols=$cols rows=$rows"; return 0; }

    iL=$(pane_id L)
    iR=$(pane_id R)
    iH=$(pane_id H)
    iLL=$(pane_id LL)
    log "layout cols=$cols rows=$rows panes L=$iL R=$iR H=$iH LL=$iLL"

    if [[ -z "$iL" || -z "$iR" || -z "$iH" || -z "$iLL" ]]; then
        log "panes missing after ensure_layout"
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
        tmux resize-pane -t "$iLL" -x "$ll_w" -y "$rows"
        tmux resize-pane -t "$iL"  -x "$lr_w" -y "$top_r"
        tmux resize-pane -t "$iR"  -x "$lr_w" -y "$top_r"
        tmux resize-pane -t "$iH"  -y "$bot_r"
        notify "◼◼◼◼ ultrawide fullscreen (${cols}x${rows})"
    elif (( wide )); then
        tmux resize-pane -t "$iLL" -x "$ll_w" -y "$rows"
        tmux resize-pane -t "$iL"  -x "$lr_w" -y "$rows"
        tmux resize-pane -t "$iR"  -x "$lr_w" -y "$rows"
        tmux resize-pane -t "$iH"  -y 1
        notify "◼◼◼ ultrawide quake (${cols}x${rows})"
    elif (( tall )); then
        tmux resize-pane -t "$iLL" -x 1
        tmux resize-pane -t "$iL"  -x "$lr_w" -y "$top_r"
        tmux resize-pane -t "$iR"  -x "$lr_w" -y "$top_r"
        tmux resize-pane -t "$iH"  -y "$bot_r"
        notify "◼◼ mac fullscreen (${cols}x${rows})"
    else
        tmux resize-pane -t "$iLL" -x 1
        tmux resize-pane -t "$iH"  -y 1
        tmux resize-pane -t "$iL"  -x "$lr_w" -y "$rows"
        tmux resize-pane -t "$iR"  -x "$lr_w" -y "$rows"
        notify "◼ mac quake (${cols}x${rows})"
    fi

    log "layout done"
}

init_cmd() {
    log "init start session=$SESS window=$WIN"
    ensure_window
    create_layout
    apply_layout
}

layout_cmd() {
    log "layout start session=$SESS window=$WIN"
    ensure_window
    ensure_layout
    apply_layout
}

reinit_cmd() {
    log "reinit start session=$SESS window=$WIN"
    ensure_window
    clear_managed_panes
    create_layout
    apply_layout
}

main() {
    [[ "$WIN" == "dynamic" ]] || exit 0
    log "--- fired session=$SESS window=$WIN cmd=$CMD"

    case "$CMD" in
        init)   init_cmd ;;
        reinit) reinit_cmd ;;
        *)      layout_cmd ;;
    esac
}

main "$@"

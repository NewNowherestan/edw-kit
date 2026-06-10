#!/usr/bin/env bash
# =============================================================================
# autolayout.sh — dynamic tmux pane layout based on terminal dimensions
#
# Pane naming convention:
#   dyndef-L   (dynamic default — left)
#   dyndef-R   (dynamic default — right)
#   dyndef-H   (dynamic default — horizontal / bottom full-width)
#   dynwide-LL (dynamic widescreen — far left, stashed on laptop)
#
# Layout map:
#   Layout 1 — Quick/narrow  (<160 cols)       : dyndef-L  | dyndef-R
#   Layout 2 — Three side    (≥160, <220 cols)  : dyndef-L  | dyndef-R  | dynwide-LL
#   Layout 3 — Fullscreen    (any cols, ≥50r)   : dyndef-L (top) | dyndef-H (bottom)
#   Layout 4 — Wide+full     (≥220 cols, ≥50r)  : dynwide-LL | dyndef-L | dyndef-R (top)
#                                                 dyndef-H (bottom full-width)
#
# Logging: ~/.local/state/tmux/autolayout.log
# Usage:   called via client-resized hook or manually with C-a M-l
# =============================================================================

# ── Config ───────────────────────────────────────────────────────────────────
MAIN="dynamic"
STASH="stash"
LOG_DIR="$HOME/.local/state/tmux"
LOG_FILE="$LOG_DIR/autolayout.log"
MAX_LOG_LINES=500

# Pane names in order of visual priority
PANE_L="dyndef-L"
PANE_R="dyndef-R"
PANE_H="dyndef-H"
PANE_LL="dynwide-LL"

# ── Logging ───────────────────────────────────────────────────────────────────
mkdir -p "$LOG_DIR"

log() {
    local level="$1"
    shift
    local msg="$*"
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$ts] [$level] $msg" >> "$LOG_FILE"
}

# Rotate log if too large
rotate_log() {
    if [ -f "$LOG_FILE" ]; then
        local lines
        lines=$(wc -l < "$LOG_FILE")
        if [ "$lines" -gt "$MAX_LOG_LINES" ]; then
            tail -n "$MAX_LOG_LINES" "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
            log "INFO" "Log rotated (was ${lines} lines, kept ${MAX_LOG_LINES})"
        fi
    fi
}

# ── Utilities ────────────────────────────────────────────────────────────────

count_panes() {
    tmux list-panes -t "$1" 2>/dev/null | wc -l | tr -d ' '
}

find_pane_by_name() {
    # Returns pane index for a given name in a given window, or empty string
    tmux list-panes -t "$1" -F '#{pane_index} #{pane_title}' 2>/dev/null \
        | grep " ${2}$" | head -1 | cut -d' ' -f1
}

name_pane() {
    # name_pane <window> <index> <name>
    tmux select-pane -t "${1}.${2}" -T "$3"
    log "DEBUG" "Named pane ${1}.${2} → '$3'"
}

ensure_window() {
    # Ensure a named tmux window exists (detached)
    local wname="$1"
    if ! tmux list-windows -t "$MAIN" 2>/dev/null | grep -q ": ${wname}[^-]"; then
        if ! tmux list-windows 2>/dev/null | grep -q ": ${wname} "; then
            log "INFO" "Creating window: $wname"
            tmux new-window -d -n "$wname"
        fi
    fi
}

# ── Stash / Recall ───────────────────────────────────────────────────────────

stash_named() {
    local name="$1"
    local idx
    idx=$(find_pane_by_name "$MAIN" "$name")
    if [ -z "$idx" ]; then
        log "DEBUG" "stash_named: '$name' not found in $MAIN — skipping"
        return
    fi
    log "INFO" "Stashing pane '$name' (index $idx) from $MAIN → $STASH"
    ensure_window "$STASH"
    tmux join-pane -d -s "${MAIN}.${idx}" -t "$STASH" -h
    # Re-apply name in stash (join-pane may reset title)
    local stash_idx
    stash_idx=$(count_panes "$STASH")
    tmux select-pane -t "${STASH}.${stash_idx}" -T "$name"
    log "DEBUG" "Stashed as $STASH.$stash_idx titled '$name'"
}

recall_named() {
    local name="$1"
    # Check if already in MAIN
    local existing
    existing=$(find_pane_by_name "$MAIN" "$name")
    if [ -n "$existing" ]; then
        log "DEBUG" "recall_named: '$name' already in $MAIN (index $existing) — skipping"
        return
    fi
    local idx
    idx=$(find_pane_by_name "$STASH" "$name")
    if [ -z "$idx" ]; then
        log "WARN" "recall_named: '$name' not found in $STASH — cannot recall"
        return
    fi
    log "INFO" "Recalling pane '$name' (stash index $idx) → $MAIN"
    tmux join-pane -d -s "${STASH}.${idx}" -t "$MAIN" -h
    # Restore name
    local main_idx
    main_idx=$(count_panes "$MAIN")
    tmux select-pane -t "${MAIN}.${main_idx}" -T "$name"
    log "DEBUG" "Recalled as $MAIN.$main_idx titled '$name'"
}

# ── Init: create all 4 named panes on first run ──────────────────────────────

init_panes() {
    log "INFO" "init_panes: initialising dynamic window panes"
    ensure_window "$STASH"

    # First pane already exists — name it
    name_pane "$MAIN" 1 "$PANE_L"

    local created=("$PANE_L")
    for name in "$PANE_R" "$PANE_H" "$PANE_LL"; do
        local in_main in_stash
        in_main=$(find_pane_by_name "$MAIN" "$name")
        in_stash=$(find_pane_by_name "$STASH" "$name")
        if [ -z "$in_main" ] && [ -z "$in_stash" ]; then
            log "INFO" "init_panes: creating pane '$name'"
            tmux split-window -d -t "$MAIN" -h -c "#{pane_current_path}"
            local idx
            idx=$(count_panes "$MAIN")
            name_pane "$MAIN" "$idx" "$name"
            stash_named "$name"
        else
            log "DEBUG" "init_panes: pane '$name' already exists (main=$in_main stash=$in_stash)"
        fi
    done

    # Start with L and R visible — recall R from stash
    recall_named "$PANE_R"
    tmux select-layout -t "$MAIN" even-horizontal
    log "INFO" "init_panes: done — L+R visible, H+LL in stash"
}

# ── Layout application ────────────────────────────────────────────────────────

apply_layout() {
    local cols="$1"
    local rows="$2"

    # Layout 4: Widescreen + fullscreen (≥220 cols AND ≥50 rows)
    # Top row: dynwide-LL | dyndef-L | dyndef-R
    # Bottom:  dyndef-H (full width)
    if [ "$cols" -ge 220 ] && [ "$rows" -ge 50 ]; then
        log "INFO" "apply_layout: Layout 4 — wide+full (cols=$cols rows=$rows)"
        recall_named "$PANE_R"
        recall_named "$PANE_H"
        recall_named "$PANE_LL"
        tmux select-layout -t "$MAIN" tiled
        tmux display-message "Layout 4 — wide fullscreen (LL | L | R + H below)"

    # Layout 3: Laptop fullscreen (any cols, ≥50 rows)
    # Top: dyndef-L   Bottom: dyndef-H (full width)
    elif [ "$rows" -ge 50 ]; then
        log "INFO" "apply_layout: Layout 3 — laptop fullscreen (cols=$cols rows=$rows)"
        recall_named "$PANE_H"
        stash_named  "$PANE_LL"
        stash_named  "$PANE_R"
        tmux select-layout -t "$MAIN" main-horizontal
        tmux resize-pane -t "${MAIN}.1" -y 60%
        tmux display-message "Layout 3 — fullscreen (L top | H bottom)"

    # Layout 2: Three side-by-side (≥160 cols, compact height)
    # dyndef-L | dyndef-R | dynwide-LL
    elif [ "$cols" -ge 160 ]; then
        log "INFO" "apply_layout: Layout 2 — three side-by-side (cols=$cols rows=$rows)"
        recall_named "$PANE_R"
        recall_named "$PANE_LL"
        stash_named  "$PANE_H"
        tmux select-layout -t "$MAIN" even-horizontal
        tmux display-message "Layout 2 — three panes (L | R | LL)"

    # Layout 1: Quick / narrow (<160 cols)
    # dyndef-L | dyndef-R
    else
        log "INFO" "apply_layout: Layout 1 — quick/narrow (cols=$cols rows=$rows)"
        stash_named  "$PANE_H"
        stash_named  "$PANE_LL"
        recall_named "$PANE_R"
        tmux select-layout -t "$MAIN" even-horizontal
        tmux display-message "Layout 1 — quick (L | R)"
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

rotate_log

COLS=$(tmux display-message -p '#{window_width}')
ROWS=$(tmux display-message -p '#{window_height}')
TRIGGER="${1:-auto}"

log "INFO" "======= autolayout called: trigger='$TRIGGER' cols=$COLS rows=$ROWS ======="

# Check if the dynamic window exists at all
if ! tmux list-windows 2>/dev/null | grep -q ": ${MAIN}"; then
    log "WARN" "Window '$MAIN' not found — skipping layout"
    exit 0
fi

# Init if total pane count across main+stash < 4
TOTAL=$(( $(count_panes "$MAIN") + $(count_panes "$STASH") ))
log "DEBUG" "Pane count — main=$(count_panes "$MAIN") stash=$(count_panes "$STASH") total=$TOTAL"

if [ "$TOTAL" -lt 4 ]; then
    log "INFO" "Total panes < 4, running init_panes"
    init_panes
fi

apply_layout "$COLS" "$ROWS"

log "INFO" "======= autolayout done ======="

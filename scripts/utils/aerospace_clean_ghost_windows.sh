#!/usr/bin/env bash
#
# aerospace-ghosts — find (and optionally close) phantom AeroSpace windows.
#
# A "ghost" is a window AeroSpace still tracks in its tree but whose owning
# process is already dead — it reserves a tiling slot while showing nothing.
# They appear when an app closes a window (or is force-quit) without going
# through `aerospace close`, so AeroSpace never receives the close event.
# The tell: the window's reported PID belongs to no running process.
#
# Usage:
#   aerospace-ghosts           list ghosts only (safe, read-only)
#   aerospace-ghosts --reap    list, then close each via `aerospace close`
#
set -uo pipefail

reap=0
[[ "${1:-}" == "--reap" ]] && reap=1

found=0

# process substitution (not a pipe) so the counter survives the loop
while IFS='|' read -r wid pid name title; do
  [[ "$pid" =~ ^[0-9]+$ ]] || continue            # skip malformed rows
  if ! kill -0 "$pid" 2>/dev/null; then           # process gone -> ghost
    found=$((found + 1))
    printf 'GHOST  win=%-8s pid=%-7s %s  %s\n' "$wid" "$pid" "$name" "$title"
    if (( reap )); then
      if aerospace close --window-id "$wid" 2>/dev/null; then
        echo "       -> closed $wid"
      else
        echo "       -> could not close $wid (window has no close button?)"
      fi
    fi
  fi
done < <(aerospace list-windows --all \
           --format '%{window-id}|%{app-pid}|%{app-name}|%{window-title}')

echo "---"
if (( found == 0 )); then
  echo "No ghosts. Tree is clean."
elif (( reap )); then
  echo "$found ghost(s) processed."
else
  echo "$found ghost(s) found. Run with --reap to close them."
fi

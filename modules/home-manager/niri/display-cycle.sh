#!/usr/bin/env bash
# Cycle external display: extend -> external-only -> panel-only -> extend.
# (GNOME Super+P equivalent, minus mirror: niri 26.04 has no mirror — neither
#  `niri msg output ... mirror` nor a config `mirror` node, verified live
#  15.10.2026. External-only covers the "present on projector" use case.)
# Positions are saved/restored via state files, so any layout round-trips.
set -eu
internal="eDP-1"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}"
state_file="$state_dir/niri-display-mode"
extpos_file="$state_dir/niri-external-pos"
panelpos_file="$state_dir/niri-panel-pos"

external=$(niri msg outputs | grep -oE '\((DP|HDMI)-[0-9]+\)' | tr -d '()' | head -1 || true)
[ -z "$external" ] && exit 0  # panel only, nothing to toggle

get_pos() { # $1 = output short name; prints "X Y" or empty
  niri msg outputs | grep -A8 "($1)" | grep -i "logical position" | grep -oE "[0-9-]+, [0-9-]+" | head -1 | tr ',' ' ' || true
}

mode="extend"
[ -f "$state_file" ] && mode=$(cat "$state_file")

case "$mode" in
  extend)
    # -> external-only: remember both positions, panel off last
    mkdir -p "$state_dir"
    echo "$(get_pos "$external")" > "$extpos_file"
    echo "$(get_pos "$internal")" > "$panelpos_file"
    niri msg output "$external" on
    niri msg output "$internal" off
    echo "external" > "$state_file"
    ;;
  external)
    # -> panel-only: panel on first (never leave zero outputs), external off
    niri msg output "$internal" on
    niri msg output "$external" off
    echo "panel" > "$state_file"
    ;;
  *)
    # -> extend: both on, then restore saved positions
    niri msg output "$external" on
    niri msg output "$internal" on
    if [ -s "$extpos_file" ]; then
      read -r sx sy < "$extpos_file"
      niri msg output "$external" position set "$sx" "$sy"
    fi
    if [ -s "$panelpos_file" ]; then
      read -r px py < "$panelpos_file"
      niri msg output "$internal" position set "$px" "$py"
    fi
    echo "extend" > "$state_file"
    ;;
esac

#!/usr/bin/env bash
# Cycle external display: extend -> external-only -> panel-only -> mirror -> extend.
# (GNOME Super+P equivalent. niri 26.04 has no native mirror — neither
#  `niri msg output ... mirror` nor a config `mirror` node, verified live
#  15.10.2026 — so the mirror state is wl-mirror fullscreen on the external
#  output, capturing the internal panel. Cursor is visible in the mirror;
#  leaving the state kills wl-mirror and restores extend exactly.)
# Positions are saved/restored via state files, so any layout round-trips.
# Works with DP-*, USB-C or HDMI-* external outputs; no external -> no-op.
set -eu
internal="eDP-1"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}"
state_file="$state_dir/niri-display-mode"
extpos_file="$state_dir/niri-external-pos"
panelpos_file="$state_dir/niri-panel-pos"
wl_mirror_bin="${WL_MIRROR:-wl-mirror}"

external=$(niri msg outputs | grep -oE '\((DP|HDMI)-[A-Za-z0-9-]+\)' | tr -d '()' | head -1 || true)
if [ -z "$external" ]; then
  # no external: leave mirror state cleanly, back to extend defaults
  pkill -x wl-mirror 2>/dev/null || true
  echo "extend" > "$state_file"
  exit 0
fi

cleanup_mirror() { pkill -x wl-mirror 2>/dev/null || true; }
trap cleanup_mirror EXIT

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
  panel)
    # -> mirror: both on, restore positions, wl-mirror fullscreen on external
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
    echo "mirror" > "$state_file"
    # Detach wl-mirror from this script's lifecycle: EXIT trap must NOT kill
    # it while the state is mirror — start it after re-arming the trap.
    trap - EXIT
    exec "$wl_mirror_bin" --fullscreen --fullscreen-output "$external" "$internal" &
    disown
    ;;
  *)
    # -> extend (from mirror or unknown): kill wl-mirror, both on, restore
    cleanup_mirror
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
#!/usr/bin/env bash
# Usage: update.sh [target]   (default target: current hostname)
#
#   caladan / giedi-prime  local flow: nh os boot (-u / flake update only on
#                          caladan — only caladan may advance flake.lock,
#                          otherwise divergent locks collide on push)
#   cardassia              on cardassia itself: same local flow (no -u,
#                          --impure for private.nix). From any other host:
#                          commit+push local changes, then ssh to cardassia
#                          and run update.sh there (cardassia pulls what was
#                          pushed and rebuilds locally as flex).
#   rura-penthe            remote build + deploy from caladan
#                          (nixos-rebuild switch --target-host). From any
#                          other host: abort — build on caladan, deploy
#                          from there.
#   omnius                 same as rura-penthe: build on caladan, deploy
#                          via nixos-rebuild switch --target-host, then
#                          attic push. From any other host: abort.
#
# Without `set -o pipefail`, `if ! nh os boot ... | tee` would test tee's
# exit status — a build failure would be swallowed and a broken flake.lock
# committed+pushed.
set -o pipefail

FLAKE="/home/flex/flexos"
TARGET="${1:-$HOSTNAME}"
HOST="$HOSTNAME"
LOG="$FLAKE/log/nixos-update-$TARGET.log"
DATE=$(date)

# Dispatch to a MODE. The local flow runs when the target is this host; the
# cardassia delegate re-execs via ssh (flex runs the eval there, so
# ~/.config/flexos-private/cardassia.nix resolves; nh asks for sudo).
MODE="local"
case "$TARGET" in
  "$HOST") MODE="local" ;;
  cardassia) MODE="cardassia-ssh" ;;
  rura-penthe|omnius)
    if [ "$HOST" != "caladan" ]; then
      echo "FEHLER: $TARGET wird von caladan aus gebaut und deployt." >&2
      echo "  Auf caladan ausführen:  $0 $TARGET" >&2
      exit 1
    fi
    MODE="remote-deploy"
    ;;
  *)
    echo "Unbekanntes Ziel: '$TARGET'" >&2
    echo "Unterstützt: caladan, giedi-prime, cardassia, rura-penthe, omnius" >&2
    echo "(lokal auf dem jeweiligen Host, cardassia/rura-penthe/omnius wie oben)" >&2
    exit 1
    ;;
esac

cd ~/flexos

echo "Changes (git diff):"
echo "====================================================="
echo
git diff
echo
read -r -e -p "Commit message [update - $HOSTNAME]: " COMMIT_MSG || COMMIT_MSG=""
COMMIT_MSG=${COMMIT_MSG:-"update - $HOSTNAME"}

pushd $FLAKE && git pull --rebase --autostash && (git commit -a -m "$COMMIT_MSG" || true) && popd

# Pull the private ssh-config sync repo (modules/home-manager/ssh reads it
# at build time). Not fatal if it isn't cloned yet on this host — see
# modules/home-manager/ssh/default.nix for the bootstrap command.
PRIVATE_SYNC="$HOME/.config/flexos-private-sync"
[ -d "$PRIVATE_SYNC/.git" ] && (cd "$PRIVATE_SYNC" && git pull --rebase --autostash)

if [ "$MODE" = "cardassia-ssh" ]; then
  # Push first so cardassia's `git pull` inside its own update.sh gets the
  # latest state; gate the delegate on a full flake check (catches eval
  # errors for OTHER hosts too, which the cardassia build alone wouldn't).
  pushd $FLAKE
  if nix flake check --impure && git push; then
    popd
    echo "===== DELEGATE cardassia (ssh, flex@cardassia) ===== $(date)" >>"$LOG"
    exec ssh -t flex@cardassia '~/flexos/update.sh'
  else
    popd
    echo "nix flake check/push failed — skipping cardassia update" >&2
    exit 1
  fi
fi

# Only caladan advances flake.lock (the -u flag below). Other hosts rebuild
# against whatever lock caladan already pushed — running `nix flake update`
# from multiple hosts causes divergent-lock merge conflicts.
UPDATE_FLAG=""
[ "$HOST" = "caladan" ] && UPDATE_FLAG="-u"

echo "===== UPDATE ($TARGET) ===== $DATE" >>$LOG

if [ "$MODE" = "remote-deploy" ]; then
  # Remote build + deploy from caladan. Server ⇒ switch (activates
  # immediately), matching the documented deploy command.
  if ! nixos-rebuild switch --flake "$FLAKE#$TARGET" --target-host "root@$TARGET" | tee -a $LOG; then
    echo "Deploy auf $TARGET fehlgeschlagen" >&2
    exit 1
  fi
  # Push the new closure to the attic cache so the host can pull it back
  # after a nh clean (GC recovery) instead of rebuilding.
  TGL=$(nix eval --raw "$FLAKE#nixosConfigurations.$TARGET.config.system.build.toplevel")
  (setsid nix shell nixpkgs#attic-client -c attic push -j1 flexos "$TGL" >>"$LOG" 2>&1) &
  disown
  pushd $FLAKE && (nix flake check --impure && git push || echo "nix flake check failed — not pushing" >&2) && popd
  exit 0
fi

# Local flow (caladan / giedi-prime / cardassia on itself).
if ! nh os boot $UPDATE_FLAG --impure $FLAKE --ask | tee -a $LOG; then
  echo "nh os boot failed — skipping commit of flake.lock and push" >&2
  exit 1
fi

# Commit + push the flake.lock update produced by `nh os boot -u` (caladan)
# so the other hosts can `git pull` it instead of generating their own.
# Gate the push on `nix flake check`: the boot above only built *this* host,
# a broken eval for a different host wouldn't be caught by that build alone.
pushd $FLAKE && (git commit -a -m "$COMMIT_MSG" || true) && (nix flake check --impure && git push || echo "nix flake check failed — not pushing" >&2) && popd

nh os info

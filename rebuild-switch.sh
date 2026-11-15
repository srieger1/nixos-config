#!/usr/bin/env bash
# Usage: rebuild-switch.sh [target]   (default target: current hostname)
#
#   caladan / giedi-prime  local flow: nh os switch
#   cardassia              on cardassia itself: same local flow (--impure for
#                          private.nix). From any other host: commit+push
#                          local changes, then ssh to cardassia and run
#                          rebuild-switch.sh there.
#   rura-penthe            remote build + deploy from caladan
#                          (nixos-rebuild switch --target-host) + attic push
#                          of the new rura-penthe closure. From any other
#                          host: abort — build on caladan, deploy from there.
#   omnius                 same as rura-penthe: build on caladan, deploy
#                          via nixos-rebuild switch --target-host, then
#                          attic push. From any other host: abort.
set -o pipefail

FLAKE="/home/flex/flexos"
TARGET="${1:-$HOSTNAME}"
HOST="$HOSTNAME"
LOG="$FLAKE/log/nixos-update-$TARGET.log"
DATE=$(date)

# Dispatch — same rules as update.sh (see the header there for the model:
# only caladan advances flake.lock; cardassia rebuilds locally as flex;
# rura-penthe is deployed from caladan).
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

cd /home/flex/flexos

echo "Changes (git diff):"
echo "====================================================="
echo ""
echo
git diff
echo
read -r -e -p "Commit message [rebuild - $HOSTNAME]: " COMMIT_MSG || COMMIT_MSG=""
COMMIT_MSG=${COMMIT_MSG:-"rebuild - $HOSTNAME"}
pushd $FLAKE && git pull --rebase --autostash && (git commit -a -m "$COMMIT_MSG" || true) && popd

PRIVATE_SYNC="$HOME/.config/flexos-private-sync"
[ -d "$PRIVATE_SYNC/.git" ] && (cd "$PRIVATE_SYNC" && git pull --rebase --autostash)

if [ "$MODE" = "cardassia-ssh" ]; then
  # Push first so cardassia's `git pull` inside its own rebuild-switch.sh
  # gets the latest state; gate the delegate on a full flake check.
  pushd $FLAKE
  if nix flake check --impure && git push; then
    popd
    echo "===== DELEGATE cardassia (ssh, flex@cardassia) ===== $(date)" >>"$LOG"
    exec ssh -t flex@cardassia '~/flexos/rebuild-switch.sh'
  else
    popd
    echo "nix flake check/push failed — skipping cardassia rebuild" >&2
    exit 1
  fi
fi

echo "===== REBUILD ($TARGET) ===== $DATE" >>$LOG

if [ "$MODE" = "remote-deploy" ]; then
  # Remote build + deploy from caladan (server ⇒ switch), then push the new
  # closure to the attic cache for GC recovery / fast pulls.
  if ! nixos-rebuild switch --flake "$FLAKE#$TARGET" --target-host "root@$TARGET" | tee -a $LOG; then
    echo "Deploy auf $TARGET fehlgeschlagen" >&2
    exit 1
  fi
  TGL=$(nix eval --raw "$FLAKE#nixosConfigurations.$TARGET.config.system.build.toplevel")
  (setsid nix shell nixpkgs#attic-client -c attic push -j1 flexos "$TGL" >>"$LOG" 2>&1) &
  disown
  pushd $FLAKE && (nix flake check --impure && git push || echo "nix flake check failed — not pushing" >&2) && popd
  exit 0
fi

# Local flow (caladan / giedi-prime).
if ! nh os switch --impure $FLAKE --ask | tee -a $LOG; then
  echo "nh os switch failed — skipping flake check and push" >&2
  exit 1
fi
pushd $FLAKE && (nix flake check --impure && git push || echo "nix flake check failed — not pushing" >&2) && popd

# Push the new system closure to the attic cache (flexos, on cardassia) so
# openlogi, containerlab and pumpkin don't get rebuilt on giedi-prime and
# rura-penthe. Fire-and-forget in the background; failures must not abort.
(setsid nix shell nixpkgs#attic-client -c attic push -j1 flexos /run/current-system >>"$LOG" 2>&1) &
disown

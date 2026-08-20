#!env bash
#sudo nixos-rebuild switch --flake ~/flexos#$HOSTNAME
#sudo nixos-rebuild switch --flake ~/flexos
FLAKE="/home/flex/flexos"
LOG="$FLAKE/log/nixos-update-$HOSTNAME.log"
DATE=$(date)
echo "===== REBUILD ===== $DATE" >>$LOG
pushd $FLAKE && git pull --rebase && (git commit -a -m "rebuild - $HOSTNAME" || true) && (nix flake check --impure && git push || echo "nix flake check failed — not pushing" >&2) && popd

PRIVATE_SYNC="$HOME/.config/flexos-private-sync"
[ -d "$PRIVATE_SYNC/.git" ] && (cd "$PRIVATE_SYNC" && git pull --rebase)
nh os switch --impure $FLAKE --ask | tee -a $LOG

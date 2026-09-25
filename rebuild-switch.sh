#!env bash
#sudo nixos-rebuild switch --flake ~/flexos#$HOSTNAME
#sudo nixos-rebuild switch --flake ~/flexos
FLAKE="/home/flex/flexos"
LOG="$FLAKE/log/nixos-update-$HOSTNAME.log"
DATE=$(date)
echo "===== REBUILD ===== $DATE" >>$LOG
set -o pipefail

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
if ! nh os switch --impure $FLAKE --ask | tee -a $LOG; then
  echo "nh os switch failed — skipping flake check and push" >&2
  exit 1
fi
pushd $FLAKE && (nix flake check --impure && git push || echo "nix flake check failed — not pushing" >&2) && popd

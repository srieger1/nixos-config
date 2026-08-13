#!env bash
#sudo nixos-rebuild switch --flake ~/flexos#$HOSTNAME
#sudo nixos-rebuild switch --flake ~/flexos
FLAKE="/home/flex/flexos"
LOG="$FLAKE/log/nixos-update-$HOSTNAME.log"
DATE=$(date)
echo "===== REBUILD ===== $DATE" >>$LOG
pushd $FLAKE && git pull --rebase && (git commit -a -m "rebuild" || true) && git push && popd
nh os switch $FLAKE --ask | tee -a $LOG

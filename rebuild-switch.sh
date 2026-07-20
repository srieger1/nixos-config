#!env bash
#sudo nixos-rebuild switch --flake ~/flexos#$HOSTNAME
#sudo nixos-rebuild switch --flake ~/flexos
FLAKE="/home/flex/flexos"
LOG="$FLAKE/log/nixos-update-$HOSTNAME.log"
DATE=$(date)
echo "===== REBUILD ===== $DATE" >>$LOG
pushd $FLAKE && git commit -a -m "rebuild" && popd
nh os switch -u $FLAKE --ask | tee -a $LOG

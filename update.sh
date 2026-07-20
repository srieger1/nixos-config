#!env bash
#HOSTNAME=$(hostname)

# needed in case of "ln: failed to create symbolic link '/nix/store/ user-units/xdg-desktop-portal-gtk.service': File exists"
#nix-collect-garbage -d

##sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5
##sudo nix-env -p /nix/var/nix/profiles/system --delete-generations 5d 
#sudo nix-env -p /nix/var/nix/profiles/system --delete-generations 14d 
#sudo nix-collect-garbage --delete-older-than 14d
##ls -l /boot/EFI/nixos
#sudo /run/current-system/bin/switch-to-configuration boot
##ls -l /boot/EFI/nixos
##nix-env --list-generations
##nixos-rebuild list-generations

FLAKE="/home/flex/flexos"
LOG="$FLAKE/log/nixos-update-$HOSTNAME.log"
DATE=$(date)

#cd ~
#pushd ~/flexos && nix flake update && git commit -a -m "update" && popd
pushd $FLAKE && git commit -a -m "update" && popd
#~/flexos/rebuild-switch.sh
#sudo nixos-rebuild switch --flake ~/flexos#$HOSTNAME
nh os info

echo "===== UPDATE ===== $DATE" >>$LOG
#nh os switch -u $FLAKE --ask | tee -a $LOG
nh os boot -u $FLAKE --ask | tee -a $LOG
#nh clean all --optimise --max --keep-since 14d -k 7 
#nh clean all --keep-since 14d -k 10 

#Handling Full /boot: If your boot partition is already 100% full, nh might fail just like standard tools. In that case, you must manually delete old kernels from /boot/EFI/nixos/ and nixos-rebuild boot or nh to restore functionality.
#User Permission: Always run nh clean with sudo if you want to clean system-level generations. 

nh os info

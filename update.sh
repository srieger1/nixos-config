#!/usr/bin/env bash
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

# Only caladan is allowed to advance flake.lock (nix flake update, the -u flag
# below). Running `nix flake update` from multiple hosts and pushing
# independently causes divergent flake.lock merge conflicts. Other hosts
# (e.g. giedi-prime) rebuild against whatever lock caladan already pushed.
UPDATE_FLAG=""
[ "$HOSTNAME" = "caladan" ] && UPDATE_FLAG="-u"

#cd ~
pushd $FLAKE && git pull --rebase && (git commit -a -m "update - $HOSTNAME" || true) && popd

# Pull the private ssh-config sync repo (modules/home-manager/ssh reads it
# at build time). Not fatal if it isn't cloned yet on this host — see
# modules/home-manager/ssh/default.nix for the bootstrap command.
PRIVATE_SYNC="$HOME/.config/flexos-private-sync"
[ -d "$PRIVATE_SYNC/.git" ] && (cd "$PRIVATE_SYNC" && git pull --rebase)
#~/flexos/rebuild-switch.sh
#sudo nixos-rebuild switch --flake ~/flexos#$HOSTNAME
nh os info

echo "===== UPDATE ===== $DATE" >>$LOG
#nh os switch -u $FLAKE --ask | tee -a $LOG
nh os boot $UPDATE_FLAG --impure $FLAKE --ask | tee -a $LOG
#nh clean all --optimise --max --keep-since 14d -k 7 
#nh clean all --keep-since 14d -k 10 

#Handling Full /boot: If your boot partition is already 100% full, nh might fail just like standard tools. In that case, you must manually delete old kernels from /boot/EFI/nixos/ and nixos-rebuild boot or nh to restore functionality.
#User Permission: Always run nh clean with sudo if you want to clean system-level generations. 

# Commit + push the flake.lock update produced by `nh os boot -u` (caladan) so
# the other host can `git pull` it instead of generating its own. Gate the
# push on `nix flake check`: `nh os boot` above only built *this* host, a
# broken eval for a different host wouldn't be caught by that build alone,
# and giedi-prime pulls whatever lands here.
pushd $FLAKE && (git commit -a -m "update - $HOSTNAME" || true) && (nix flake check --impure && git push || echo "nix flake check failed — not pushing" >&2) && popd

nh os info

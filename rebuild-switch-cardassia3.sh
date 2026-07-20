#!/usr/bin/env bash
FLAKE="/home/flex/flexos"
HOST="cardassia3"
TARGET="root@cardassia3"
REMOTE_FLAKE="/root/flexos"
LOG="$FLAKE/log/nixos-update-$HOST.log"
DATE=$(date)
echo "===== REBUILD $HOST ===== $DATE" >>$LOG
pushd $FLAKE && git commit -a -m "rebuild" && popd
# rsync without .git so nix sees the dir as plain (not a git repo),
# which means private.nix is visible despite being gitignored
rsync -a --delete --exclude='.git' "$FLAKE/" "$TARGET:$REMOTE_FLAKE/"
ssh "$TARGET" "rm -rf $REMOTE_FLAKE/.git && chown -R root:root $REMOTE_FLAKE"
ssh "$TARGET" "nixos-rebuild switch --flake $REMOTE_FLAKE#$HOST" 2>&1 | tee -a $LOG

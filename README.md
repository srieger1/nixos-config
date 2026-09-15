# flexnet nix-config 

Personal NixOS flake configuration — hosts: `caladan` (laptop/desktop, unstable), `giedi-prime` (laptop, stable), `cardassia` (headless server VM, stable), `rura-penthe` (Proxmox VM with a Pumpkin Minecraft server, unstable).

All rebuilds assume the flake at `~/flexos` and rely on `nh`. Public repo — private values live *outside* it (see below).

## Hosts & workflows

### caladan (primary machine)

```bash
# Apply local changes: commit + push + switch (asks for confirmation)
./rebuild-switch.sh

# Update the flake: bump flake.lock, then boot into the new generation
./update.sh
```

`update.sh` is the only place `flake.lock` is advanced (`nh os boot -u`); every other host rebuilds against the lock caladan pushed. The push is gated on `nix flake check` so a broken eval never lands for the other hosts.

### giedi-prime (second laptop)

Same script as caladan — without the `-u` flag, so it never advances
`flake.lock`, it only pulls what caladan pushed:

```bash
./update.sh
```

Equivalent manual form: `cd ~/flexos && git pull --rebase && nh os boot --impure`.
`update.sh` additionally pulls `~/.config/flexos-private-sync`, logs to
`~/flexos/log/` and runs `nix flake check` before its (no-op) push.

### cardassia (headless server VM)

Log in on the machine itself and rebuild locally (`switch` is safe — no desktop):

```bash
cd ~/flexos && git pull --rebase && nh os switch --impure
```

### rura-penthe (Proxmox VM, Pumpkin Minecraft server)

Deployed remotely from caladan — no login needed:

```bash
nixos-rebuild switch --flake ~/flexos#rura-penthe --target-host root@192.168.78.224
```

Root is authorized via caladan's SSH key; the IP is pinned by a router DHCP lease. First-time provisioning built the VM from the same eval: `nix build .#rura-penthe-proxmox-image` → import the resulting `vzdump-qemu-rura-penthe.vma.zst` with `qmrestore` on the Proxmox host.

## Private values (outside the repo)

The flake is public, so secrets and undisclosed values (static IPs, hostnames, tunnel IDs, ssh-config) never live in it. Flakes also only see *git-tracked* files — gitignoring a file inside the repo would silently break it — hence both locations live outside:

**`~/.config/flexos-private/<host>.nix`** — per-host values read by `flake.nix`'s `privateFor` at eval time (currently `cardassia` and `giedi-prime`; rura-penthe and caladan have none). Requires `--impure` on any manual `nixos-rebuild`/`nh`/`nix build` run — the scripts already pass it. Bootstrap a host's file from the checked-in example:

```bash
mkdir -p ~/.config/flexos-private
cp hosts/<host>/private.nix.example ~/.config/flexos-private/<host>.nix
$EDITOR ~/.config/flexos-private/<host>.nix   # fill in real values
```

If the file is missing, the flake falls back to the `.example` placeholder (eval succeeds, but the host won't be usable with real values).

**`~/.config/flexos-private-sync/`** — a small private git repo (bare repo at `cardassia:git/flexos-private.git`) shared across hosts. Currently holds `ssh-config`, which `modules/home-manager/ssh` links to `~/.ssh/config` at build time. `rebuild-switch.sh`/`update.sh` pull it alongside the flake. Bootstrap on a new host:

```bash
git clone cardassia:git/flexos-private.git ~/.config/flexos-private-sync
```

Edit values by committing in those repos — a change to `flexos-private-sync` lands on a host after the next `git pull` there (both scripts pull before rebuilding).

## Sanity check

```bash
nix flake check          # evaluate all hosts without building
nix flake check --impure # needed on hosts whose private files exist
```

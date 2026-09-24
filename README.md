# flexnet nix-config 

Personal NixOS flake configuration — hosts: `caladan` (laptop/desktop, unstable), `giedi-prime` (laptop, stable), `cardassia` (headless server VM, stable), `rura-penthe` (Proxmox VM with a Pumpkin Minecraft server, unstable).

All rebuilds assume the flake at `~/flexos` and rely on `nh`. Public repo — private values live *outside* it (see below).

## DISCLAIMER

This flake is a boring, minimalistic config using NixOS the lazy way. I've got a life, I've got three kids and a challenging job. I see fancy concepts like dendritic pattern, disko etc. that would be more elegant and even more declarative, but I do not have the time to maintain their configuration and integrating every nice new concept. Instead, I enjoy Nix giving me what I missed since using Linux in the mid 90ies: even after years of using the same system having a clean and declarative config for my machines. Time constraints are also the reason why I started using AI coding agents to maintain parts of this flake in mid 2026 (using, e.g., omp and/or claude code).

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

Root is authorized via caladan's SSH key; the IP is pinned by a router DHCP lease.

#### Proxmox image build

The VM was first provisioned from an image built by the *same* flake eval that
also serves the running system — image and deployed config can never drift.
Build and import it like this:

```bash
nix build .#rura-penthe-proxmox-image
scp result/vzdump-qemu-rura-penthe.vma.zst root@<pve-host>:/tmp/
# on the Proxmox host:
qmrestore /tmp/vzdump-qemu-rura-penthe.vma.zst <VMID> --storage local-lvm
```

The pattern scales to further Proxmox hosts: import the upstream
`nixos/modules/virtualisation/proxmox-image.nix` in the host's
`configuration.nix` (see `hosts/rura-penthe/configuration.nix`) and add a
`packages.<system>.<host>-proxmox-image = self.nixosConfigurations.<host>.config.system.build.image`
output in `flake.nix`. Rebuilds of an existing VM need no image — just the
`--target-host` deploy above.
Hosts whose values come from `~/.config/flexos-private` (currently
`giedi-prime`, `cardassia`) need `--impure` on the image build:
`nix build --impure .#<host>-proxmox-image`.

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

## devenv environments & store cleanup

devenv registers each project's current environment as a GC root
(`/nix/var/nix/gcroots/auto` → the project's `.devenv/gc/*` symlinks), so the
daily `nh clean` collects everything **except** the latest environment of
every devenv project. Old versions (including tried-out packages) vanish
automatically once you re-enter the project after changing `devenv.nix`.

```bash
# Find all devenv projects (no depth cap — some live deep in Nextcloud):
find ~ -name devenv.nix -not -path '*/.cache/*' 2>/dev/null

# See which projects currently pin store paths (the registered roots):
ls -l /nix/var/nix/gcroots/auto | grep .devenv

# Update a project's devenv.lock and rebuild:
cd <project> && devenv update && devenv shell

# Prune old generations of a project's environment:
cd <project> && devenv gc

# Retire an abandoned project — releases its environment to the next
# `nh clean` run (the stale entry in gcroots/auto is harmless):
rm -rf <project>/.devenv
```

Note: the central `~/.local/share/devenv/gc/` directory is devenv-internal
bookkeeping, *not* GC roots — do not bother pruning it. Store paths freed by
deleting roots are collected by the next `nh clean` (daily 06:00).


## Sanity check

```bash
nix flake check          # evaluate all hosts without building
nix flake check --impure # needed on hosts whose private files exist
```

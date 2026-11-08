# omnius — Proxmox VM running the Paseo daemon plus the coding agent CLIs
# (claude code, omp, pi, opencode) and hermes with its Matrix gateway.
# Named after Omnius, the distributed AI consciousness from Dune.
#
# Same deployment model as rura-penthe: the *same* evaluation builds both
# the running system and the importable Proxmox image, so they can never
# drift:
#
#   nix build .#omnius-proxmox-image      # → vzdump-qemu-omnius.vma.zst
#   scp result/vzdump-qemu-omnius.vma.zst root@<pve-host>:/tmp/
#   qmrestore /tmp/vzdump-qemu-omnius.vma.zst <VMID> --storage local-lvm
#
# After the first boot, rebuilds deploy straight from caladan:
#   nixos-rebuild switch --flake ~/flexos#omnius --target-host root@omnius
#
# Runs on nixpkgs-unstable: the agent CLIs move fast and omnius is an agent
# host (matches caladan/rura-penthe; stable would pin stale claude-code etc.).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # claude-code is unfree.
  nixpkgs.config.allowUnfree = true;

  imports = [
    # Proxmox image support: disk layout (root on /dev/disk/by-label/nixos,
    # GRUB on /dev/vda), qemu-guest-agent, sshd, and the VMA image build
    # output consumed by the flake's `omnius-proxmox-image` package.
    "${inputs.nixpkgs-unstable}/nixos/modules/virtualisation/proxmox-image.nix"
  ];

  # VM shape baked into the generated qemu-server.conf (adjustable in PVE
  # afterwards). Sized for parallel agent sessions: 4 cores / 8 GiB like the
  # initial Debian VM.
  #
  # Disk: keep the image SMALL (~10 GiB: ~6 GiB agent closure + 4G headroom).
  # make-disk-image's cptofs (LKL, hardcoded mem=100M) kernel-panics with
  # "System is deadlocked on memory" when the target filesystem gets large
  # (known upstream issue; rura-penthe's ~12G image works, 32G does not).
  # The root filesystem auto-grows on boot (growPartition + autoResize), so
  # enlarge the disk in PVE after the import (e.g. `qm resize` to 64G) and
  # the first boot extends it.
  proxmox.qemuConf = {
    name = "omnius";
    cores = 4;
    memory = 8192;
    additionalSpace = "4G";
  };
  # No cloud-init: hostname and DHCP come from this config, so the guest is
  # self-contained. Pin the VM's DHCP lease to 192.168.78.231 in the router
  # (the address the existing ~/.ssh/config entry uses) or switch to a
  # static IP here, cardassia-style via private.nix.
  proxmox.cloudInit.enable = false;

  # The agent CLI closure (claude-code, omp, pi, opencode, paseo, hermes) is
  # far larger than rura-penthe's: diskSize "auto" sizes the image to fit it.
  virtualisation.diskSize = "auto";

  networking = {
    hostName = "omnius";
    useDHCP = true;
    networkmanager.enable = false;
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  # Root is the deploy target (`nixos-rebuild ... --target-host root@omnius`),
  # reachable with caladan's key only — no password login anywhere. flex
  # exists for the agent/user services (paseo daemon, hermes gateway run as
  # systemd user units, enabled via `linger` below).
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKY9jyesFbszrveSupV0WlbxMjPR4kCkZe3tFkqQ9xe flex@cardassia"
  ];
  users.users.flex = {
    isNormalUser = true;
    description = "Sebastian Rieger";
    extraGroups = [ "wheel" ];
    # Keep user services alive at boot without an active login session.
    linger = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKY9jyesFbszrveSupV0WlbxMjPR4kCkZe3tFkqQ9xe flex@cardassia"
    ];
  };

  home-manager = {
    # Same pattern as caladan: reuse the system's unstable pkgs for
    # home-manager and pass the flake inputs through to HM modules.
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users = {
      "flex" = import ./home.nix;
    };
  };

  services.openssh.enable = true;

  # Paseo daemon listens on all interfaces (runtime setting in
  # ~/.paseo/config.json, set to 0.0.0.0:6767 after first boot — paseo owns
  # that file); the firewall restricts 6767 to the tailnet so LAN stays out.
  # Desktop app + iOS app connect via Tailscale (MagicDNS name `omnius`).
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 6767 ];

  # Phone access: paseo clients (iOS app) connect to the daemon over the
  # tailnet instead of paseo's e2ee relay. One-time `sudo tailscale up`
  # needed after first boot.
  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    htop
    git

    # Coding agent CLIs, driven by the paseo daemon (user service in home.nix).
    omp
    claude-code
    pi-coding-agent
    opencode
    paseo
  ];

  system.stateVersion = "26.11"; # Did you read the comment?
}

# rura-penthe — Proxmox VM running Pumpkin, a Minecraft server written in Rust.
#
# Deployment model (different from the other hosts): the *same* evaluation
# builds both the running system and the importable Proxmox image, so they
# can never drift:
#
#   nix build .#rura-penthe-proxmox-image   # → vzdump-qemu-rura-penthe.vma.zst
#   scp result/vzdump-qemu-rura-penthe.vma.zst root@<pve-host>:/tmp/
#   qmrestore /tmp/vzdump-qemu-rura-penthe.vma.zst <VMID> --storage local-lvm
#
# After the first boot, rebuilds deploy straight from caladan:
#   nixos-rebuild switch --flake ~/flexos#rura-penthe --target-host root@192.168.78.224
# (root is reachable via the authorized key below; no secrets on the guest,
#  so no sops-nix setup is needed — add it here if pumpkin ever grows one,
#  e.g. an RCON password via services.pumpkin.settings.networking.rcon.passwordFile.)
#
# Runs on nixpkgs-unstable: the pumpkin package and its NixOS module only
# exist there (neither is in stable nixos-26.05).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    # Proxmox image support: disk layout (root on /dev/disk/by-label/nixos,
    # GRUB on /dev/vda), qemu-guest-agent, sshd, and the VMA image build
    # output consumed by the flake's `rura-penthe-proxmox-image` package.
    "${inputs.nixpkgs-unstable}/nixos/modules/virtualisation/proxmox-image.nix"
  ];

  # VM shape baked into the generated qemu-server.conf (all adjustable in
  # PVE afterwards). 8G headroom on top of the NixOS closure for worlds,
  # backups and nix store growth; the root filesystem auto-grows on boot.
  proxmox.qemuConf = {
    name = "rura-penthe";
    cores = 2;
    memory = 2048;
    additionalSpace = "8G";
  };
  # No cloud-init: hostname and DHCP come from this config, so the guest is
  # self-contained. Pin the VM's DHCP lease in the router (or switch to a
  # static IP here, cardassia-style) if it needs a stable address.
  proxmox.cloudInit.enable = false;

  networking = {
    hostName = "rura-penthe";
    useDHCP = true;
    networkmanager.enable = false;
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  # Root is the deploy target (`nixos-rebuild ... --target-host root@192.168.78.224`),
  # reachable with caladan's key only — no password login anywhere. flex
  # exists for interactive sessions; give it a password with `passwd` if
  # sudo is ever needed (root's key makes that unnecessary for deploys).
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKY9jyesFbszrveSupV0WlbxMjPR4kCkZe3tFkqQ9xe flex@cardassia"
  ];
  users.users.flex = {
    isNormalUser = true;
    description = "Sebastian Rieger";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKY9jyesFbszrveSupV0WlbxMjPR4kCkZe3tFkqQ9xe flex@cardassia"
    ];
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    htop
    git
  ];

  # Pumpkin: everything at upstream defaults (port 25565 java + bedrock,
  # RCON disabled by default, whitelist off). Data lives in /var/lib/pumpkin
  # (systemd StateDirectory). Extend `settings` freely — it becomes
  # pumpkin.toml; missing keys keep pumpkin's built-in defaults.
  #
  # The stdin console must stay off under systemd: on EOF (stdin is
  # /dev/null) the console receiver task busy-loops at ~130% CPU —
  # `rx.recv()` on the closed channel returns None immediately and the
  # `while SHOULD_STOP { if let Some(...) }` loop never exits
  # (Pumpkin-MC/Pumpkin#2863, fixed by #2524, but the nixpkgs pin
  # 0dfaf5d predates it and no newer nixpkgs pin exists yet). Server
  # administration runs over RCON instead if ever needed — enable
  # settings.networking.rcon + a passwordFile (sops-nix) for that.
  # Access control: the server is exposed publicly (players have dynamic
  # IPs, VPN is too much friction for one of them). Mojang online-mode
  # auth (module default) plus this whitelist means exactly these two
  # Microsoft accounts can join — no password auth exists that could be
  # brute-forced, so no fail2ban is needed on top. The module writes
  # whitelist.json on first start; in-game /whitelist changes to the file
  # are deliberately not overwritten by later rebuilds.
  services.pumpkin = {
    enable = true;
    openFirewall = true;
    settings.commands.use_console = false;
    settings.white_list = true;
    settings.enforce_whitelist = true;
    whitelist.entries = [
      {
        uuid = "67b73e60-20e9-43a4-8457-1e90a752f51e";
        name = "flexobrian";
      }
      {
        uuid = "a202c7c1-36a5-4d37-83d6-44710991474d";
        name = "Relian2018";
      }
    ];
  };

  # Pumpkin 0.1.0 loads ban/whitelist/ops JSON from <stateDir>/data/ (DATA_FOLDER),
  # while the NixOS module installs whitelist.json into the state dir root —
  # without this link the server starts with an EMPTY whitelist and rejects
  # every whitelisted account. Relative symlink: in-game /whitelist add writes
  # through it into the module-managed file, so both stay one source of truth.
  systemd.services.pumpkin.preStart = ''
    ln -sfn ../whitelist.json /var/lib/pumpkin/data/whitelist.json
  '';

  # TEMPORARY: debug logging while the client-side "joined then immediately
  # left" (network error) issue is root-caused. Remove once fixed.
  systemd.services.pumpkin.environment.RUST_LOG = "debug";

  # The module defaults to DynamicUser, which changes the service UID per
  # start and leaves root-owned imported files unwritable. Pin a static
  # system user instead so /var/lib/pumpkin/world ownership is stable.
  systemd.services.pumpkin.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "pumpkin";
    Group = "pumpkin";
  };
  users.users.pumpkin = {
    isSystemUser = true;
    group = "pumpkin";
    home = "/var/lib/pumpkin";
  };
  users.groups.pumpkin = {};

  # Daily LOCAL backup of the pumpkin world as zstd-compressed tar with
  # 14-day retention. The server is briefly stopped for a consistent
  # region-file snapshot — pumpkin restarts in ~1 s, so the downtime
  # window is negligible at 03:00.
  #
  # TODO: these archives only live on rura-penthe itself (VM disk). For
  # off-host protection they should be shipped to Sebastian's Hetzner
  # storage box via borg or restic (both already in use elsewhere). Left
  # out for now deliberately: this is a small, rarely-used server.
  systemd.services.pumpkin-world-backup = {
    description = "Daily pumpkin world backup";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "pumpkin-world-backup" ''
        set -euo pipefail
        backupDir=/var/backups/pumpkin
        mkdir -p "$backupDir"
        # Stop for a consistent snapshot; restart no matter how the backup ends.
        systemctl stop pumpkin.service
        trap 'systemctl start pumpkin.service' EXIT
        stamp=$(date +%F_%H%M%S)
        ${pkgs.gnutar}/bin/tar -C /var/lib/pumpkin -cf - world \
          | ${pkgs.zstd}/bin/zstd -o "$backupDir/world-$stamp.tar.zst"
        find "$backupDir" -name 'world-*.tar.zst' -mtime +14 -delete
      '';
    };
  };

  systemd.timers.pumpkin-world-backup = {
    description = "Daily pumpkin world backup";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00";
      RandomizedDelaySec = "10m";
      Persistent = true;
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # attic on cardassia (shared Nix binary cache, cache "flexos", public pull).
  # Lets rura-penthe pull builds (e.g. pumpkin) instead of compiling on the VM.
  nix.settings.extra-substituters = [ "http://192.168.78.247:8080/flexos" ];
  nix.settings.extra-trusted-public-keys = [ "flexos:Ea0r+Ec1NpdDr1tNylfhGpPEVJ5s0QZXNvUYjbZgoGc=" ];

  system.stateVersion = "26.11"; # Did you read the comment?
}

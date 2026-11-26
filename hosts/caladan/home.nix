{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home-manager/base.nix
    ../../modules/home-manager/zsh
    ../../modules/home-manager/tex
    #../../modules/home-manager/gtk
    ../../modules/home-manager/gnome
    ../../modules/home-manager/niri
    ../../modules/home-manager/nextcloud-client.nix
    ../../modules/home-manager/omp
    ../../modules/home-manager/paseo.nix
    ../../modules/home-manager/ssh
    ../../modules/home-manager/herdr
    ../../modules/home-manager/hermes.nix
    ../../modules/home-manager/nvim
  ];

  #programs.git.enable = true;
  #
  #programs.ssh.enable = true;
  #programs.ssh.enableDefaultConfig = false;
  #programs.ssh.matchBlocks = {
  #  "*" = {
  #    forwardAgent = true;
  #    identityFile = "~/.ssh/id_ed25519";
  #    identitiesOnly = true;
  #  };
  #  "cardassia" = {
  #    hostname = "your.dyndns.host";
  #    port = 25222;
  #    user = "flex";
  #  };
  #  "cardassia" = {
  #    hostname = "192.168.x.x";
  #    user = "root";
  #    proxyJump = "cardassia";
  #  };
  #};

  # 2026-11-24: umbriel keyboard layout. umbriel falls back to the locale1
  # X11 keymap (de, set via services.xserver.xkb) only when [input.keyboard]
  # sets none of layout/variant/options/model — yet the first session came
  # up with a US layout, so set it explicitly. Also matches niri's setup
  # (config.kdl: empty xkb + numlock, de from locale1). umbriel never creates
  # or modifies this file itself; edits here are the source of truth.
  xdg.configFile."umbriel/config.toml".text = ''
    [input.keyboard]
    layout = "de"
    model = "pc105"
    numlock_toggle = true
  '';

  # 2026-11-22: luciole (noctalia's native Wayland file manager) to try
  # alongside nautilus, which stays the default handler. Purely additive —
  # launched from the menu/terminal, nothing points at it yet. If it sticks:
  # set as default file manager and enable its FileChooser portal backend.
  home.packages = [
    inputs.luciole.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}

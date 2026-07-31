{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "flex";
  home.homeDirectory = "/home/flex";

  imports = [
    #../../modules/home-manager/kitty
    ../../modules/home-manager/zsh
    #../../modules/home-manager/nvim
    #../../modules/home-manager/neofetch
    #../../modules/home-manager/tmux
    ../../modules/home-manager/tex
    #../../modules/home-manager/gtk
    ../../modules/home-manager/gnome
    ../../modules/home-manager/niri
    ../../modules/home-manager/nextcloud-client.nix
    ../../modules/home-manager/omp
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/flex/etc/profile.d/hm-session-vars.sh
  #
  #home.sessionVariables = {
  #  GTK_THEME = "Catppuccin-Macchiato-Blue-Dark";
  #  # EDITOR = "emacs";
  #};

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

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
  #  "cardassia3" = {
  #    hostname = "192.168.x.x";
  #    user = "root";
  #    proxyJump = "cardassia";
  #  };
  #  "minecraft1" = {
  #    hostname = "192.168.x.x";
  #    user = "root";
  #    proxyJump = "cardassia";
  #  };
  #  "udm-pro" = {
  #    hostname = "192.168.x.x";
  #    user = "root";
  #  };
  #  "pve1" = {
  #    hostname = "192.168.x.x";
  #    user = "root";
  #  };
  #  "pve2" = {
  #    hostname = "192.168.x.x";
  #    user = "root";
  #  };
  #  "pve3" = {
  #    hostname = "192.168.x.x";
  #    user = "root";
  #  };
  #  "pvenet1" = {
  #    hostname = "192.168.x.x";
  #    user = "root";
  #  };
  #  "mister" = {
  #    hostname = "192.168.x.x";
  #    user = "root";
  #  };
  #  "charm-os-deploy" = {
  #    hostname = "x.x.x.x";
  #    user = "cloud";
  #    dynamicForward = 1080;
  #  };
  #
  #};
}

{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/base.nix
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
    ../../modules/home-manager/ssh
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

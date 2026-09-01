{ config, pkgs, ... }:

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
    ../../modules/home-manager/ssh
    ../../modules/home-manager/herdr
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
  #  "cardassia3" = {
  #    hostname = "192.168.x.x";
  #    user = "root";
  #    proxyJump = "cardassia";
  #  };
  #};
}

{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/base.nix
    ../../modules/home-manager/zsh
    ../../modules/home-manager/tex
    #../../modules/home-manager/gtk
    #../../modules/home-manager/gnome
    #../../modules/home-manager/niri
    #../../modules/home-manager/nextcloud-client.nix
    ../../modules/home-manager/omp
    ../../modules/home-manager/ssh
    ../../modules/home-manager/herdr
    ../../modules/home-manager/nvim
  ];
}

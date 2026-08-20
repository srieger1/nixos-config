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
    ../../modules/home-manager/ssh
  ];
}

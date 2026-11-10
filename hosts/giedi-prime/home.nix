{ config, pkgs, inputs, ... }:

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
    #../../modules/home-manager/herdr # not in nixos stable as of 26.05
    ../../modules/home-manager/nvim
    # paseo is not in nixos-26.05 yet — pull the CLI + daemon from the
    # pinned nixpkgs-unstable input (see flake.nix for the pin rationale).
    (import ../../modules/home-manager/paseo.nix {
      pkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
    })
  ];
}

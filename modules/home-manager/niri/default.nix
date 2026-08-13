# niri.nix
#
# home-manager module for the niri config, alternative to gnome on caladan.
# Validates config.kdl at build time, per https://wiki.nixos.org/wiki/Niri

{ pkgs, ... }:
{
  xdg.configFile."niri/config.kdl".source =
    pkgs.runCommand "niri-config-checked"
      {
        nativeBuildInputs = [ pkgs.niri ];
      }
      ''
        niri validate --config ${./config.kdl}
        cp ${./config.kdl} $out
      '';
}

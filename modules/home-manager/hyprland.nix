# hyprland.nix

{ pkgs, lib, config, ... }: {
  options = {
    hyprlandLayout = lib.mkOption {
      default = "master";
      description = ''
        hyprland window layout
      '';
    };
  };
}

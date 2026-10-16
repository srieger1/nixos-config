# niri.nix
#
# home-manager module for the niri config, alternative to gnome on caladan.
# Validates config.kdl at build time, per https://wiki.nixos.org/wiki/Niri

 { pkgs, ... }:
 let
   # Super+P display cycle (extend -> external-only -> panel-only). No mirror:
   # niri 26.04 supports neither `msg output ... mirror` nor a config mirror
   # node (verified live 15.10.2026). Bound as Super+P in config.kdl.
   display-cycle = pkgs.writeShellScriptBin "display-cycle" (builtins.readFile ./display-cycle.sh);
 in
 {
   home.packages = [ display-cycle ];

  xdg.configFile."niri/config.kdl".source =
    pkgs.runCommand "niri-config-checked"
      {
        nativeBuildInputs = [ pkgs.niri ];
      }
      ''
        niri validate --config ${./config.kdl}
        cp ${./config.kdl} $out
      '';

  # noctalia (v5, native) as a systemd user service instead of niri's
  # spawn-at-startup: survives crashes (Restart=on-failure) and gets
  # restarted on nixos-rebuild switch, so the running shell and the
  # `noctalia msg ...` IPC client always come from the same build.
  systemd.user.services.noctalia = {
    Unit = {
      Description = "Noctalia desktop shell";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.noctalia}/bin/noctalia";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}

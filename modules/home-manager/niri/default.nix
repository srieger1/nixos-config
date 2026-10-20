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
  # Super+P mirror state runs wl-mirror fullscreen on the external output.
 in
 {
   home.packages = [ display-cycle pkgs.wl-mirror ];

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

  # niri-zoom daemon (Ctrl+Scroll-Lupe): idelt bei ~0% CPU und wartet auf
  # niri-zoomctl-Kommandos (Binds in config.kdl). systemd statt
  # spawn-at-startup, damit Crashes neu starten und der Daemon die
  # Session-Umgebung (WAYLAND_DISPLAY) erbt. Binary liegt experimentell in
  # ~/.local/bin (aus ~/src/niri-zoom gebaut), nicht im nix Store.
  systemd.user.services.niri-zoomd = {
    Unit = {
      Description = "niri-zoom zooming daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "%h/.local/bin/niri-zoomd";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}

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

  # noctalia-shell as a systemd user service instead of niri's
  # spawn-at-startup: survives crashes (Restart=on-failure) and gets
  # restarted on nixos-rebuild switch, avoiding the stale-store-path
  # mismatch where the running quickshell keeps the old hash while the
  # IPC client (keyed on shell.qml path) can no longer find it.
  systemd.user.services.noctalia-shell = {
    Unit = {
      Description = "Noctalia shell (quickshell)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.noctalia-shell}/bin/noctalia-shell";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}

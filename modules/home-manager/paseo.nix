# paseo.nix
#
# Paseo daemon (agent control surface) as a systemd --user service, plus the
# paseo CLI. Clients (desktop app, iOS, web, CLI) connect to this daemon and
# drive the coding agent CLIs on this machine (omp, claude-code, pi, …).
#
# Connectivity: the daemon listens on 0.0.0.0:6767 — a RUNTIME setting paseo
# owns in ~/.paseo/config.json (`daemon.listen`, default 127.0.0.1; set it to
# 0.0.0.0:6767 once after first boot and restart the service). Expose 6767
# only over the tailnet: either a firewall rule on tailscale0 or — where the
# firewall already trusts tailscale0 (caladan) — nothing extra. Direct
# connections need no pairing/password, auth is the tailnet membership
# itself (https://paseo.sh/docs/connectivity → Tailscale).
{ pkgs, ... }:
{
  home.packages = [ pkgs.paseo ];

  systemd.user.services.paseo-daemon = {
    Unit = {
      Description = "Paseo daemon (coding agent control surface)";
      After = [ "network-online.target" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.paseo}/bin/paseo daemon run";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}

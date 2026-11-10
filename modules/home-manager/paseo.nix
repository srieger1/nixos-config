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
let
  # NOTE: paseoPkg must NOT be a module-argument default (`paseoPkg ?
  # pkgs.paseo` in the signature) — module-arg defaults referencing pkgs
  # force config evaluation and recurse. Hosts on stable nixpkgs (26.05)
  # don't ship paseo — they import this module via a direct call passing
  # `pkgs = inputs.nixpkgs-unstable.legacyPackages.…` (giedi-prime; the
  # unstable input is pinned for the hermes/patchelf issue, see flake.nix).
  paseoPkg = pkgs.paseo;
in
{
  home.packages = [ paseoPkg ];

  systemd.user.services.paseo-daemon = {
    Unit = {
      Description = "Paseo daemon (coding agent control surface)";
      After = [ "network-online.target" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${paseoPkg}/bin/paseo daemon run";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}

# attic (https://github.com/zhaofengli/attic) — self-hosted Nix binary cache.
#
# Hosts the shared build outputs of OpenLogi, containerlab and pumpkin:
# caladan builds and pushes (it runs unstable), giedi-prime and rura-penthe
# pull via substituter instead of recompiling. Plain HTTP on the LAN — for
# plain-IP substituters no TLS is needed, the signing key in the clients'
# nix config is what makes the paths verifiable.
#
# One-off bootstrap after the first deploy (attic-client is on caladan):
#
#   # 1. deploy on cardassia itself (git pull && nixos-rebuild switch --flake .#cardassia):
#   #    NOT via --target-host from caladan — that copies the closure without
#   #    cardassia's sops secrets (cf. the static-IP outage).
#   # 2. admin token (run on cardassia; atticd-atticadm is installed by the module):
#   #      atticd-atticadm make-token --sub flex --validity 1y \
#   #        --pull '*' --push '*' --delete '*' --create-cache '*' --configure-cache '*'
#   # 3. on caladan: attic login cardassia http://192.168.78.247:8080 <token>
#   #    attic cache create flexos --public
#   #    attic cache info flexos   # -> Public Key, unten in common.nix/rura-penthe eintragen
#   # 4. push: attic push flexos /run/current-system
#
{ config, ... }:

{
  services.atticd = {
    enable = true;

    # RS256 JWT signing secret (ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=...).
    # EnvironmentFile is read by systemd as root, so the default 0400
    # root-owned sops secret works despite atticd's DynamicUser.
    environmentFile = config.sops.secrets.attic_rs256_secret.path;

    # Module defaults are fine for LAN use: sqlite at /var/lib/atticd/server.db,
    # local storage at /var/lib/atticd/storage, listen [::]:8080. allowed-hosts/
    # api-endpoint are only needed behind a reverse proxy with a real hostname.
  };
}

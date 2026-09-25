# attic (https://github.com/zhaofengli/attic) — self-hosted Nix binary cache.
#
# Hosts the shared build outputs of OpenLogi, containerlab and pumpkin:
# caladan builds and pushes (it runs unstable), giedi-prime and rura-penthe
# pull via substituter instead of recompiling. Plain HTTP on the LAN — for
# plain-IP substituters no TLS is needed, the signing key in the clients'
# nix config is what makes the paths verifiable.
#
# Postgres instead of the sqlite default: under concurrent uploads sqlite's
# single-writer + sea-orm pool caused "Connection pool timed out" 500s and a
# spinning atticd (65% CPU, 4G memory peak); Postgres is attic's documented
# production backend and runs here anyway (Nextcloud).
#
# One-off bootstrap (attic-client is on caladan):
#
#   # 2. admin token (run on cardassia; atticd-atticadm is installed by the module):
#   #      atticd-atticadm make-token --sub flex --validity 1y \
#   #        --pull '*' --push '*' --delete '*' --create-cache '*' --configure-cache '*'
#   # 3. on caladan: attic login cardassia http://192.168.78.247:8080 <token>
#   #    attic cache create flexos --public
#   #    attic cache info flexos   # -> Public Key, in common.nix/rura-penthe aktiviert
#   # 4. push: attic push flexos /run/current-system
#
{ config, ... }:

{
  # Static user: atticd's NixOS module hardcodes DynamicUser=yes, but with an
  # existing User= systemd uses the static user instead — required for postgres
  # peer auth over the unix socket (role atticd ↔ OS user atticd).
  users.users.atticd = {
    isSystemUser = true;
    group = "atticd";
  };
  users.groups.atticd = { };

  services.postgresql = {
    ensureDatabases = [ "atticd" ];
    ensureUsers = [
      {
        name = "atticd";
        ensureDBOwnership = true;
      }
    ];
  };

  services.atticd = {
    enable = true;
    user = "atticd";
    group = "atticd";

    # RS256 JWT signing secret (ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=...).
    # EnvironmentFile is read by systemd as root, so the default 0400
    # root-owned sops secret works.
    environmentFile = config.sops.secrets.attic_rs256_secret.path;

    settings = {
      database.url = "postgresql:///atticd?host=/run/postgresql";

      # Module default; explicit here so the ReadWritePaths story is visible.
      storage = {
        type = "local";
        path = "/var/lib/atticd/storage";
      };
    };

    # Module defaults are fine for LAN use: listen [::]:8080. allowed-hosts/
    # api-endpoint are only needed behind a reverse proxy with a real hostname.
  };
}

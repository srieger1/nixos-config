# Forgejo (Gitea fork) — git hosting on git.sx21.de.
#
# DB: postgres via the module's createDatabase provisioning (ensures db+user),
# peer auth over the unix socket — no password, matching the atticd pattern.
# Git over HTTPS only; forgejo's built-in SSH server stays off (port 22
# belongs to sshd). Registration disabled; first user = admin via CLI:
#   forgejo admin user create --admin --username flex --email ... --random-password
{ config, lib, pkgs, private, ... }:

{
  services.forgejo = {
    enable = true;
    database = {
      type = "postgres";
      createDatabase = true;
    };
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = private.forgejoHostname;
        ROOT_URL = "https://${private.forgejoHostname}/";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 3000;
      };
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
    };
  };

  services.nginx.virtualHosts."${private.forgejoHostname}" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    # 24744: router forwards this port to cardassia directly — ionos reverse
    # proxy reaches the new VM here while the 443 forward still points at
    # cardassia-old (until the nextcloud migration).
    listen = [
      {port = 443; addr = "0.0.0.0"; ssl = true;}
      {port = 24744; addr = "0.0.0.0"; ssl = true;}
      {port = 443; addr = "[::]"; ssl = true;}
      {port = 24744; addr = "[::]"; ssl = true;}
    ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        client_max_body_size 16G;
      '';
    };
  };
}

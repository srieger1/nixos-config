# HedgeDoc (ex-CodiMD/HackMD) — collaborative markdown editor on md.sx21.de.
#
# DB: postgres via peer auth over the unix socket (role hedgedoc ↔ OS user
# hedgedoc, which the module creates). The module does NOT provision the
# database itself — ensureDatabases/ensureUsers here, same as attic.nix.
# nginx vHost is defined manually instead of configureNginx=true, because
# that option uses the full URL as vHost name and skips ACME/DNS-challenge.
{ config, lib, pkgs, private, ... }:

{
  services.postgresql = {
    ensureDatabases = [ "hedgedoc" ];
    ensureUsers = [
      {
        name = "hedgedoc";
        ensureDBOwnership = true;
      }
    ];
  };

  services.hedgedoc = {
    enable = true;
    settings = {
      domain = "https://${private.hedgedocHostname}";
      host = "127.0.0.1";
      port = 3001;
      protocolUseSSL = true;
      db = {
        dialect = "postgresql";
        username = "hedgedoc";
        database = "hedgedoc";
        host = "/run/postgresql";
      };
    };
  };

  services.nginx.virtualHosts."${private.hedgedocHostname}" = {
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
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
      '';
    };
  };
}

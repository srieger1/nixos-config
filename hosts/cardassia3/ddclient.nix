{ self, config, lib, pkgs, ... }: {
  services.ddclient = {
    enable = true;
    configFile = "/run/secrets/ddclient.conf";
  };

  systemd.services.ddclient.path = [pkgs.iproute2];
}

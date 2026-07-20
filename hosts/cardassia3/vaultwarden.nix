{ self, config, lib, pkgs, ... }: {
  services.vaultwarden = {
    enable = true;
    backupDir = "/var/backup/vaultwarden";
    config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
    };
  };
}

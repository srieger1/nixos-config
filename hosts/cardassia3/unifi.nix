{ self, config, lib, pkgs, ... }: {
  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb; 
  };
}

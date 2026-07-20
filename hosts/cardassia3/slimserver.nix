{ self, config, lib, pkgs, ... }: {
  services.slimserver = {
    enable = true;
  };
}

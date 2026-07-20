{ inputs, pkgs, ... }: {
  home.packages = [
    pkgs.nextcloud-client
  ];
  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
  systemd.user.services.nextcloud-client = {
    Unit = {
      After = pkgs.lib.mkForce "graphical-session.target"; 
    };
    # repair mixed kde/gnome qt setup and tray icon not showing up due to qt.style in configuration.nix
    #Service = {
    #  Environment = [ "QT_STYLE_OVERRIDE=" ];
    #};
  };
}

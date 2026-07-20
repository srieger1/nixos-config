{ config, pkgs, ... }:

{ 
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
    #  #name = "Orchis-Grey-Dark";
    #  #package = pkgs.orchis-theme;
    #  #package = pkgs.gnome-themes-extra;
    };
    
    #iconTheme = {
    #  package = pkgs.adwaita-icon-theme;
    #  name = "Adwaita";
    #};
    
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme=1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme=1;
    };
  };
    
  #programs = {
  #  kitty = {
  #    enable = true;
  #    font = {
  #      name = "JetBrainsMono Nerd Font";
  #      size = 17;
  #    };
  #
  #    settings = {
  #      confirm_os_window_close = -0;
  #    };
  #
  #    theme = "Catppuccin-Frappe";
  #    };
  #  };

  #xdg.configFile = {
  #  "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
  #  "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
  #  "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  #};

  # home.nix
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; lib.mkForce [
      xdg-desktop-portal-gtk # Fallback for both
      #xdg-desktop-portal-hyprland # For Hyprland
      xdg-desktop-portal-gnome # For GNOME
      #kdePackages.xdg-desktop-portal-kde
    ];
    #config.common.default = [ "hyprland" "kde" ];
    config.common.default = [ "gnome" ];
  };
}

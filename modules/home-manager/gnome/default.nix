 { inputs, pkgs, ... }: {
  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false; # Optionally disable user extensions entirely
        enabled-extensions = with pkgs.gnomeExtensions; [
            gsconnect.extensionUuid
            blur-my-shell.extensionUuid
            vitals.extensionUuid
            appindicator.extensionUuid
            wiggle.extensionUuid
            tiling-shell.extensionUuid
            #tiling-assistant.extensionUuid
            just-perfection.extensionUuid
            #thinkpad-battery-threshold.extensionUuid
            #thinkpad-thermal.extensionUuid
            tailscale-status.extensionUuid
            #system-monitor-2.extensionUuid
            #arc-menu.extensionUuid
        ];
      };

      # Configure extensions
      "org/gnome/shell/extensions/blur-my-shell" = {
        brightness = 0.75;
        noise-amount = 0;
      };

      "org/gnome/shell/extensions/vitals" = {
        show-cpu = true;
        show-memory = true;
        show-network = true;
        show-disk = true;
        show-temperatures = true;
      };

      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };

      "org/gnome/desktop/interface" = {
          accent-color = "blue";
      };

    };
  };
}
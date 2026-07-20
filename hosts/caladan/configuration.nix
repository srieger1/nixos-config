# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/nixos/test.nix
      ../../modules/nixos/thunderbolt.nix
      #../../modules/nixos/cosmic.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  # frequent freezes with 6.15 and 6.16
  boot.kernelPackages = pkgs.linuxPackages_latest; # https://search.nixos.org/packages?channel=25.11&query=linuxKernel.kernels.linux_6_18
  #boot.kernelPackages = pkgs.linuxPackages_testing; # needed as MST deep daisy chaining was not working in 6.18 (https://gitlab.freedesktop.org/drm/amd/-/issues/4756)
  #  https://search.nixos.org/packages?channel=25.11&query=linuxKernel.kernels.linux_testing
  #boot.kernelPackages = pkgs.linuxPackages_6_17;
  #boot.kernelPackages = pkgs.linuxPackages_6_12;
  #boot.kernelPackages = pkgs.linuxPackages_6_11;

  # amdgpu kernel params here: https://docs.kernel.org/gpu/amdgpu/module-parameters.html
  # amdgpu.dcdemugmask not necessary anymore? not need in kernel >=6.6
  #boot.kernelParams = [ "amdgpu.dcdebugmask=0x10" "amd_pstate=guided" "amdgpu.dc=1" ]; # amdgpu.dcdebugmask seems to fix 780M glitches, disables panel self refresh 
  boot.kernelParams = [
    #"ttm.pages_limit=524288" # 2GB * 1024 * 1024 * 1024 / 4096 page
    # 16GB * 1024 * 1024 * 1024 / 4096 page
    #"ttm.page_pool_size=4194304" # 16GB * 1024 * 1024 * 1024 / 4096 page
    "amdgpu.dcdebugmask=0x10" # seems to fix system freeze on >=6.15? (e.g., ctrl+tab switch in gnome?) amdgpu.dcdebugmask seems to fix 780M glitches, disables panel self refresh
    "zswap.enabled=1" # enables zswap
    "zswap.compressor=lz4" # compression algorithm
    "zswap.max_pool_percent=20" # maximum percentage of RAM that zswap is allowed to use
    "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
    "resume_offset=187985920" # hibernate support, see https://nixos.wiki/wiki/Hibernation
  ];
  # amdgpu.dc to support standby when using external monitor see: https://forums.linuxmint.com/viewtopic.php?t=404544 and 
  #boot.kernelParams = [ "amdgpu.dc=0" "amd_pstate=guided" ];
  # not needed?
  #boot.kernelParams = [ "amd_pstate=guided" ];
  # fix external monitor >=6.18?
  #boot.kernelParams = [ "amdgpu.dcdebugmask=0x10" "amdgpu.dc=1" ];
  #boot.kernelParams = [
  #  "video=DP-10:2560x1440@60"
  #  "video=DP-12:2560x1440@60"
  #];

  powerManagement.enable = true;
  #powerManagement.cpuFreqGovernor = "schedutil";

  boot.supportedFilesystems = [ "ntfs" ];
  boot.initrd.kernelModules = [ "lz4" "amdgpu" ];
  boot.initrd.systemd.enable = true;
  # Prevent systemd from waiting for network online 
  # (Optional but recommended for faster boot with VPNs)
  systemd.network.wait-online.enable = false; 
  boot.initrd.systemd.network.wait-online.enable = false;

  # hibernate support
  boot.resumeDevice = "/dev/disk/by-uuid/e6e6071d-2737-4f98-ac4f-7bddfc4e8a2d";

  #environment.systemPackages = [ pkgs.lan-mouse_git ];
  #boot.kernelPackages = pkgs.linuxPackages_cachyos; # chaotic
  #services.scx.enable = true; # by default uses scx_rustland scheduler

  networking.hostName = "caladan"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  systemd.services.ath11k-suspend = {
    enable = true;
    description = "Suspend: rmmod ath11k_pci";
    unitConfig = {
      Before = [ "sleep.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/usr/bin/rmmod ath11k_pci";
    };
    wantedBy = [ "sleep.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
  };

  systemd.services.ath11k-resume = {
    enable = true;
    description = "Resume: modprobe ath11k_pci";
    unitConfig = {
      After = [ "suspend.target" "suspend-then-hibernate.target" "hibernate.target" "hybrid-sleep.target" ];
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/usr/bin/modprobe ath11k_pci";
    };
    wantedBy = [ "suspend.target" "suspend-then-hibernate.target" "hibernate.target" "hybrid-sleep.target" ];
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  #networking.hostFiles = [ "/etc/hosts.clab" ];
  #networking.networkmanager.plugins = [
  #  pkgs.networkmanager-openconnect
  #  pkgs.networkmanager-openvpn
  #];

  # Set your time zone.
  #time.timeZone = "Europe/Berlin";
  services.automatic-timezoned.enable = true;
  time.hardwareClockInLocalTime = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  #services.xserver.videoDrivers = [ "nvidia" ];
  # displaylink and/or modesetting currently breaks suspend
  #services.xserver.videoDrivers = [ "amdgpu" "displaylink" "modesetting" ];
  #services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "modesetting" ]; # recommended default over amdgpu for AMD GPUs on NixOS
  # nix-prefetch-url --name displaylink-580.zip https://www.synaptics.com/sites/default/files/exe_files/2023-08/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu5.8-EXE.zip
  # nix-prefetch-url --name displaylink-600.zip https://www.synaptics.com/sites/default/files/exe_files/2024-05/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.0-EXE.zip
  # https://nixos.wiki/wiki/Displaylink


  # Enable the X11 windowing system.
  services.xserver.enable = true;

  #services.xserver.displayManager.sessionCommands = ''
  #  ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
  #'';

  # Enable the Desktop Environments
  #services.displayManager.sddm.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  #services.xserver.desktopManager.xfce.enable = true;
  #services.desktopManager.plasma6.enable = true;
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];


  # Configure keymap in X11
  services.xserver = {
    #xkb.layout = "eu";
    xkb.layout= "de";
    #xkb.variant = "no-dead-keys";
    xkb.variant = "";
    xkb.options = "";
    xkb.model = "pc105";
  };

  # xfce
  #services.xserver = {
  #  desktopManager = {
  #    xterm.enable = false;
  #    xfce.enable = true;
  #  };
  #  #displayManager.defaultSession = "xfce";
  #};

  # Configure console keymap
  console.keyMap = "de-latin1-nodeadkeys";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # https://nixos.wiki/wiki/Printing
  services.printing.drivers = [ pkgs.hplip ];

  # Enable sound with pipewire.
  #sound.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  #services.gnome.gnome-keyring.enable = true;
  #security.pam.services = {
  #  gdm.enableGnomeKeyring = true;
  #  #login.enableGnomeKeyring = true;
  #}
  #services.gnome.gnome-remote-desktop.enable = true;

  # breaks e.g. nextcloud tray icon:
  #qt = {
  #  enable = true;
  #  platformTheme = "gnome";
  #  style = "adwaita"; # don't use adwaita-dark, will set a whole bunch of QT env vars and break e.g. nextcloud-client tray icon
  #};

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # create group dependencies
  users.groups.frrvty = {};
  users.groups.clab_admins = {};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.flex = {
    isNormalUser = true;
    description = "flex";
    extraGroups = [ "networkmanager" "dialout" "wheel" "libvirtd" "docker" "clab_admins" ];
    shell = pkgs.zsh;
    #shell = pkgs.fish;
    packages = with pkgs; [

      # desktop
      #gnome-themes-extra
      #orchis-theme
      gnome-clocks
      #gnomeExtensions.wintile-windows-10-window-tiling-for-gnome
      gnomeExtensions.gsconnect
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      gnomeExtensions.tiling-assistant
      gnomeExtensions.vitals
      gnomeExtensions.tiling-shell
      gnomeExtensions.thinkpad-thermal
      gnomeExtensions.thinkpad-battery-threshold
      gnomeExtensions.tailscale-status
      gnomeExtensions.system-monitor-2
      #gnomeExtensions.wiggle
      #gnomeExtensions.appindicator
      gnome-tweaks
      adwaita-icon-theme
      kora-icon-theme
      #catppuccin-cursors.mochaBlue
      #catppuccin
      brightnessctl
      bazaar
      #easyeffects # flatpak now

      # virtualization
      #virtualbox # defined by virtualization. below
      #virt-manager # enabled by virtualization. ... below

      # browsers
      firefox
      #librewolf # insecure no maintainer in nix - 6/2026 
      chromium

      # mail
      thunderbird

      # sync & share
      # move to home-manager?
      #nextcloud-client

      # music
      spotify
      #pear-desktop # previously youtube-music # not really used currently

      # password manager
      #bitwarden-desktop

      # dev
      vscode # further extensions to be defined declaratively? cline, ...?
      #(vscode-with-extensions.override {
      #  vscodeExtensions = with vscode-extensions; [
      #    bbenoist.nix
      #    ms-python.python
      #    ms-azuretools.vscode-docker
      #    ms-vscode-remote.remote-ssh
      #  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      #    {
      #      name = "remote-ssh-edit";
      #      publisher = "ms-vscode-remote";
      #      version = "0.47.2";
      #      sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
      #    }
      #  ];
      #})

      #jetbrains.rust-rover 
      #jetbrains-toolbox 
      #jetbrains.goland # disabled, use vscode for now seems to be enough
      #jetbrains.pycharm # disabled, use vscode for now seems to be enough
      gh
      #nodejs_20 # using devenv now
      #fnm # node version manager - using devenv now
      gnumake
      gcc # disable and use devenv?
      git
      #python3 # using devenv now
      #go # using devenv now
      rustup # disable and use devenv?
      rustc
      cargo
      devenv
      jdk # jameica

      # ops / cloud
      openstackclient
      terraform
      kubectl
      kubernetes-helm
      awscli2
      k9s

      # editors
      #zed-editor # currently not used
      #helix # currently not used
      #vimPlugins.LazyVim # not really used
      #neovim

      # crypto
      openssl

      # msg
      halloy # remove? weechat?
      element-desktop
      rocketchat-desktop
      threema-desktop
      signal-desktop
      discord
      #slack
      #webex # does not work anyway currently? using browser-based webex for now

      # ai
      opencode
      claude-code
      claude-monitor
      lmstudio
      ollama-rocm

      # conf
      #teams-for-linux
      zoom-us

      # productivity
      kuro
      #super-productivity # flatpak now

      # cli
      fastfetch # remove?
      jq
      yq-go
      fzf
      nh
      eza
      fd
      ripgrep
      bat
      ncdu

      # games
      #steam # enabled by programs.steam below
      #lutris
      #protonup-qt
      #parsec-bin # breaks update 2026-06-29

      # vpn
      tailscale
      wireguard-tools
      eduvpn-client

      # office
      #libreoffice-fresh # now flathub
      #onlyoffice-desktopeditors
      pympress

      # sys tools / hw
      lshw
      lm_sensors
      powertop
      btop

      # emu / retro
      fsuae
      #fsuae-launcher@master # currently build in unstable breaks with python "distutils" not found, 2024-08-05
      fsuae-launcher
      #vice # currently breaks build # flatpak now

      # network
      containerlab
      #gns3-gui@2.2.42 # lock gns3-gui to a specific version
      mininet
      #openvswitch
      gnmic
      wireshark
      tshark
      iperf3
      ethtool
      iw
      liboping # noping
      inetutils
      curl
      wget
      socat
      dig

      # terminal
      ghostty
      #kitty # remove?
      tmux
      tmux-xpanes
      #zellij
      #starship # enabled as program below
      #alacritty
      #wezterm

      # pdf
      kdePackages.okular
      #masterpdfeditor4
      #masterpdfeditor

      # notes
      xournalpp
      obsidian

      # gfx
      gimp
      inkscape
      pinta

      # tex
      texstudio
      #texliveFull # big package - optimize -> DONE separate flake now

      # remote desktop
      anydesk # breaks update 2026-06-29
      remmina

      # video
      obs-studio
      obs-studio-plugins.obs-backgroundremoval
      vlc
      yt-dlp

      # 3d printing
      #prusa-slicer

      # packer
      unzip
      unrar

      # sec
      sops
    ];
  };

  users.users.root.extraGroups = [ "frrvty" ];

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users = {
      "flex" = import ./home.nix;
    };
  };

  #nix.optimise.automatic = true;
  #
  #nix.gc = {
  #  automatic = true;
  #  dates = "weekly";
  #  options = "--delete-older-than 14d";
  #};

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "06:00"; # Daily at 6 AM
      extraArgs = "--optimise --keep-since 14d --keep 10";
    };
    flake = "/home/flex/flexos"; # sets NH_OS_FLAKE variable for you
  };

  fonts.packages = with pkgs; [
    corefonts
    noto-fonts
    #noto-fonts-cjk renamed to:
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    proggyfonts
    vista-fonts
    #nerdfonts # big package - optimze
    #(nerdfonts.override { fonts = [ "FiraCode" "Iosevka" "IosevkaTerm" "NerdFontsSymbolsOnly" ]; })
    nerd-fonts.fira-code
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    nerd-fonts.symbols-only
    google-fonts # nunito for hs-fulda
    liberation_ttf # dfg
    fira-code # dfg
  ];

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # e.g., to allow cachix for devenv: https://devenv.cachix.org	
  # risky/lazy: nix.settings.trusted-users = [ "root" "flex" ];
  nix.settings.trusted-users = [ "root" "flex" ];
  # better:
  nix.extraOptions = ''
    extra-substituters = https://devenv.cachix.org https://nixpkgs-python.cachix.org 
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU=
  '';

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # for xfce: really necessary?
  #nixpkgs.config.pulseaudio = true;
  nixpkgs.config.rocmSupport = true;

  # vscode, signal, kuro, ... :(
  #nixpkgs.config.permittedInsecurePackages = [
  #  #"electron-22.3.27"
  #  #"electron-25.9.0"
  #  "electron-29.4.6"
  #];

  # not needed?
  #hardware.amdgpu.initrd.enable = true; #redundant?
  #hardware.amdgpu.opencl.enable = true; # brings back rocm and this currently does not compile in v6.0.2

  #nixpkgs.config.packageOverrides =
  #  pkgs: {
  #    vaapiIntel = pkgs.vaapiIntel.override {
  #    enableHybridCodec = true;
  #  };
  #};
  # OpenGL
  #hardware.opengl = {
  #  enable = true;
  #  driSupport = true;
  #  driSupport32Bit = true;
  #  extraPackages = with pkgs; [
  #    intel-media-driver
  #    vaapiIntel
  #    vaapiVdpau
  #    libvdpau-va-gl
  #  ];
  #};

  #hardware.nvidia = {
  #  # Modesetting is required.
  #  modesetting.enable = true;
  #  # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
  #  powerManagement.enable = false;
  #  # Fine-grained power management. Turns off GPU when not in use.
  #  # Experimental and only works on modern Nvidia GPUs (Turing or newer).
  #  powerManagement.finegrained = false;
  #  # Use the NVidia open source kernel module (not to be confused with the
  #  # independent third-party "nouveau" open source driver).
  #  # Support is limited to the Turing and later architectures. Full list of
  #  # supported GPUs is at:
  #  # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
  #  # Only available from driver 515.43.04+
  #  # Currently alpha-quality/buggy, so false is currently the recommended setting.
  #  open = false;
  #  # Enable the Nvidia settings menu,
  #	# accessible via `nvidia-settings`.
  #  nvidiaSettings = true;
  #  # Optionally, you may need to select the appropriate driver version for your specific GPU.
  #  package = config.boot.kernelPackages.nvidiaPackages.stable;
  #  prime = {
  #    offload = {
  #		enable = true;
  #		enableOffloadCmd = true;
  #	  };
  #    # Make sure to use the correct Bus ID values for your system!
  #    intelBusId = "PCI:0:2:0";
  #    nvidiaBusId = "PCI:1:0:0";
  #  };
  #};

  #hardware.opengl.extraPackages = with pkgs; [
  #  rocmPackages.clr.icd
  #];

  #not needed anymore:
  #hardware.opengl.driSupport = true; # This is already enabled by default
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true; # For 32 bit applications

  hardware.graphics.extraPackages = with pkgs; [
    #rocmPackages.clr.icd
  ];

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # hosts file allow write for containerlab
  environment.etc.hosts.enable = false;

  # to build ff a lot of /bin/bash was given in like every file
  services.envfs.enable = true;

  # Declarative flatpak package management via nix-flatpak (github:gmodena/nix-flatpak).
  # uninstallUnmanaged is intentionally NOT set: this list is additive only for now
  # (missing packages get installed, but nothing installed outside this list gets removed).
  services.flatpak = {
    enable = true;
    remotes = [
      { name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; }
      {
        name = "threema-desktop";
        location = "https://releases.threema.ch/flatpak/threema-desktop/";
        gpg-import = "${./flatpak-keys/threema-desktop.gpg}";
      }
    ];
    packages = [
      "org.libreoffice.LibreOffice"
      { appId = "ch.threema.threema-desktop"; origin = "threema-desktop"; }
      "com.bitwarden.desktop"
      "com.blitterstudio.amiberry"
      "com.github.IsmaelMartinez.teams_for_linux"
      "com.github.wwmm.easyeffects"
      "com.protonvpn.www"
      "com.super_productivity.SuperProductivity"
      "com.usebottles.bottles"
      "de.willuhn.Jameica"
      "me.dumke.Reinschrift"
      "net.sf.VICE"
      "net.trowell.typesetter"
      "org.freedesktop.Bustle"
    ];
    update.onActivation = true;
  };
  
  # not needed anymore?, for vscode:
  #environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb"; # ensure wayland for qt apps, removed warning "Ignoring XDG_SESSION_TYPE=wayland on Gnome. Use QT_QPA_PLATFORM=wayland to run on Wayland anyway."
  };

  # Set the default editor to vim
  environment.variables.EDITOR = "vim";

  # otherwise:
  # (texstudio:838694): GLib-GIO-ERROR **: 18:46:30.864: Settings schema 'org.gtk.Settings.FileChooser' is not installed zsh: abort (core dumped) texstudio nixos
  # in texstudio
  environment.extraInit = ''
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    vim
    htop    
    nautilus-python
    libimobiledevice # iphone
    ifuse # iphone - optional to mount using ifuse
    reaction # ip46tables
    pciutils
    psmisc # killall, ...
    clinfo
    #kdePackages.xwaylandvideobridge # needed for x11 programs using video in wayland
    #spice-gtk # needed for usb pass through in virt-manager
    usbutils # lsusb etc.
    #libfido2
    dnsmasq
    ebtables
    bridge-utils
    #networkmanager-openconnect
    #lan-mouse_git # chaotic # dead
    lan-mouse
    #gnomeExtensions.appindicator
    # not needed anymore?
    #libappindicator-gtk2
    #libappindicator-gtk3
    #kdePackages.breeze-gtk
  ];

  # conflicts with services.power-profiles-daemon.enable = true;
  #services.tlp = {
  #  enable = true;
  #  settings = {
  #    TLP_DEFAULT_MODE = "BAT";
  #    TLP_PERSISTENT_DEFAULT = 1;
  #  };
  #};
  #services.power-profiles-daemon.enable = false; 
  #services.power-profiles-daemon.enable = true; 

  #powerManagement.powertop.enable = true;

  # iPhone devices
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  #programs.mtr.enable = true;
  #programs.gnupg.agent = {
  #  enable = true;
  #  enableSSHSupport = true;
  #};

  programs = {
    fuse.userAllowOther = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
      # when trying kde:
      # pinentryPackage = pkgs.pinentry-qt;
    };
  };

  # containerlab 
  #security.wrappers.containerlab = {
  #  source = "${pkgs.containerlab}/bin/containerlab";
  #  capabilities = "cap_net_admin,cap_net_raw,cap_sys_admin+eip";
  #  owner = "root";
  #  group = "root";
  #};

  # In sudoers via NixOS:
  security.sudo.extraRules = [{
    users = [ "flex" ];
    commands = [
      {
        command = "${pkgs.util-linux}/bin/nsenter";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${pkgs.docker}/bin/docker";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${pkgs.containerlab}/bin/containerlab";
        options = [ "NOPASSWD" ];
      }
      {
        command = "/etc/profiles/per-user/flex/bin/containerlab";
        options = [ "NOPASSWD" ];
      }
      {
        command = "/run/current-system/sw/bin/containerlab";
        options = [ "NOPASSWD" ];
      }
      {
        command = "/home/flex/containerlab/run-clab-sudo.sh";
        options = [ "NOPASSWD" ];
      }
    ];
  }];

  programs.zsh.enable = true;
  #programs.fish.enable = true; not used currently
  programs.starship = {
    enable = true;
    settings = {
      aws = {
        disabled = true;
      };
    };
  };

  programs.direnv.enable = true;

  virtualisation.libvirtd.enable = true;
  virtualisation.vswitch.enable = true;
  programs.virt-manager.enable = true;

  # disabled: using virt-manager and kvm by default
  #virtualisation.virtualbox.host.enable = true;
  #causes recompilation:
  #virtualisation.virtualbox.host.enableExtensionPack = true;
  #users.extraGroups.vboxusers.members = [ "flex" ];

  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "flex" ];

  virtualisation.spiceUSBRedirection.enable = true;

  # Steam Configuration
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  #programs.hyprland = {
  #  enable = true;
  #  #package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  #  xwayland.enable = true;
  #};

  programs.dconf.enable = true;
  programs.seahorse.enable = true;

  # needed when kde and gnome are enabled:
  #programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";

  # List services that you want to enable:

  services.fwupd.enable = true;

  services.tailscale.enable = true;
  #services.tailscale.useRoutingFeatures = "client";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.fprintd.enable = true;
  #services.fprintd.tod.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  #networking.firewall = {
  # # if packets are still dropped, they will show up in dmesg
  #logReversePathDrops = true;
  # # wireguard trips rpfilter up
  # extraCommands = ''
  #   ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
  #   ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
  # '';
  # extraStopCommands = ''
  #   ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
  #   ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
  # '';
  #};
  #networking.firewall.checkReversePath = false;
  #networking.firewall.checkReversePath = "loose";

  networking.firewall = {
    enable = true;
    # Always allow traffic from your Tailscale network
    trustedInterfaces = [
      "virbr0" # allow VM NAT / Internet access
      config.services.tailscale.interfaceName # trust tailscale dev
    ];
    allowedUDPPorts = [
      51820 # wireguard Clients and peers can use the same port, see listenport
      config.services.tailscale.port # Allow the Tailscale UDP port through the firewall
    ]; 
    #allowedTCPPorts = [ 3389 ]; # gnome remote desktop
    checkReversePath = "loose"; # allow wireguard VPN host as default gw, allow exit nodes and subnet routers in tailscale
  };

  # temporary rules: nixos-firewall-tool, e.g.:
  #   sudo nixos-firewall-tool open tcp 4001

  #networking.firewall = {
  # # if packets are still dropped, they will show up in dmesg
  # logReversePathDrops = true;
  # # wireguard trips rpfilter up
  # extraCommands = ''
  #   ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 47334 -j RETURN
  #   ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
  #   ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 47334 -j RETURN
  #   ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
  # '';
  # extraStopCommands = ''
  #   ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 47334 -j RETURN || true
  #   ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
  #   ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 47334 -j RETURN || true
  #   ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
  # '';
  #}

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}

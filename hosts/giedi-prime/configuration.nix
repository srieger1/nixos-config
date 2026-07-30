# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  # disable?
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" ];
  # boot.initrd.kernelModules = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "lz4" ];
  boot.initrd.systemd.enable = true;

  #boot.kernelPackages = pkgs.linuxPackages_cachyos; # chaotic
  #services.scx.enable = true; # by default uses scx_rustland scheduler
  #boot.kernelPackages = pkgs.linuxPackages_cachyos; # chaotic
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  #boot.kernelPackages = pkgs.linuxPackages_6_11;

  boot.kernelParams = [
    "zswap.enabled=1" # enables zswap
    "zswap.compressor=lz4" # compression algorithm
    "zswap.max_pool_percent=10" # maximum percentage of RAM that zswap is allowed to use
    "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
  ];

  networking.hostName = "giedi-prime"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "de-latin1-nodeadkeys";

  services.flatpak.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  security.sudo.extraRules = [{
    users = [ "flex" ];
    commands = [
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

  # Define group dependencies
  users.groups.frrvty = {};
  users.groups.clab_admins = {};
  users.users.root.extraGroups = [ "frrvty" ];

  # otherwise:
  # (texstudio:838694): GLib-GIO-ERROR **: 18:46:30.864: Settings schema 'org.gtk.Settings.FileChooser' is not installed zsh: abort (core dumped) texstudio nixos
  # in texstudio
  environment.extraInit = ''
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.flex = {
    isNormalUser = true;
    description = "flex";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "clab_admins" "docker" ];
    shell = pkgs.zsh;
    #shell = pkgs.fish;
    packages = with pkgs; [
    #  thunderbird
      firefox
      thunderbird
      nextcloud-client
      #bitwarden-desktop # insecure electron, flatpak now
      vscode # further extensions to be defined declaratively? cline, ...?
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          bbenoist.nix
          ms-python.python
          ms-azuretools.vscode-docker
          ms-vscode-remote.remote-ssh
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "remote-ssh-edit";
            publisher = "ms-vscode-remote";
            version = "0.47.2";
            sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
          }
        ];
      })
      rocketchat-desktop
      openssl
      element-desktop
      fastfetch # remove?
      kuro
      #super-productivity # flathub now
      jq
      git
      python3
      terraform
      obsidian
      signal-desktop
      neovim
      inetutils
      vlc
      unzip
      unrar
      btop
      curl
      wget
      socat
      brightnessctl
      gnumake
      #tailscale
      wireguard-tools
      libreoffice-fresh
      #onlyoffice-desktopeditors
      lshw
      teams-for-linux
      obs-studio
      obs-studio-plugins.obs-backgroundremoval
      iperf3
      wireshark
      tshark
      liboping # noping
      gnomeExtensions.tiling-assistant
      gnomeExtensions.vitals
      #gnomeExtensions.wiggle # not working with gnome 49, fixed in pr 27
      gnome-tweaks # needed?
      #vimPlugins.LazyVim
      yq-go
      kubectl
      kubernetes-helm
      gh
      awscli2
      zoom-us
      tmux
      chromium
      containerlab
      lm_sensors
      fzf
      dig
      pympress
      openstackclient
      tmux-xpanes
      powertop
      gnmic
      ghostty
      go
      mininet
      openvswitch
      kdePackages.okular
      threema-desktop # flathub now
      gcc
      #starshipshell # replaced by programs.starship
      rustup
      cargo
      devenv
      xournalpp
      eduvpn-client
      discord
      nh
      solaar
      lan-mouse
      bazaar
      claude-code
      claude-monitor
      opencode
      texstudio
    ];
  };

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users = {
      "flex" = import ./home.nix;
    };
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
  ];  

  programs.direnv.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings.download-buffer-size = 524288000;

  nix.settings.trusted-users = [ "root" "flex" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
     vim
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;programs
  #   enableSSHSupport = true;
  # };

  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.starship = {
    enable = true;
    settings = {
      aws = {
        disabled = true;
      };
    };
  };  

  # List services that you want to enable:
  services.tailscale = {
    # Enable tailscale at startup
    enable = true;

    # If you would like to use a preauthorized key, set
    # authKeyFile = "/run/secrets/tailscale_key";
    # Note: maximum expire time is 90 days
  };

  # printing kyocera
  services.printing = {
    enable = true;
    drivers = [
      pkgs.cups-kyodialog
    ];
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "flex" ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  }; 
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  virtualisation.vswitch.enable = true;
  virtualisation.vswitch.resetOnStart = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall.checkReversePath = "loose";

  networking.firewall = {
    allowedUDPPorts = [ 51820 ]; # Clients and peers can use the same port, see listenport
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}

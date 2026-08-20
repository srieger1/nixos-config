# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/nixos/common.nix
      ../../modules/nixos/desktop-common.nix
      ../../modules/nixos/packages-common.nix
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

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

  # Configure keymap in X11 (layout set in modules/nixos/desktop-common.nix)
  services.xserver.xkb.variant = "nodeadkeys";

  services.flatpak.enable = true;

  #services.printing = {
  #  enable = true;
  #  drivers = [
  #    pkgs.cups-kyodialog # kyocera
  #  ];
  #};

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.flex.packages = with pkgs; [
      #  thunderbird
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
      #super-productivity # flathub now
      python3
      signal-desktop
      neovim
      #tailscale
      libreoffice-fresh
      #onlyoffice-desktopeditors
      teams-for-linux
      #gnomeExtensions.wiggle # not working with gnome 49, fixed in pr 27
      #vimPlugins.LazyVim
      go
      openvswitch
      #starshipshell # replaced by programs.starship
      solaar
      lan-mouse
  ];

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users = {
      "flex" = import ./home.nix;
    };
  };

  # Install firefox.
  programs.firefox.enable = true;

  nix.settings.download-buffer-size = 524288000;

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

  programs.fish.enable = true;

  # tailscale/openssh enable live in modules/nixos/desktop-common.nix
  # If you would like to use a preauthorized key, set
  # authKeyFile = "/run/secrets/tailscale_key";
  # Note: maximum expire time is 90 days

  virtualisation.libvirtd.qemu = {
    package = pkgs.qemu_kvm;
    runAsRoot = true;
    swtpm.enable = true;
  };
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  virtualisation.vswitch.resetOnStart = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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

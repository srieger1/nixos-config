# Settings shared by every desktop host (caladan, giedi-prime). Not imported
# by cardassia3 (headless server, stable channel, different user/services
# entirely) — see modules/nixos/desktop-common.nix for the desktop-only half
# of this split.
{ pkgs, ... }:
{
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

  console.keyMap = "de-latin1-nodeadkeys";

  users.groups.frrvty = {};
  users.groups.clab_admins = {};
  users.users.root.extraGroups = [ "frrvty" ];

  users.users.flex = {
    isNormalUser = true;
    description = "flex";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" "clab_admins" ];
  };

  programs.containerlab.enable = true;

  # containerlab needs elevated netns/capabilities; NOPASSWD sudo avoids a
  # password prompt on every lab deploy, across every path containerlab's
  # binary might resolve to (nix profile symlink vs. system profile vs. PATH).
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

  # otherwise:
  # (texstudio:838694): GLib-GIO-ERROR **: 18:46:30.864: Settings schema 'org.gtk.Settings.FileChooser' is not installed zsh: abort (core dumped) texstudio nixos
  # in texstudio
  environment.extraInit = ''
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
  '';

  programs.zsh.enable = true;
  programs.starship = {
    enable = true;
    settings.aws.disabled = true;
  };
  programs.direnv.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "flex" ];
  # binary cache for llm-agents-nix's source-typed packages (claude-code, dsh):
  # avoids compiling their bun/JS dependency graph from scratch.
  nix.settings.extra-substituters = [ "https://cache.numtide.com" ];
  nix.settings.extra-trusted-public-keys = [
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];

  nixpkgs.config.allowUnfree = true;

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
}

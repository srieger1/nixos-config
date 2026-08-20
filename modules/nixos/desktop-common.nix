# Desktop-specific half of the caladan/giedi-prime shared config (GNOME,
# audio, virtualisation, networking). See modules/nixos/common.nix for the
# non-desktop-specific half. Not imported by cardassia3.
{ ... }:
{
  services.xserver.enable = true;
  services.xserver.xkb.layout = "de";

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.vswitch.enable = true;
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "flex" ];

  networking.networkmanager.enable = true;

  services.tailscale.enable = true;
  services.openssh.enable = true;

  # allow wireguard VPN host as default gw, allow exit nodes and subnet
  # routers in tailscale
  networking.firewall.checkReversePath = "loose";
}

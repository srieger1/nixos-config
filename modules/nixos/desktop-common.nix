# Desktop-specific half of the caladan/giedi-prime shared config (GNOME,
# audio, virtualisation, networking). See modules/nixos/common.nix for the
# non-desktop-specific half. Not imported by cardassia.
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
  #programs.librepods.enable = true; # currently disabled don't need to tune airpods and don't use them so much, also needs to run desktop app with constant window
  programs.solaar.enable = true;

  virtualisation.libvirtd.enable = true;
  virtualisation.vswitch.enable = true;
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "flex" ];

  networking.networkmanager.enable = true;
  # NM pushes per-connection DNS + search domains into resolved (scoped to the
  # link): physical link keeps DHCP DNS as default, tailscale registers
  # 100.100.100.100 only for the tailnet domains, eduVPN/OpenVPN search
  # domains land scoped on the tun link instead of clobbering
  # /etc/resolv.conf (pattern verified on cardassia, 2026-09-26).
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  services.tailscale.enable = true;
  services.openssh.enable = true;

  # allow wireguard VPN host as default gw, allow exit nodes and subnet
  # routers in tailscale
  networking.firewall.checkReversePath = "loose";
}

# Shared home-manager base for caladan and giedi-prime (both single-user
# "flex" hosts on the same state version). Host home.nix files add only
# their own `imports`.
{
  home.username = "flex";
  home.homeDirectory = "/home/flex";
  home.stateVersion = "23.11"; # Please read home-manager's release notes before changing.

  programs.home-manager.enable = true;
}

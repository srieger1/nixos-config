{ inputs, pkgs, lib, config, ... }:
 
{
  users.users.flex = {
    packages = with pkgs; [
      #dstat # remove as deprecated use dools
      dool
    ];
  };
}

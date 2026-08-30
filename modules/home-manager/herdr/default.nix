# herdr — agent multiplexer runtime (client/server, like tmux for agent panes).
# Runs on demand inside ghostty: `herdr` starts/attaches the background server,
# `herdr server stop` shuts it down. Not a terminal emulator; nothing autostarts.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    herdr
  ];
}

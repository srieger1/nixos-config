# User packages shared by caladan and giedi-prime. Host configuration.nix
# files add their own extras via a separate `users.users.flex.packages`
# definition — NixOS concatenates list-typed options defined across modules,
# so this list and each host's additions merge automatically.
{ pkgs, inputs, ... }:
{
  users.users.flex.packages = with pkgs; [
    awscli2
    bazaar
    brightnessctl
    btop
    cargo
    chromium
    claude-monitor
    containerlab
    curl
    devenv
    dig
    discord
    dool # dstat replacement
    eduvpn-client
    element-desktop
    fastfetch
    firefox
    fzf
    gcc
    gh
    ghostty
    git
    gnmic
    gnome-tweaks
    gnomeExtensions.tiling-assistant
    gnomeExtensions.vitals
    gnumake
    inetutils
    iperf3
    jq
    kdePackages.okular
    kubectl
    kubernetes-helm
    kuro
    liboping # noping
    lm_sensors
    lshw
    mininet
    nh
    obs-studio
    obs-studio-plugins.obs-backgroundremoval
    obsidian
    opencode
    openssl
    openstackclient
    powertop
    pympress
    rocketchat-desktop
    rustup
    socat
    terraform
    texstudio
    thunderbird
    tmux
    tmux-xpanes
    tshark
    unrar
    unzip
    vlc
    wget
    wireguard-tools
    wireshark
    xournalpp
    yq-go
    zoom-us

    inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
    inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system}.dsh # deepseek-ai agent harness
  ];
}

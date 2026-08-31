# ./overlays/default.nix
{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    # Overlay 1: Use `self` and `super` to express
    # the inheritance relationship
    #(self: super: {
    #  google-chrome = super.google-chrome.override {
    #    commandLineArgs =
    #      "--proxy-server='https=127.0.0.1:3128;http=127.0.0.1:3128'";
    #  };
    #})
 
    #(final: prev: {
    #  containerlab = prev.containerlab.overrideAttrs (finalAttrs: previousAttrs: { 
    ##    version = "0.61.0";
    ##    src = prev.fetchFromGitHub {
    ##      owner = "srl-labs";
    ##      repo = "containerlab";
    ##      rev = "v0.61.0";
    ##      hash = "sha256-VEN2JjgLukE8YQ2nq+qFS2Yq0TdiTyRm2RUm32mJzBM=";
    ##    };
    ##    vendorHash = "sha256-PwPih5LuXPBznSvn4L4h8zCiuWP2+u90PdN5+2Il6j0=";
    #    version = "0.64.0";
    #    src = prev.fetchFromGitHub {
    #      inherit (previousAttrs.src) owner repo;
    #      rev = "v${finalAttrs.version}";
    #      hash = "sha256-ijqylVQKt7N3rc+HVc34XfU3LMXAtn+mhVWIzZZIikw=";
    #    };
    ## to get vendorHash:
    ##    vendorHash = lib.fakeHash;
    #    vendorHash = "sha256-9p4J9qkIQCubn3W4b3qNHfq1M2kMiqG0eGFaBxGdrAk=";
    #    ldflags = [
    #      "-s"
    #      "-w"
    #      "-X github.com/srl-labs/containerlab/cmd.version=${finalAttrs.version}"
    #      "-X github.com/srl-labs/containerlab/cmd.commit=${finalAttrs.src.rev}"
    #      "-X github.com/srl-labs/containerlab/cmd.date=1970-01-01T00:00:00Z"
    #    ];
    #    postInstall = ''
    #      ln -sf "$out/bin/containerlab" "$out/bin/clab"
    #    '';
    #    meta = {
    #      inherit (previousAttrs.meta) description homepage license platforms maintainers mainProgram;
    #      changelog = "https://github.com/srl-labs/containerlab/releases/tag/${finalAttrs.src.rev}";
    #    };
    #  });
    #})

    # Overlay 2: Use `final` and `prev` to express
    # the relationship between the new and the old
    #(final: prev: {
    #  steam = prev.steam.override {
    #    extraPkgs = pkgs: with pkgs; [
    #      keyutils
    #      libkrb5
    #      libpng
    #      libpulseaudio
    #      libvorbis
    #      stdenv.cc.cc.lib
    #      xorg.libXcursor
    #      xorg.libXi
    #      xorg.libXinerama
    #      xorg.libXScrnSaver
    #    ];
    #    extraProfile = "export GDK_SCALE=2";
    #  };
    #})

    # Overlay 3: Define overlays in other files
    # The content of ./overlays/overlay3/default.nix is the same as above:
    # `(final: prev: { xxx = prev.xxx.override { ... }; })`
    #(import ./overlay3)

    # not needed anymore:
    #(import ./xdg-fix)

    #(import ./containerlab)
    #(import ./ms-python)
    #(import ./pympress)
    #(import ./ghostty)
    #(import ./wireplumber)
  ];
}

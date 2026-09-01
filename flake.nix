{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager's `master` branch is the one meant to track
    # nixpkgs-unstable (release-XX.YY branches pair with the matching
    # stable nixos-XX.YY). Used only for caladan, which runs unstable.
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";

    # No `inputs.nixpkgs.follows` here: the numtide binary cache is only
    # populated for llm-agents.nix's own pinned nixpkgs. Following our
    # nixpkgs would change every package's derivation hash and force
    # source builds (verified: differing drvPath with vs. without follows).
    llm-agents-nix.url = "github:numtide/llm-agents.nix";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # No `inputs.nixpkgs.follows` here (same rationale as llm-agents-nix above):
    # openlogi is a Rust/GPUI app with no public binary cache, so every nixpkgs
    # bump on our side was forcing a ~13min from-source rebuild via the shared
    # input. Letting it pin its own nixpkgs decouples rebuilds from our routine
    # `update.sh` runs, at the cost of a second nixpkgs closure.
    openlogi.url = "github:AprilNEA/OpenLogi";

    containerlab = {
      url = "github:srl-labs/containerlab";
      #inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    #chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; # cachyos kernel etc. # dead

    #hyprland.url = "github:hyprwm/Hyprland";

    #nixvim = {
    #  url = "github:nix-community/nixvim";
    #  #url = "github:nix-community/nixvim/nixos-24.05";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    #nixpkgs.url = "nixpkgs/nixos-unstable";

  };

  #outputs = { self, nixpkgs, chaotic, ... }@inputs: {
  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;

    # Secrets/host-specific values that must never land in the (public) git
    # repo. Flakes only see git-tracked files, so gitignoring a file in-repo
    # isn't enough — it silently falls back to the checked-in .example.
    # The real file lives at an absolute path outside the repo, keyed off
    # $HOME so it resolves correctly whichever user builds the flake (flex
    # on caladan/giedi-prime/cardassia3). Reading it needs `--impure` too,
    # since pure eval also refuses external absolute paths (already set in
    # update.sh / rebuild-switch.sh).
    privateFor = host:
      let
        path = builtins.toPath (builtins.getEnv "HOME" + "/.config/flexos-private/${host}.nix");
      in
      if builtins.pathExists path
      then import path
      else import ./hosts/${host}/private.nix.example;

    # Collects each host's boilerplate nixosSystem call into one place, so
    # the per-host differences below (which nixpkgs channel, which
    # home-manager input, which extra modules) are what's visible.
    mkHost = { hostname, nixpkgsFlake, homeManagerInput, extraSpecialArgs ? {}, extraModules ? [] }:
      nixpkgsFlake.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; } // extraSpecialArgs;
        modules = [
          ./hosts/${hostname}/configuration.nix
          homeManagerInput.nixosModules.default
        ] ++ extraModules ++ [
          (import ./overlays)
        ];
      };
  in {
    nixosConfigurations = {
      caladan = mkHost {
        hostname = "caladan";
        nixpkgsFlake = nixpkgs-unstable;
        homeManagerInput = inputs.home-manager-unstable;
        extraModules = [
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.openlogi.nixosModules.default
          inputs.containerlab.nixosModules.default
        ];
      };
      giedi-prime = mkHost {
        hostname = "giedi-prime";
        nixpkgsFlake = nixpkgs;
        homeManagerInput = inputs.home-manager;
        extraSpecialArgs = { private = privateFor "giedi-prime"; };
        extraModules = [
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.openlogi.nixosModules.default
          inputs.containerlab.nixosModules.default
        ];
      };
      cardassia3 = mkHost {
        hostname = "cardassia3";
        nixpkgsFlake = nixpkgs;
        homeManagerInput = inputs.home-manager;
        extraSpecialArgs = { private = privateFor "cardassia3"; inherit self; };
        extraModules = [
          ./hosts/cardassia3/sops.nix
          inputs.sops-nix.nixosModules.sops
        ];
      };
    };
  };
}

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

    omp-nix = {
      url = "github:yuxqiu/omp-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
    #pkgs = nixpkgs.legacyPackages.${system};
    pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
  in {
    nixosConfigurations = {
      caladan = nixpkgs-unstable.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs pkgsUnstable;};
        modules = [
          ./hosts/caladan/configuration.nix
          inputs.home-manager-unstable.nixosModules.default
          inputs.nix-flatpak.nixosModules.nix-flatpak
          #./modules/nixos/kitty/default.nix
          #./hosts
          (import ./overlays)
          #chaotic.nixosModules.default
        ];
      };
      giedi-prime =
        let
          private =
            #if builtins.pathExists ./hosts/giedi-prime/private.nix
            #then import ./hosts/giedi-prime/private.nix
            #else import ./hosts/giedi-prime/private.nix.example;
            import ./hosts/giedi-prime/private.nix;
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {inherit inputs pkgsUnstable private;};
          #inputs.nixpkgs.follows = "nixpkgs-unstable";
          #inputs.home-manager.nixpkgs.follows = "nixpkgs-stable";
          modules = [
            ./hosts/giedi-prime/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.nix-flatpak.nixosModules.nix-flatpak
            #./modules/nixos/kitty/default.nix
            #./hosts
            (import ./overlays)
            #chaotic.nixosModules.default
          ];
        };
      cardassia3 =
        let
          private =
            if builtins.pathExists ./hosts/cardassia3/private.nix
            then import ./hosts/cardassia3/private.nix
            else import ./hosts/cardassia3/private.nix.example;
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {inherit inputs pkgsUnstable self private;};
          modules = [
            ./hosts/cardassia3/configuration.nix
            ./hosts/cardassia3/sops.nix
            inputs.home-manager.nixosModules.default
            inputs.sops-nix.nixosModules.sops
            (import ./overlays)
          ];
        };
    };
  };
}

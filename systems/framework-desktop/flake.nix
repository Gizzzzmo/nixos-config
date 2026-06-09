{
  description = "Framework Desktop NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    handy = {
      url = "github:cjpais/Handy/v0.8.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, nixpkgs, home-manager, nixvim, rose-pine-hyprcursor, handy, ...}: let
    inputs = {
      inherit nixpkgs home-manager nixvim rose-pine-hyprcursor handy;
    };
  in {
    nixosConfigurations.framework-desktop = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        my-system = import ../framework-desktop.nix;
      };

      modules = [
        ../../configuration.nix
        home-manager.nixosModules.default
        handy.nixosModules.default
      ];
    };
  };
}
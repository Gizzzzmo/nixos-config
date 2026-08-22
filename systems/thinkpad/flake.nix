{
  description = "Thinkpad NixOS config";

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
    matui = {
      url = "github:pkulak/matui/86dccde832a590c5220ea93ec0e4a7df752fef46";
      input.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    rose-pine-hyprcursor,
    matui,
    ...
  }: let
    inputs = {
      inherit nixpkgs home-manager nixvim rose-pine-hyprcursor matui;
    };
  in {
    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };

      modules = [
        ../thinkpad.nix
        home-manager.nixosModules.default
      ];
    };
  };
}

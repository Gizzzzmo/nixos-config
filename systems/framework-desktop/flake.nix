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
    rocmfpx = {
      # PIN: ROCmFPX build we validated (Vulkan+MTP on qwen3.6-35B)
      url = "github:charlie12345/ROCmFPX/c49ebdbd5c9f01ec242369f9e7f7967855f80cba";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    matui = {
      url = "github:pkulak/matui/86dccde832a590c5220ea93ec0e4a7df752fef46";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes = {
      url = "github:NousResearch/hermes-agent/v2026.8.19";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    rose-pine-hyprcursor,
    rocmfpx,
    matui,
    hermes,
    ...
  }: let
    inputs = {
      inherit nixpkgs home-manager nixvim rose-pine-hyprcursor rocmfpx matui hermes;
    };
  in {
    nixosConfigurations.framework-desktop = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };

      modules = [
        ../framework-desktop.nix
        home-manager.nixosModules.default
      ];
    };
  };
}

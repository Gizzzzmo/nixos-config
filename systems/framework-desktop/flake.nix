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
      url = "github:charlie12345/ROCmFPX/0a59add89b8cba06fb6a0baf25a253a4e45faa78";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    rose-pine-hyprcursor,
    rocmfpx,
    ...
  }: let
    inputs = {
      inherit nixpkgs home-manager nixvim rose-pine-hyprcursor rocmfpx ;
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
      ];
    };
  };
}

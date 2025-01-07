# sudo nixos-rebuild switch --flake /etc/nixos#default

{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    hyprland = {
      url = "github:hyprwm/hyprland/v0.46.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    flox = {
      url = "github:flox/flox/v1.3.8";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

  };

  outputs = { self, nixpkgs, ... }@inputs:{
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      
      modules = [
        ./configuration.nix
        inputs.home-manager.nixosModules.default
      ];
      
      extraSpecialArgs = {
        inherit inputs;
        standalone = true;
      };
    };
  };
}

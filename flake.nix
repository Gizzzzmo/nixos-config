# sudo nixos-rebuild switch --flake /path/to/this/file#<profile>
# home-manager switch --flake /path/to/this/file#<user>
{
  description = "Nixos and home manager config flake";

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
    muxxies = {
      url = "github:Gizzzzmo/muxxies/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nixvim-stable = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    muxxies-stable = {
      url = "github:Gizzzzmo/muxxies/main";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    home-manager-stable,
    nixvim-stable,
    muxxies-stable,
    ...
  } @ inputs: {
    homeConfigurations.jonas = let
      system = "x86_64-linux";
      pkgs = nixpkgs-stable.legacyPackages.${system};
    in
      home-manager-stable.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [./jonas-home.nix];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
          inputs = {
            nixpkgs = nixpkgs-stable;
            home-manager = home-manager-stable;
            nixvim = nixvim-stable;
            muxxies = muxxies-stable;
          };
          standalone = true;
          username = "jonas";
        };
      };

    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        my-system = ./systems/thinkpad.nix;
      };

      modules = [
        ./configuration.nix
        home-manager.nixosModules.default
      ];
    };

    nixosConfigurations.framework-desktop = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        my-system = ./systems/framework-desktop.nix;
      };

      modules = [
        ./configuration.nix
        home-manager.nixosModules.default
      ];
    };
  };
}

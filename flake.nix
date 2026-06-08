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
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    handy = {
      url = "github:cjpais/Handy/v0.8.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nixvim-stable = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    rose-pine-hyprcursor-stable = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    handy-stable = {
      url = "github:cjpais/Handy/v0.8.3";
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
    rose-pine-hyprcursor-stable,
    handy,
    handy-stable,
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
          };
          standalone = true;
          username = "jonas";
        };
      };

    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        my-system = import ./systems/thinkpad.nix;
      };

      modules = [
        ./configuration.nix
        home-manager.nixosModules.default
        handy.nixosModules.default
      ];
    };

    nixosConfigurations.framework-desktop = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        # inputs = {
        #   nixpkgs = nixpkgs-stable;
        #   home-manager = home-manager-stable;
        #   nixvim = nixvim-stable;
        #   rose-pine-hyprcursor = rose-pine-hyprcursor-stable;
        #   handy = handy-stable;
        # };
        my-system = import ./systems/framework-desktop.nix;
      };

      modules = [
        ./configuration.nix
        home-manager.nixosModules.default
        handy.nixosModules.default
      ];
    };

    nixosConfigurations.noether = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inputs = {
          nixpkgs = nixpkgs-stable;
          home-manager = home-manager-stable;
          nixvim = nixvim-stable;
        };
        my-system = import ./systems/noether.nix;
      };

      modules = [
        ./configuration.nix
        home-manager.nixosModules.default
      ];
    };
  };
}

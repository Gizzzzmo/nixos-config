# sudo nixos-rebuild switch --flake /path/to/this/file#<profile>
{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

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
    muxxies = {
      url = "github:Gizzzzmo/muxxies/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    nixosConfigurations = {
      thinkpad = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          my-system = {
            id = "thinkpad";
            hardware-config = ./systems/thinkpad/hardware-configuration.nix;
          };
        };

        modules = [
          ./configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      framework-desktop = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          my-system = {
            id = "framework-desktop";
            hostName = "hilbert";
            hardware-config = ./systems/framework-desktop/hardware-configuration.nix;
            enableSshServer = true;
          };
        };

        modules = [
          ./configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}

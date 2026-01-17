# sudo nixos-rebuild switch --flake /path/to/this/file#<profile>
# home-manager switch --flake /path/to/this/file#<user>
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
    home-manager,
    ...
  } @ inputs: {
    homeConfigurations = let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      jonas = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [../jonas-home.nix];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
          inherit inputs;
          standalone = true;
        };
      };
    };

    nixosConfigurations = {
      thinkpad = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          my-system = {
            id = "thinkpad";
            hardwareConfig = ./systems/thinkpad/hardware-configuration.nix;
            enableBluetooth = true;
            # enableIwd = true;
            enableUserMounts = true;
            enablePrinting = true;
            enableSteam = true;
            enableSound = true;
            enableGui = true;
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
            hardwareConfig = ./systems/framework-desktop/hardware-configuration.nix;
            enableSshServer = true;
            enableVirtualization = true;
            enableBluetooth = true;
            enableIwd = false;
            luks = "/dev/nvme0n1p2";
            enableUserMounts = true;
            enablePrinting = true;
            enableSteam = true;
            enableSound = true;
            enableGui = true;
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

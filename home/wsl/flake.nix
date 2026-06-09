{
  description = "Jonas siemens wsl home-manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations.jonas = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [../../jonas-home.nix];

      extraSpecialArgs = {
        inputs = {
          inherit nixpkgs home-manager nixvim;
        };
        standalone = true;
        wsl = true;
        extraPkgs = pkgs:
          with pkgs; [
            cmake
            neocmakelsp
            basedpyright
            just
            zathura
            eog
          ];
        username = "jonas";
      };
    };
  };
}

{
  # add a description
  description = "<description>";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        my-name = "envmux";
        # list dependencies
        my-buildInputs = with pkgs; [];
        # enter the script's filename
        my-script = (pkgs.writeScriptBin my-name (builtins.readFile ./script-file.sh)).overrideAttrs (old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      in rec {
        defaultPackage = packages.envmux;
        packages.envmux = pkgs.symlinkJoin {
          name = my-name;
          paths = [my-script] ++ my-buildInputs;
          buildInputs = [pkgs.makeWrapper];
          postBuild = "wrapProgram $out/bin/${my-name} --prefix PATH : $out/bin";
        };
      }
    );
}

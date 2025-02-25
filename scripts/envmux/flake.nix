{
  description = "Starts a new tmux session in the current directory, with the name of the current directory and with all current environment variables pulled into the tmux environment";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        my-name = "envmux";
        my-buildInputs = with pkgs; [ coreutils ];
        my-script = (pkgs.writeScriptBin my-name (builtins.readFile ./envmux.sh)).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      in rec {
        defaultPackage = packages.envmux;
        packages.envmux = pkgs.symlinkJoin {
          name = my-name;
          paths = [ my-script ] ++ my-buildInputs;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${my-name} --prefix PATH : $out/bin";
        };
      }
    );   
}

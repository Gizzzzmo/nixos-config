{
  description = "Starts a new tmux session in the current directory, with the name of the current directory and with all current environment variables pulled into the tmux environment";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        my-buildInputs = with pkgs; [ coreutils perl ];
        envmux-name = "envmux";
        envmux-script = (pkgs.writeScriptBin envmux-name (builtins.readFile ./envmux.sh)).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
        sourcemux-name = "sourcemux";
        sourcemux-script = (pkgs.writeScriptBin sourcemux-name (builtins.readFile ./sourcemux.sh)).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
        multimux-name = "multimux";
        multimux-script = (pkgs.writeScriptBin multimux-name (builtins.readFile ./multimux.sh)).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      in rec {
        defaultPackage = packages.envmux;
        packages.envmux = pkgs.symlinkJoin {
          name = "tmux-utils";
          paths = [ envmux-script sourcemux-script multimux-script ] ++ my-buildInputs;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/${envmux-name} --prefix PATH : $out/bin
            wrapProgram $out/bin/${sourcemux-name} --prefix PATH : $out/bin
            wrapProgram $out/bin/${multimux-name} --prefix PATH : $out/bin
          '';
        };
      }
    );   
}

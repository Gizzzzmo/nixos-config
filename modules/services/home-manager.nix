{
  lib,
  config,
  inputs,
  ...
}: {
  options.hm.profile = lib.mkOption {
    type = lib.types.nullOr lib.types.path;
    default = null;
    description = "Home-manager profile (home/profiles/<name>.nix) to use for this system.";
  };

  config.home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    users.jonas = lib.mkIf (config.hm.profile != null) (import config.hm.profile);
  };
}

{
  lib,
  config,
  pkgs,
  ...
}: {
  options.services.docker = {
    rocmRuntime = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Register a ROCm runtime for docker.";
    };
  };

  config = {
    virtualisation.docker = {
      enable = true;
      enableNvidia = false;
      extraOptions = lib.mkIf config.services.docker.rocmRuntime ''
        --add-runtime=rocm=${pkgs.rocmPackages.clr}/bin/rocm-runtime
      '';
    };

    main-user.extraGroups = ["docker"];

    environment.systemPackages = [pkgs.docker-compose];
  };
}
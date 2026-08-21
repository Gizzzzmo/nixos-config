{
  lib,
  config,
  pkgs,
  ...
}: {
  # Requires services/docker.nix to be imported alongside (it declares
  # services.docker.rocmRuntime).
  services.docker.rocmRuntime = true;

  hardware.amdgpu.opencl.enable = true;

  main-user.extraGroups = ["video" "render"];

  environment.systemPackages = with pkgs.rocmPackages; [
    amdsmi
    rocm-smi
    rocminfo
  ];
}
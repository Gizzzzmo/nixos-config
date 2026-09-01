{inputs, ...}: {
  imports = [
    ../modules/core.nix
    ../modules/main-user.nix
    ../modules/services/ssh.nix
    ../modules/services/gui.nix
    ../modules/services/audio.nix
    ../modules/services/tailscale.nix
    ../modules/services/docker.nix
    ../modules/services/rocm.nix
    ../modules/services/virtualization.nix
    ../modules/services/storage-box.nix
    ../modules/services/user-mounts.nix
    ../modules/services/ollama.nix
    ../modules/services/llama.nix
    ../modules/services/home-manager.nix
    ../modules/services/steam.nix
    ../modules/services/printing.nix
    ../modules/services/bluetooth.nix
    ../modules/services/hermes.nix
    ./framework-desktop-hardware.nix
  ];

  main-user.enable = true;
  main-user.userName = "jonas";
  main-user.extraGroups = ["dialout"];

  sys = {
    hostName = "hilbert";
    bindAddress = "100.64.0.3";
    luksRoot = "/dev/nvme0n1p2";
    iommu = "amd";
    pciPassthrough = true;
    extraInitrdModules = ["amdgpu"];
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d3", MODE="0666", GROUP="dialout"
  '';

  users.groups.dialout = {};

  hm.profile = ../home/profiles/framework-desktop.nix;
}

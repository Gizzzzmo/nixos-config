{
  id = "framework-desktop";
  hostName = "hilbert";
  hardwareConfig = ./framework-desktop-hardware.nix;
  enableSshServer = true;
  enableVirtualization = true;
  enableTailscale = true;
  enableOpenclawNode = true;
  enableDocker = true;
  enableBluetooth = true;
  enableIwd = true;
  luks = "/dev/nvme0n1p2";
  enableUserMounts = true;
  enablePrinting = true;
  enableSteam = true;
  enableSound = true;
  enableGui = true;
  enableOpenclAmd = true;
  iommu = "amd";
  pciPassthrough = true;
  extraInitrdModules = ["amdgpu"];
  extraPkgs = pkgs:
    with pkgs; [
      rocmPackages.amdsmi
      rocmPackages.rocm-smi
      rocmPackages.rocminfo
    ];

  homeManagerConfig = {
    extraPkgs = pkgs:
      with pkgs; [
        lmstudio
        ardour
        kdePackages.kdenlive
      ];
  };
}

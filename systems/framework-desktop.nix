{
  id = "framework-desktop";
  hostName = "hilbert";
  hardwareConfig = import ./framework-desktop-hardware.nix;
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
  iommu = "amd";
  pciPassthrough = true;
  extraInitrdModules = ["amdgpu"];
}

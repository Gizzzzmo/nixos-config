{
  id = "framework-desktop";
  hostName = "hilbert";
  hardwareConfig = ./framework-desktop-hardware.nix;
  enableSshServer = true;
  enableVirtualization = true;
  enableTailscale = true;
  enableDocker = true;
  enableBluetooth = true;
  enableStorageBox = true;
  luks = "/dev/nvme0n1p2";
  enableUserMounts = true;
  enablePrinting = true;
  enableSteam = true;
  enableSound = true;
  enableGui = true;
  enableOpenclAmd = true;
  enableOllama = true;
  enableLlamaCpp = true;
  tailscaleIp = "100.64.0.3";
  iommu = "amd";
  pciPassthrough = true;
  extraInitrdModules = ["amdgpu"];
  extraPkgs = pkgs:
    with pkgs; [
      rocmPackages.amdsmi
      rocmPackages.rocm-smi
      rocmPackages.rocminfo
    ];
  extraGroups = ["dialout"];
  extraUdevRules = pkgs: ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d3", MODE="0666", GROUP="dialout"
  '';

  homeManagerConfig = {
    enableHandy = true;
    waybarHeight = 36;
    waybarOpacity = 0.6;
    useHyprland = true;
    enableGuiApps = true;
    enableSoundApps = true;
    enableSyncthing = true;
    extraPkgs = pkgs:
      with pkgs; [
        mmtui
        bluetui
        (darktable.override {withAi = true;})
        ollama
        lmstudio
        ardour
        kdePackages.kdenlive
      ];
  };
}

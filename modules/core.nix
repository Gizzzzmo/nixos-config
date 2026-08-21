{
  config,
  lib,
  pkgs,
  ...
}: {
  options.sys = {
    hostName = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "System hostname.";
    };
    legacyBios = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use GRUB legacy BIOS instead of systemd-boot.";
    };
    luksRoot = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "LUKS device for the root filesystem (preLVM).";
    };
    iommu = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "IOMMU vendor, e.g. \"amd\" or \"intel\".";
    };
    pciPassthrough = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable VFIO PCI passthrough kernel modules/params.";
    };
    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address that network services bind to (usually a Tailscale IP).";
    };
    tailscaleLoginServer = lib.mkOption {
      type = lib.types.str;
      default = "https://headscale.jonbyr.com";
      description = "Tailscale/Headscale coordination server URL.";
    };
    extraInitrdModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra kernel modules for the initrd.";
    };
    extraKernelParams = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra kernel command line parameters.";
    };
    autoUpgradeFlake = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Flake path to auto-upgrade from, or null to disable.";
    };
  };

  config = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnfreePredicate = pkg: true;

    # Bootloader: UEFI (systemd-boot) by default, GRUB legacy BIOS if requested.
    boot.loader.systemd-boot.enable = !config.sys.legacyBios;
    boot.loader.efi.canTouchEfiVariables = !config.sys.legacyBios;
    boot.loader.grub = lib.mkIf config.sys.legacyBios {
      enable = true;
      devices = ["/dev/sda"];
      fsIdentifier = "provided";
    };

    boot.initrd.luks.devices = lib.mkIf (config.sys.luksRoot != null) {
      root = {
        device = config.sys.luksRoot;
        preLVM = true;
      };
    };

    boot.initrd.kernelModules =
      (lib.optionals config.sys.pciPassthrough ["vfio_pci" "vfio" "vfio_iommu_type1"])
      ++ config.sys.extraInitrdModules;
    boot.kernelParams =
      lib.optionals (config.sys.iommu != null) [
        "${config.sys.iommu}_iommu=on"
      ]
      ++ lib.optionals config.sys.pciPassthrough ["iommu=pt"]
      ++ config.sys.extraKernelParams;

    networking.hostName = config.sys.hostName;

    networking.networkmanager = {
      enable = true;
      dispatcherScripts = [
        {
          source = pkgs.writeShellScript "mount-fritz-nas" ''
            export MOUNT_CIFS="${pkgs.cifs-utils}/bin/mount.cifs"
            export MOUNTPOINT_BIN="${pkgs.util-linux}/bin/mountpoint"
            export UMOUNT="${pkgs.util-linux}/bin/umount"
            export PATH="${pkgs.hyprland}/bin:$PATH"
            exec ${pkgs.bash}/bin/bash ${../scripts/mount-fritz-nas.sh} "$@"
          '';
          type = "basic";
        }
      ];
    };

    nix.settings.experimental-features = ["nix-command" "flakes"];
    nix.optimise.automatic = true;

    system.autoUpgrade = lib.mkIf (config.sys.autoUpgradeFlake != null) {
      enable = true;
      flake = toString config.sys.autoUpgradeFlake;
      flags = [
        "--update-input"
        "nixpkgs-stable"
        "--update-input"
        "home-manager-stable"
      ];
      dates = "04:00";
      allowReboot = false;
      persistent = true;
    };

    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };

    services.cron.enable = true;
    services.atd.enable = true;
    services.pcscd.enable = true;

    networking.firewall = {
      enable = true;
      checkReversePath = "loose";
    };

    hardware.keyboard.qmk = {
      enable = true;
      keychronSupport = true;
    };

    services.udev = {
      enable = true;
      packages = [pkgs.via];
    };

    programs.fish.enable = true;

    environment.systemPackages = with pkgs; [
      parted
      at
      cron
    ];

    system.stateVersion = "23.11";
  };
}
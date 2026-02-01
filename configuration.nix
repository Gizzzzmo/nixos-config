# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  inputs,
  my-system,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    my-system.hardwareConfig
    ./main-user.nix
    inputs.home-manager.nixosModules.default
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = lib.mkIf (my-system ? "luks") {
    root = {
      device = my-system.luks;
      preLVM = true;
    };
  };

  boot.initrd.kernelModules =
    lib.optionals
    ((my-system.enableVirtualization or false) && my-system ? "iommu" && (my-system.pciPassthrough or false))
    ["vfio_pci" "vfio" "vfio_iommu_type1"]
    ++ my-system.extraInitrdModules or [];

  boot.kernelParams =
    lib.optionals (my-system ? "iommu") [
      "${my-system.iommu}_iommu=on"
    ]
    ++ lib.optionals (my-system.pciPassthrough or false)
    ["iommu=pt"]
    ++ my-system.extraKernelParams or [];

  networking.hostName = my-system.hostName or "nixos";

  networking.networkmanager = {
    enable = true;
    wifi.backend = lib.mkIf (my-system.enableIwd or false) "iwd";
    dispatcherScripts = [
      {
        source = pkgs.writeShellScript "mount-fritz-nas" ''
          export MOUNT_CIFS="${pkgs.cifs-utils}/bin/mount.cifs"
          export MOUNTPOINT_BIN="${pkgs.util-linux}/bin/mountpoint"
          export UMOUNT="${pkgs.util-linux}/bin/umount"
          export PATH="${pkgs.hyprland}/bin:$PATH"
          exec ${pkgs.bash}/bin/bash ${./scripts/mount-fritz-nas.sh} "$@"
        '';
        type = "basic";
      }
    ];
  };
  networking.wireless = {
    iwd.enable = my-system.enableIwd or false;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.optimise.automatic = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    #keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  services.cron.enable = true;
  services.atd.enable = true;
  services.xserver.enable = true;
  services.pcscd.enable = true;
  services.tailscale = {
    enable = my-system.enableTailscale or false;
    authKeyFile = "/root/tailscale-auth-key";
    extraUpFlags = [
      "--login-server=https://78.47.49.217:8443"
      "--accept-routes"
    ];
  };

  # Add Headscale server certificate to system trust store
  security.pki.certificateFiles = [
    ./certificates/headscale.crt
  ];

  # Increase timeout for tailscale autoconnect service
  systemd.services.tailscaled-autoconnect.serviceConfig = {
    TimeoutStartSec = "5min";
  };

  programs.hyprland = {
    enable = my-system.enableGui or false;
    xwayland.enable = true;
    withUWSM = true;
  };
  services.displayManager.sddm = {
    enable = my-system.enableGui or false;
    wayland.enable = true;
    theme = "where_is_my_sddm_theme";
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = my-system.enablePrinting or false;

  # Enable sound.
  security.rtkit.enable = my-system.enableSound or false;
  services.pipewire = {
    enable = my-system.enableSound or false;

    # Global low-latency defaults for pro audio
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000; # Default for general use
        "default.clock.allowed-rates" = [44100 48000 88200 96000 176400 192000];
        "default.clock.quantum" = 256; # Lower latency (~5.33ms at 48kHz)
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 2048;
      };
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -15;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;
          };
          flags = ["ifexists" "nofail"];
        }
      ];
    };

    wireplumber = {
      enable = true;
      configPackages = [
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-ssl2-pro-audio.conf" ''
          # Configure SSL 2 Mk II for high sample rate support
          monitor.alsa.rules = [
            {
              matches = [
                {
                  device.name = "alsa_card.usb-Solid_State_Logic_SSL_2_Mk_II-00"
                }
              ]
              actions = {
                update-props = {
                  api.alsa.period-size = 256
                  api.alsa.headroom = 1024
                  audio.rate = 96000
                  audio.allowed-rates = [ 44100 48000 88200 96000 176400 192000 ]
                }
              }
            }
          ]
        '')
      ];
    };

    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    audio.enable = true;
    jack.enable = true;
  };

  programs.steam.enable = my-system.enableSteam or false;

  programs.virt-manager.enable = my-system.enableVirtualization or false;

  virtualisation = {
    libvirtd = {
      enable = my-system.enableVirtualization or false;
      qemu = {
        vhostUserPackages = [pkgs.virtiofsd];
        swtpm = {
          enable = true;
          package = pkgs.swtpm;
        };
      };
    };
    # tpm.enable = true;
    spiceUSBRedirection.enable = my-system.enableVirtualization or false;

    docker = {
      enable = my-system.enableDocker or false;
      enableNvidia = false; # Explicitly disable NVIDIA support
      # Enable ROCm support for AMD GPUs
      extraOptions = lib.mkIf (my-system.enableOpenclAmd or false) ''
        --add-runtime=rocm=${pkgs.rocmPackages.clr}/bin/rocm-runtime
      '';
    };
  };

  # Enable udisks2 for manual mounting of external drives without sudo
  services.udisks2.enable = my-system.enableUserMounts or false;
  # Allow user jonas to mount/unmount drives without password
  security.polkit.extraConfig =
    lib.mkIf (my-system ? "enableUserMounts")
    (builtins.readFile ./polkit-rules/mount-permissions.js);
  # Allow non-root users to use FUSE for sshfs mounting
  programs.fuse.userAllowOther = my-system.enableUserMounts or false;

  # Enable bluetooth
  hardware.bluetooth.enable = my-system.enableBluetooth or false;
  hardware.amdgpu.opencl.enable = my-system.enableOpenclAmd or false;

  services.udev = {
    enable = true;
    extraRules = lib.mkIf (my-system ? "extraUdevRules") (my-system.extraUdevRules pkgs);
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  main-user.enable = true;
  main-user.userName = "jonas";

  programs.fish.enable = true;

  users.groups = {
    backlight = {};
    libvirtd = {};
  };

  users.users.jonas = {
    extraGroups =
      [
        "audio"
        "wheel"
        "networkmanager"
        "backlight"
      ]
      ++ lib.optionals my-system.enableOpenclAmd or false ["video" "render"]
      ++ lib.optionals my-system.enableVirtualization or false ["libvirtd"]
      ++ lib.optionals my-system.enableDocker or false ["docker"]
      ++ lib.optionals my-system.enableUserMounts or false ["storage"];
  };

  home-manager = {
    extraSpecialArgs =
      {
        inherit inputs;
        username = "jonas";
        extraPkgs = pkgs: [];
      }
      // ((my-system.homeManagerConfig or {}) // {standalone = false;});
    users = {
      "jonas" = import ./jonas-home.nix;
    };
  };

  # User-level systemd service for openclaw
  systemd.user.services.openclaw-node = lib.mkIf (my-system.enableOpenclawNode or false) {
    description = "OpenClaw Node Service";
    after = ["network-online.target"];
    wants = ["network-online.target"];

    serviceConfig = {
      Type = "simple";
      ExecStart = let
        openclawPkg = inputs.openclaw.packages.${pkgs.stdenv.hostPlatform.system}.openclaw;
      in "${pkgs.writeShellScript "openclaw-wrapper" ''
        export PATH="${openclawPkg}/bin:$PATH"
        while true; do
          echo "Starting openclaw node..."
          openclaw node run --host ${my-system.openclawGateway or "100.64.0.2"} 2>&1
          EXIT_CODE=$?
          echo "openclaw exited with code $EXIT_CODE, restarting in 5 seconds..."
          sleep 5
        done
      ''}";
      Restart = "always";
      RestartSec = "10s";
    };

    wantedBy = ["default.target"];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    (lib.optionals (my-system ? "extraPkgs") (my-system.extraPkgs pkgs))
    ++ (with pkgs;
      [
        parted
        at
        cron
        waypipe
        (buildFHSEnv {
          name = "fhs";
          targetPkgs = pkgs:
            with pkgs; [
              python313
              python313Packages.pip
              coreutils
              curl
              wget
              git
              fish
              which
              file
            ];
          profile = ''export FHS=1'';
          runScript = "fish";
        })
        # Mounting tools
        cifs-utils
        sshfs
        ntfs3g
        exfat
      ]
      ++ lib.optionals my-system.enableVirtualization or false [
        swtpm
        tpm-tools
      ]
      ++ lib.optionals my-system.enableUserMounts or false [
        udisks
      ]
      ++ lib.optionals my-system.enableGui or false [
        inputs.rose-pine-hyprcursor.packages.${pkgs.hostPlatform.system}.default
        hyprpaper
      ]
      ++ lib.optionals my-system.enableSound or false [
        pamixer
        # Audio production helper script
        (pkgs.writeScriptBin "set-audio-rate" (builtins.readFile ./scripts/set-audio-rate.sh))
      ]
      ++ lib.optionals my-system.enableDocker or false [
        docker-compose
      ]);

  environment = {
    variables =
      {}
      // (
        if (my-system.enableGui or false)
        then {
          # If cursor is not visible, try to set this to "on".
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_TYPE = "wayland";
          XDG_SESSION_DESKTOP = "Hyprland";
        }
        else {}
      );
    sessionVariables =
      {}
      // (
        if (my-system.enableGui or false)
        then {
          MOZ_ENABLE_WAYLAND = "1";
          NIXOS_OZONE_WL = "1";
          T_QPA_PLATFORM = "wayland";
          GDK_BACKEND = "wayland";
          WLR_NO_HARDWARE_CURSORS = "1";
        }
        else {}
      );
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default =
        lib.mkIf (my-system.enableGui or false)
        ["gtk"];
      hyprland.default = lib.mkIf (my-system.enableGui or false) [
        "gtk"
        "hyprland"
      ];
    };
    extraPortals = lib.mkIf (my-system.enableGui or false) [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = my-system.enableSshServer or false;
  };

  # List services that you want to enable:
  services.openssh = {
    enable = my-system.enableSshServer or false;
    settings = {
      PasswordAuthentication = false;
      X11Forwarding = true;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}

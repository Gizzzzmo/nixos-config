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
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;

    pulse.enable = true;
    audio.enable = true;
    jack.enable = true;
  };

  programs.steam.enable = my-system.enableSteam or false;

  programs.virt-manager.enable = my-system.enableVirtualization or false;
  virtualisation = lib.mkIf (my-system.enableVirtualization or false) {
    libvirtd = {
      enable = true;
      qemu.swtpm = {
        enable = true;
        package = pkgs.swtpm;
      };
    };
    # tpm.enable = true;
    spiceUSBRedirection.enable = true;
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

  services.udev = {
    enable = true;
    extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/coreutils --coreutils-prog=chgrp backlight $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/coreutils --coreutils-prog=chmod g+w $sys$devpath/brightness"
    '';
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
      ++ lib.optionals my-system.enableVirtualization or false ["libvirtd"]
      ++ lib.optionals my-system.enableUserMounts or false ["storage"];
  };

  home-manager = {
    extraSpecialArgs =
      {
        inherit inputs;
        username = "jonas";
      }
      // ((my-system.homeManagerConfig or {}) // {standalone = false;});
    users = {
      "jonas" = import ./jonas-home.nix;
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      parted
      at
      cron
      waypipe
      # Mounting tools
      cifs-utils
      sshfs
      ntfs3g
      exfat
    ]
    ++ my-system.extraPkgs or []
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
    ];

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

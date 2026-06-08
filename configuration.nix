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
}: let
  dufs-merge-auth =
    pkgs.writers.writePython3Bin "dufs-merge-auth"
    {
      libraries = [pkgs.python3Packages.pyyaml];
    }
    ''
      import os
      import sys
      import tempfile

      import yaml

      CONFIG_BASE = "${./dufs-config.yaml}"
      CONFIG_AUTH = "/etc/dufs/credentials.yaml"

      with open(CONFIG_BASE) as f:
          config = yaml.safe_load(f)

      if os.path.exists(CONFIG_AUTH):
          with open(CONFIG_AUTH) as f:
              auth_data = yaml.safe_load(f)
          if isinstance(auth_data, list):
              config["auth"] = auth_data

      tmp = tempfile.NamedTemporaryFile(
          prefix="dufs-", suffix=".yaml", mode="w", delete=False
      )
      yaml.dump(config, tmp)
      tmp.close()

      dufs = "${pkgs.dufs}/bin/dufs"
      os.execvp(dufs, [dufs, "--config", tmp.name] + sys.argv[1:])
    '';
in {
  imports = [
    # Include the results of the hardware scan.
    my-system.hardwareConfig
    ./main-user.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  # Bootloader: UEFI (systemd-boot) or Legacy BIOS (GRUB)
  boot.loader.systemd-boot.enable = !(my-system.enableLegacyBios or false);
  boot.loader.grub = {
    enable = my-system.enableLegacyBios or false;
    devices = ["/dev/sda"];
    fsIdentifier = "provided";
  };
  boot.loader.efi.canTouchEfiVariables = my-system.enableLegacyBios or false;

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

  system.autoUpgrade = lib.mkIf (my-system.enableAutoUpgrade or false) {
    enable = true;
    flake = "/home/jonas/nixos-config";
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
  services.xserver.enable = my-system.enableGui or false;
  services.pcscd.enable = true;

  services.tailscale = {
    enable = my-system.enableTailscale or false;
    authKeyFile = "/root/tailscale-auth-key";
    extraUpFlags = [
      "--login-server=${my-system.tailscaleLoginServer or "https://headscale.jonbyr.com"}"
      "--accept-routes"
      "--advertise-exit-node"
    ];
    useRoutingFeatures = "client";
  };

  services.ollama = {
    enable = my-system.enableOllama or false;
    package = pkgs.ollama-vulkan;
    host = my-system.tailscaleIp or "127.0.0.1"; # Bind to Tailscale interface
  };

  services.llama-cpp = let
    qwen3CoderNextGGUF = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/Qwen3-Coder-Next-GGUF/resolve/main/Qwen3-Coder-Next-Q4_K_M.gguf";
      sha256 = "sha256-nmAy0vO1CmDxfOi/Wh2Fxxr5tTuJx5eAIK58Zg8psJA";
    };
    qwen36GGUF = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF/resolve/main/Qwen3.6-35B-A3B-UD-Q8_K_XL.gguf";
      sha256 = "sha256-t2IhXF9Qf0hl30rD0a+oA4KK+kHgXsrD+sQxpnu9iOg=";
    };
    gemma4GGUF = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/gemma-4-31B-it-GGUF/resolve/main/gemma-4-31B-it-UD-Q8_K_XL.gguf";
      sha256 = "sha256-1YYh/x/WVMdfUOQsEUXOwoTTZEfFC2Hysp88HkCZpqo=";
    };
    # miniMax27GGUF00001 = pkgs.fetchurl {
    #   url = "https://huggingface.co/unsloth/MiniMax-M2.7-GGUF/resolve/main/UD-IQ4_XS/MiniMax-M2.7-UD-IQ4_XS-00001-of-00004.gguf";
    #   sha256 = "sha256-8s7IbP+qws6XGVJo8ixj93woOQo8aZCG3g6YKMUwfP4=";
    # };
    # miniMax27GGUF00002 = pkgs.fetchurl {
    #   url = "https://huggingface.co/unsloth/MiniMax-M2.7-GGUF/resolve/main/UD-IQ4_XS/MiniMax-M2.7-UD-IQ4_XS-00002-of-00004.gguf";
    #   sha256 = "sha256-SE988ZTsTXhSezaBytRZEJzzdkRw1aAUFXBPrIODoAY=";
    # };
    # miniMax27GGUF00003 = pkgs.fetchurl {
    #   url = "https://huggingface.co/unsloth/MiniMax-M2.7-GGUF/resolve/main/UD-IQ4_XS/MiniMax-M2.7-UD-IQ4_XS-00003-of-00004.gguf";
    #   sha256 = "sha256-DYAV0DmMdCW2jGLmvqG6jGqZwuvDdrbhzCRBvJUwkZc=";
    # };
    # miniMax27GGUF00004 = pkgs.fetchurl {
    #   url = "https://huggingface.co/unsloth/MiniMax-M2.7-GGUF/resolve/main/UD-IQ4_XS/MiniMax-M2.7-UD-IQ4_XS-00004-of-00004.gguf";
    #   sha256 = "sha256-S1Z/7HCE1MnKSueJJjASXhuSXoe1bQUJ/zvI9+SZlvk=";
    # };
    # miniMax27Dir = pkgs.linkFarm "miniMax27GGUF" [
    #   {
    #     path = miniMax27GGUF00001;
    #     name = "MiniMax-M2.7-UD-IQ4_XS-00001-of-00004.gguf";
    #   }
    #   {
    #     path = miniMax27GGUF00002;
    #     name = "MiniMax-M2.7-UD-IQ4_XS-00002-of-00004.gguf";
    #   }
    #   {
    #     path = miniMax27GGUF00003;
    #     name = "MiniMax-M2.7-UD-IQ4_XS-00003-of-00004.gguf";
    #   }
    #   {
    #     path = miniMax27GGUF00004;
    #     name = "MiniMax-M2.7-UD-IQ4_XS-00004-of-00004.gguf";
    #   }
    # ];
    parallel = 2;
  in {
    enable = my-system.enableLlamaCpp or false;
    package = pkgs.llama-cpp-rocm;
    host = my-system.tailscaleIp or "127.0.0.1"; # Bind to Tailscale interface
    port = 11404;

    modelsDir = pkgs.linkFarm "llama-models" [
      {
        name = "qwen3-coder-next:q4_k_m";
        path = qwen3CoderNextGGUF;
      }
      {
        name = "qwen3.6-35b-a3b-it:q8_k_xl";
        path = qwen36GGUF;
      }
      {
        name = "gemma-4-31b-it:q8_k_xl";
        path = gemma4GGUF;
      }
    ];

    modelsPreset = {
      "qwen3-coder-next:q4_k_m" = {
        model = "${qwen3CoderNextGGUF}";
        alias = "qwen3-coder-next";
        ctx-size = 262144 * parallel;
        n-gpu-layers = "auto";
        cache-type-k = "q4_0";
        cache-type-v = "q4_0";
        fit = "on";
      };

      "qwen3.6-35b-a3b-it:q8_k_xl" = {
        model = "${qwen36GGUF}";
        alias = "qwen3.6";
        ctx-size = 262144 * parallel;
        n-gpu-layers = "auto";
        cache-type-k = "q8_0";
        cache-type-v = "q8_0";
        fit = "on";
      };

      "gemma-4-31b-it:q8_k_xl" = {
        model = "${gemma4GGUF}";
        alias = "gemma-4-31b-it";
        ctx-size = 262144 * parallel;
        n-gpu-layers = "auto";
        fit = "on";
        cache-type-k = "q8_0";
        cache-type-v = "q8_0";
        reasoning = "off";
      };

      # "minimax-m2.7-ud-iq4_xs:q4_k_m" = {
      #   model = "${miniMax27Dir}/MiniMax-M2.7-UD-IQ4_XS-00001-of-00004.gguf";
      #   alias = "minimax-m2.7-ud-iq4_xs";
      #   ctx-size = 196608 * parallel;
      #   n-gpu-layers = "auto";
      #   fit = "on";
      #   cache-type-k = "q4_0";
      #   cache-type-v = "q4_0";
      # };
    };

    # Global server flags (apply to all models)
    extraFlags = [
      "--no-mmap"
      "--models-max"
      "4" # Max models in memory simultaneously
      "--models-autoload" # Auto-load models on request (default: enabled)
      # No idle timeout by default - unload imperatively via API when needed
      "--parallel"
      (toString parallel) # Number of parallel requests to allow
      "--cont-batching" # Enable continuous batching (default: on)
    ];
  };

  # Add Headscale server certificate to system trust store
  security.pki.certificateFiles = [
    ./certificates/headscale.crt
  ];

  # Increase timeout for tailscale autoconnect service
  systemd.services.tailscaled-autoconnect.serviceConfig = lib.mkIf (my-system.enableTailscale or false) {
    TimeoutStartSec = "5min";
  };

  services.headscale = lib.mkIf (my-system.enableHeadscale or false) {
    enable = true;
    settings = {
      server_url = "https://headscale.jonbyr.com";
      noise.private_key_path = "/var/lib/headscale/noise_private.key";
      prefixes.v4 = "100.64.0.0/10";
      prefixes.v6 = "fd7a:115c:a1e0::/48";
      dns.magic_dns = true;
      dns.base_domain = "headscale.local";
      dns.override_local_dns = true;
      dns.nameservers.global = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
      database.sqlite.path = "/var/lib/headscale/db.sqlite";
      tls_cert_path = "/etc/headscale/headscale.crt";
      tls_key_path = "/etc/headscale/headscale.key";
      log.level = "info";
      ephemeral_node_inactivity_timeout = "30m";
    };
  };

  systemd.services.dufs-fileshare = lib.mkIf (my-system.enableDufs or false) {
    description = "Dufs file server for fileshare.jonbyr.com";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    restartIfChanged = false;
    serviceConfig = {
      Type = "simple";
      User = "dufs";
      Group = "dufs";
      ExecStart = "${dufs-merge-auth}/bin/dufs-merge-auth";
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      ReadWritePaths = ["/mnt/storagebox"];
      LockPersonality = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "dufs-fileshare";
    };
  };

  services.nginx = lib.mkIf (my-system.enableNginx or false) {
    enable = true;
    commonHttpConfig = ''
      limit_req_zone $binary_remote_addr zone=fileshare_limit:5m rate=10r/s;
    '';
    virtualHosts."fileshare.jonbyr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8081";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          client_max_body_size 100M;
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_connect_timeout 300;
          proxy_send_timeout 300;
          proxy_read_timeout 300;
        '';
      };
      extraConfig = ''
        limit_req zone=fileshare_limit burst=20 nodelay;
        access_log /var/log/nginx/fileshare_access.log;
        error_log /var/log/nginx/fileshare_error.log;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
      '';
    };
    virtualHosts."headscale.jonbyr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://127.0.0.1:8080";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_ssl_verify off;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_read_timeout 300s;
          proxy_connect_timeout 75s;
        '';
      };
      extraConfig = ''
        access_log /var/log/nginx/headscale_access.log;
        error_log /var/log/nginx/headscale_error.log;
      '';
    };
  };

  security.acme = lib.mkIf (my-system.enableNginx or false) {
    acceptTerms = true;
    defaults.email = "jonas@jonbyr.com";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts =
      []
      ++ (lib.optionals (my-system.enableSshServer or false) [22])
      ++ (lib.optionals (my-system.enableNginx or false) [80 443]);
    interfaces."tailscale0".allowedTCPPorts =
      (lib.optionals (my-system.enableOllama or false) [11434])
      ++ (lib.optionals (my-system.enableLlamaCpp or false) [11404]);
    checkReversePath = "loose";
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

  # Auto-mount Hetzner Storage Box via CIFS
  fileSystems."/home/jonas/mnt/storagebox" = lib.mkIf (my-system.enableStorageBox or false) {
    device = "//u610415.your-storagebox.de/backup";
    fsType = "cifs";
    options = [
      "_netdev"
      "x-systemd.requires=network-online.target"
      "credentials=/home/jonas/shared/.smbcredentials-storagebox"
      "uid=1000"
      "gid=100"
      "file_mode=0644"
      "dir_mode=0755"
      "iocharset=utf8"
      "noserverino"
    ];
  };

  # Second mount of the same share for the dufs service (writable by dufs user)
  fileSystems."/mnt/storagebox" = lib.mkIf ((my-system.enableStorageBox or false) && (my-system.enableDufs or false)) {
    device = "//u610415.your-storagebox.de/backup";
    fsType = "cifs";
    options = [
      "_netdev"
      "x-systemd.requires=network-online.target"
      "credentials=/home/jonas/shared/.smbcredentials-storagebox"
      "uid=499"
      "gid=499"
      "file_mode=0664"
      "dir_mode=0775"
      "iocharset=utf8"
      "noserverino"
    ];
  };

  # Enable bluetooth
  hardware.bluetooth.enable = my-system.enableBluetooth or false;
  hardware.amdgpu.opencl.enable = my-system.enableOpenclAmd or false;
  hardware.keyboard.qmk = {
    enable = true;
    keychronSupport = true;
  };

  services.udev = {
    enable = true;
    extraRules = lib.mkIf (my-system ? "extraUdevRules") (my-system.extraUdevRules pkgs);
    packages = [pkgs.via];
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  main-user.enable = true;
  main-user.userName = "jonas";

  programs.fish.enable = true;

  users.groups = {
    backlight = {};
    libvirtd = lib.mkIf (my-system.enableVirtualization or false) {};
    storage = lib.mkIf (my-system.enableUserMounts or false) {};
    dufs = lib.mkIf (my-system.enableDufs or false) {
      gid = 499;
    };
  };

  users.users.dufs = lib.mkIf (my-system.enableDufs or false) {
    isSystemUser = true;
    uid = 499;
    group = "dufs";
    home = "/mnt/storagebox";
    shell = "${pkgs.shadow}/bin/nologin";
  };

  users.users.jonas = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA/wAnb/iv8cQU+VCpilkNZrBx2zZ/arT2zdtnymsLrX jonas@noether"
    ];
    extraGroups =
      [
        "audio"
        "wheel"
        "networkmanager"
        "backlight"
        "input"
      ]
      ++ (lib.optionals (my-system.enableDufs or false) ["dufs"])
      ++ (lib.optionals (my-system.enableOpenclAmd or false) ["video" "render"])
      ++ (lib.optionals (my-system.enableVirtualization or false) ["libvirtd"])
      ++ (lib.optionals (my-system.enableDocker or false) ["docker"])
      ++ (lib.optionals (my-system.enableUserMounts or false) ["storage"]);
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

  fonts.packages = lib.mkIf (my-system.enableGui or false) (with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove
  ]);

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    (lib.optionals (my-system ? "extraPkgs") (my-system.extraPkgs pkgs))
    ++ (with pkgs;
      [
        parted
        at
        cron
        # Mounting tools
        cifs-utils
        sshfs
        ntfs3g
        exfat
      ]
      ++ lib.optionals (my-system.enableGui or false) [
        waypipe
      ]
      ++ lib.optionals my-system.enableVirtualization or false [
        swtpm
        tpm-tools
      ]
      ++ lib.optionals my-system.enableUserMounts or false [
        udisks
      ]
      ++ lib.optionals my-system.enableGui or false [
        inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
        hyprpaper
        wtype
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
    enable = my-system.enableGui or false;
    xdgOpenUsePortal = true;
    config = {
      common.default = ["gtk"];
      hyprland.default = [
        "gtk"
        "hyprland"
      ];
    };
    extraPortals = [
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

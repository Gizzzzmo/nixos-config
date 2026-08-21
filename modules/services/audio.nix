{
  lib,
  config,
  pkgs,
  ...
}: {
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;

    # Global low-latency defaults for pro audio
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [44100 48000 88200 96000 176400 192000];
        "default.clock.quantum" = 256;
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

  environment.systemPackages = with pkgs; [
    pamixer
    pipewire.jack
    (pkgs.writeScriptBin "set-audio-rate" (builtins.readFile ../../scripts/set-audio-rate.sh))
  ];
}
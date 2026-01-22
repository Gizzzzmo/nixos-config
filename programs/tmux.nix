{
  standalone,
  pkgs,
  ...
}: {
  enable = true;
  package = pkgs.tmux;
  prefix = "C-b";
  keyMode = "vi";
  clock24 = true;
  baseIndex = 1;
  plugins = with pkgs.tmuxPlugins; [
    fingers
  ];
  extraConfig =
    # Basic config extracted to basic-tmux.conf for portability
    builtins.readFile ./basic-tmux.conf
    + ''
      # NixOS-specific additions
      run-shell ${
        (fetchGit {
          url = "https://github.com/artemave/tmux_super_fingers";
          rev = "413fb361a4f04fde818ca32491667a596c56b925";
        })
        .outPath
      }/tmux_super_fingers.tmux

      set -g update-environment 'DISPLAY ALACRITTY_WINDOW_ID ALACRITTY_LOG ALACRITTY_SOCKET DISPLAY WINDOWID SSH_ASKPASS SSH_CONNECTION XAUTHORITY KITTY_WINDOW_ID KITTY_PID'
      set -g default-shell /home/jonas/.nix-profile/bin/fish
    ''
    + (
      if standalone
      then ''
        set -g default-terminal "tmux-256color"
        set -as terminal-overrides ",*256col*:Tc"

        set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
        set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
      ''
      else ''
        set -g default-terminal "alacritty"
        set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
        set -as terminal-overrides ',alacritty:RGB'
      ''
    );
}

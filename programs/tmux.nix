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
    ''
      run-shell ${
        (fetchGit {
          url = "https://github.com/artemave/tmux_super_fingers";
          rev = "413fb361a4f04fde818ca32491667a596c56b925";
        })
        .outPath
      }/tmux_super_fingers.tmux

      set -s escape-time 0
      set -g mouse on
      set -g status-style bg=colour8,fg=colour15
      set -g mode-style fg=colour236,bg=colour15
      set-window-option -g window-status-current-style bg=colour15,fg=colour0

      set -g update-environment 'DISPLAY ALACRITTY_WINDOW_ID ALACRITTY_LOG ALACRITTY_SOCKET DISPLAY WINDOWID SSH_ASKPASS SSH_CONNECTION XAUTHORITY KITTY_WINDOW_ID KITTY_PID'

      set -g default-shell /home/jonas/.nix-profile/bin/fish
      set -g status-left-length 30
      set -gq allow-passthrough on
      set -g visual-activity off

      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      bind -r % split-window -h
      bind -r '"' split-window -v

      bind -n M-w last-window
      bind -n M-= select-window -n
      bind -n M-- select-window -p
      bind -n M-0 select-window -t 0
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      bind-key -Tcopy-mode-vi 'v' send -X begin-selection
      bind-key -Tcopy-mode-vi 'y' send -X copy-selection
      # disable "release mouse drag to copy and exit copy-mode", ref: https://github.com/tmux/tmux/issues/140
      unbind-key -T copy-mode-vi MouseDragEnd1Pane

      # since MouseDragEnd1Pane neither exit copy-mode nor clear selection now,
      # let single click do selection clearing for us.
      bind-key -T copy-mode-vi MouseDown1Pane select-pane\; send-keys -X clear-selection
      # this line changes the default binding of MouseDrag1Pane, the only difference
      # is that we use `copy-mode -eM` instead of `copy-mode -M`, so that WheelDownPane
      # can trigger copy-mode to exit when copy-mode is entered by MouseDrag1Pane
      bind -n MouseDrag1Pane if -Ft= '#{mouse_any_flag}' 'if -Ft= \"#{pane_in_mode}\" \"copy-mode -eM\" \"send-keys -M\"' 'copy-mode -eM'

      bind -n 'M-[' copy-mode

      bind -r r source ~/.config/tmux/tmux.conf

      vim_pattern='(\S+/)?g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?'
      is_vim="ps -o state= -o comm= -t '#{pane_tty}'  | grep -iqE '^[^TXZ ]+ +''${vim_pattern}$'"
      bind-key -n 'M-h' if-shell "$is_vim" 'send-keys M-h'  'select-pane -L'
      bind-key -n 'M-j' if-shell "$is_vim" 'send-keys M-j'  'select-pane -D'
      bind-key -n 'M-k' if-shell "$is_vim" 'send-keys M-k'  'select-pane -U'
      bind-key -n 'M-l' if-shell "$is_vim" 'send-keys M-l'  'select-pane -R'
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind-key -T copy-mode-vi 'M-h' select-pane -L
      bind-key -T copy-mode-vi 'M-j' select-pane -D
      bind-key -T copy-mode-vi 'M-k' select-pane -U
      bind-key -T copy-mode-vi 'M-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l
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

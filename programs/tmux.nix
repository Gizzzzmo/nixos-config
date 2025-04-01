{standalone, pkgs, ...}:
{
  enable = true;
  package = pkgs.tmux;
  prefix = "C-o";
  keyMode = "vi";
  clock24 = true;
  baseIndex = 1;
  plugins = with pkgs.tmuxPlugins; [
    fingers
  ];
  extraConfig = ''
    run-shell ${ (fetchGit {
        url = "https://github.com/artemave/tmux_super_fingers";
        rev = "413fb361a4f04fde818ca32491667a596c56b925";
    }).outPath }/tmux_super_fingers.tmux

    set -s escape-time 0
    set -g mouse on
    set -g status-style bg=colour24,fg=colour15
    set -g mode-style fg=colour236,bg=colour15
    set-window-option -g window-status-current-style bg=colour15,fg=colour0
    
    set -g default-shell /home/jonas/.nix-profile/bin/fish

    # set -g @tokyo-night-tmux_theme storm
    set -g status-left-length 25

    bind -r h select-pane -L
    bind -r j select-pane -D
    bind -r k select-pane -U
    bind -r l select-pane -R

    bind -r | split-window -h
    bind -r - split-window -v
    
    bind -n M-Left select-pane -L
    bind -n M-Down select-pane -D
    bind -n M-Up select-pane -U
    bind -n M-Right select-pane -R
    
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

    bind -n 'M-[' copy-mode

    bind -r r source ~/.config/tmux/tmux.conf
  '' + (if standalone then ''
    set -g default-terminal "tmux-256color"
    set -as terminal-overrides ",*256col*:Tc"

    set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
    set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
  '' else
  ''
    set -g default-terminal "alacritty"
    set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
    set -as terminal-overrides ',alacritty:RGB'
  '');
}

{pkgs}:
{
  enable = true;
  package = pkgs.tmux;
  prefix = "C-o";
  keyMode = "vi";
  clock24 = true;
  baseIndex = 1;
  extraConfig = ''
    set -g status-style bg=colour23,fg=colour15
    set -g mode-style fg=colour15,bg=colour23
    set-window-option -g window-status-current-style bg=colour15,fg=colour23
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

    bind -r r source ~/.config/tmux/tmux.conf
  '';
}
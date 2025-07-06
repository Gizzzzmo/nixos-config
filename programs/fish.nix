{pkgs, ...}: {
  enable = true;

  package = pkgs.fish;

  shellAliases = {
    "..." = "cd ../..";
    ".." = "cd ..";
    "ll" = "eza -lg --git";
    "lla" = "eza -lga --git";
    "la" = "eza -a";
    "lt" = "eza -s modified -lg";
    "lta" = "eza -s modified -lga --git";
    "cat" = "bat";
  };

  shellAbbrs = {
    "ls" = "eza";
    "curl" = "xh";
  };

  shellInit = ''
    set fish_greeting
  '';

  shellInitLast = ''
    status --is-interactive; and begin
      fish_vi_key_bindings
      bind --mode insert ctrl-f 'accept-autosuggestion'
      bind --mode insert ctrl-p up-or-search
      bind --mode insert ctrl-n down-or-search
      set -x GPG_TTY (tty)
      set -x MANPAGER "nvim +Man!"
      if test -z $SSH_AGENT_PID
        bass eval (ssh-agent -s)
        ssh-add | true
      end
      eval (direnv hook fish)
    end
    if test -f $HOME/.config/api-keys.sh
      bass source $HOME/.config/api-keys.sh
    end
  '';

  plugins = with pkgs.fishPlugins; [
    {
      name = "bass";
      src = bass;
    }
  ];
}

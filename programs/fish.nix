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
    # Need to clone sst/opencode from github to the location and have a flake with bun,
    # and go environment, as well as an envrc in the directory above.
    "opencode" = "direnv exec /home/jonas/gitprjs/forks/opencode/opencode bun run /home/jonas/gitprjs/forks/opencode/opencode/packages/opencode/src/index.ts";
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

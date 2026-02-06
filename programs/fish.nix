{
  inputs,
  pkgs,
  ...
}: {
  enable = true;

  package = pkgs.fish;

  shellAliases = {
    "..." = "cd ../..";
    ".." = "cd ..";
    "ls" = "eza";
    "ll" = "eza -lg --git";
    "lla" = "eza -lga --git";
    "la" = "eza -a";
    "lt" = "eza -s modified -lg";
    "lta" = "eza -s modified -lga --git";
    "cat" = "bat";
  };

  shellInit = ''
    set fish_greeting
  '';

  shellInitLast = ''
    set -x NIX_PATH "nixpkgs=${inputs.nixpkgs.outPath}"
    set -x PATH $PATH:/nix/var/nix/profiles/default/bin
    set -x OLLAMA_HOST 100.64.0.3:11434
    status --is-interactive; and begin
      fish_vi_key_bindings
      bind --mode insert ctrl-f 'accept-autosuggestion'
      bind --mode insert ctrl-p up-or-search
      bind --mode insert ctrl-n down-or-search
      # set -x GPG_TTY (tty)
      set -x MANPAGER "nvim +Man!"
      if test -z "$SSH_AGENT_PID"
        # Parse ssh-agent output natively in Fish
        for line in (ssh-agent -s)
          # Extract variable assignments like "SSH_AUTH_SOCK=/tmp/...; export SSH_AUTH_SOCK;"
          if string match -q -r '^(SSH_[^=]+)=([^;]+)' -- $line
            set -l var (string replace -r '^(SSH_[^=]+)=([^;]+).*' '$1' -- $line)
            set -l val (string replace -r '^(SSH_[^=]+)=([^;]+).*' '$2' -- $line)
            # Remove quotes if present
            set val (string trim -c '\'"' -- $val)
            set -gx $var $val
          end
        end
        ssh-add | true
      end
      # eval (direnv hook fish)
    end
    if test -f $HOME/.config/api-keys.fish
      bass source $HOME/.config/api-keys.fish
    end
    status --is-login; and if test -z "$TMUX"
      envmux
    end
  '';

  plugins = with pkgs.fishPlugins; [
    {
      name = "bass";
      src = bass;
    }
  ];
}

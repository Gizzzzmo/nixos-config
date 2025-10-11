{
  inputs,
  pkgs,
  standalone,
  ...
}: {
  enable = true;

  package = pkgs.fish;

  shellAliases =
    {
      "..." = "cd ../..";
      ".." = "cd ..";
      "ls" = "eza";
      "ll" = "eza -lg --git";
      "lla" = "eza -lga --git";
      "la" = "eza -a";
      "lt" = "eza -s modified -lg";
      "lta" = "eza -s modified -lga --git";
      "cat" = "bat";
    }
    // (
      if standalone
      then {
        "opencode" = "direnv exec $HOME/gitprjs/forks/opencode/opencode bun run --conditions=development $HOME/gitprjs/forks/opencode/opencode/packages/opencode/src/index.ts";
      }
      else {}
    );

  shellInit = ''
    set fish_greeting
  '';

  shellInitLast = ''
    set -x NIX_PATH "nixpkgs=${inputs.nixpkgs.outPath}"
    set -x PATH $PATH:/nix/var/nix/profiles/default/bin
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

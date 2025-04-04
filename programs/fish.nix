{pkgs, ...}:
{
  enable = true;

  package = pkgs.fish;

  shellAliases = {
    "..." = "cd ../..";
    ".." = "cd ..";
    "ll" = "eza -l";
    "lls" = "eza";
    "lla" = "eza -la";
    "la" = "eza -a";
    "lt" = "eza -s modified -l";
    "lta" = "eza -s modified -la";
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
      if test -z $SSH_AGENT_PID
        bass eval (ssh-agent -s)
        ssh-add | true
      end
    end
  '';
  
  plugins = with pkgs.fishPlugins; [
    {
      name = "bass";
      src = bass;
    }
    {
      name = "colored-man-pages";
      src = colored-man-pages;
    }
  ];
}

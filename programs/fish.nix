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
      if test -z $GPG_TTY
        set -x GPG_TTY (tty)
      end
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

{pkgs, ...}:
{
  enable = true;
  userName = "Jonas Beyer";
  userEmail = "reyeb.sanoj@googlemail.com";
  
  extraConfig = {
    init.defaultBranch = "main";
    rerere.enabled = true;
    core.editor = "nvim";
    commit.gpgsign = true;
    core.hooksPath = "~/.config/git/hooks";
  };

  aliases = {
    cbuild = "cd build/$(git rev-parse --abbrev-ref HEAD)";
    dl = "-c diff.external=difft log -p --ext-diff";
    ds = "-c diff.external=difft show --ext-diff";
    dft = "-c diff.external=difft diff";
  };

  includes = [ 
    { 
      path = "~/.config/git/config_siemens"; 
      condition = "gitdir:~/gitprjs/siemens/";
    }
  ];
  lfs.enable = true;
}

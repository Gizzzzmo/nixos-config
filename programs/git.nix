{pkgs, ...}: {
  enable = true;
  settings = {
    user.email =  "reyeb.sanoj@googlemail.com";
    user.name = "Jonas Beyer";

    init.defaultBranch = "main";
    rerere.enabled = true;
    commit.gpgsign = true;

    core.editor = "nvim";
    core.hooksPath = "~/.config/git/hooks";
    core.excludesFile = "~/.config/git/exclude";

    alias = {
      dl = "-c diff.external=difft log -p --ext-diff";
      ds = "-c diff.external=difft show --ext-diff";
      dft = "-c diff.external=difft diff";
    };
  };


  includes = [
    {
      path = "~/.config/git/config_siemens";
      condition = "gitdir:~/gitprjs/siemens/";
    }
  ];
  lfs.enable = true;
}

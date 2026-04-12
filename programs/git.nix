{...}: {
  enable = true;
  settings = {
    user.email = "reyeb.sanoj@googlemail.com";
    user.name = "Jonas Beyer";

    init.defaultBranch = "main";
    rerere.enabled = true;
    commit.gpgsign = true;

    core.editor = "nvim";
    core.excludesFile = "~/.config/git/exclude";

    uploadpack.allowAnySHA1InWant = true;
    uploadpack.allowFilter = true;
  };

  signing.format = "openpgp";

  includes = [
    {
      path = "~/.config/git/config_siemens";
      condition = "gitdir:~/gitprjs/siemens/";
    }
  ];
  lfs.enable = true;
}

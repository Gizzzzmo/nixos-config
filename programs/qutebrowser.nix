{standalone, ...}: {
  enable = !standalone;
  settings = {
    content.blocking.method = "both";
    colors.webpage.darkmode.enabled = true;
  };
}

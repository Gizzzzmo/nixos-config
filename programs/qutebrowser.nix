{standalone, ...}: {
  enable = !standalone;
  settings = {
    content.blocking.method = "both";
  };
}

{standalone, ...}: {
  enable = !standalone;
  settings = {
    content.blocking.method = "both";
    content.javascript.clipboard = "access";
    colors.webpage.darkmode.enabled = true;
  };
  extraConfig = ''
    config.set("content.register_protocol_handler", True, "https://mail.google.com?extsrc=mailto&url=%s")
    config.load_autoconfig()
  '';
}

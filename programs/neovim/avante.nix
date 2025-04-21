{standalone, ...}: {
  enable = true;
  settings = {
    claude = {
      endpoint =
        if standalone
        then "fixme"
        else "https://api.anthropic.com";
      max_tokens = 4096;
      model = "claude-3-5-sonnet-20240620";
      temperature = 0;
    };

    hints.enabled = false;
  };
}

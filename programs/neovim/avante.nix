{standalone, ...}: {
  enable = true;
  settings = {
    providers = {
      claude = {
        endpoint =
          if standalone
          then "fixme"
          else "https://api.anthropic.com";
        model = "claude-haiku/claude-3-5-haiku-20241022";
        extra_request_body = {
          max_tokens = 4096;
          temperature = 0;
        };
      };
    };

    hints.enabled = false;
    provider =
      if standalone
      then "copilot"
      else "claude";
  };
}

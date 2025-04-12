{ ... }:
{
  enable = true;
  autoLoad = true;
  settings = {
    suggestion = {
      enabled = true;
      auto_trigger = false;
      keymap = {
        next = "<M-n>";
        prev = "<M-p>";
        accept = "<M-f>";
        accept_word = "<M-S-F>";
        dismiss = "<M-x>";
      };
    };
    panel.enabled = true;
  };

}

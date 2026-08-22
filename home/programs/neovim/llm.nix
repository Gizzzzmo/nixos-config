{standalone, ...}: {
  # enable = !standalone;
  enable = false;

  settings = {
    backend = "openai";
    url = "http://100.64.0.3:11404";
    model = "mellum-4b-base:Q8_0";

    accept_keymap = "<M-f>"; # insert: accept the ghost suggestion
    dismiss_keymap = "<M-x>"; # insert: dismiss the ghost suggestion
  };
}

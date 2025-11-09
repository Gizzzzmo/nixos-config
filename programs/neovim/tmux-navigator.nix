{...}: {
  enable = true;
  keymaps = [
    {
      mode = ["n" "i" "t"];
      action = "left";
      key = "<M-h>";
    }
    {
      mode = ["n" "i" "t"];
      action = "down";
      key = "<M-j>";
    }
    {
      mode = ["n" "i" "t"];
      action = "up";
      key = "<M-k>";
    }
    {
      mode = ["n" "i" "t"];
      action = "right";
      key = "<M-l>";
    }
    {
      mode = ["n" "i" "t"];
      action = "previous";
      key = "<C-\\>";
    }
  ];
  settings.no_mappings = 1;
}

{...}: {
  enable = true;

  settings = {
    keymaps = {
      toggle_repl = "<leader>st";
      restart_repl = "<leader>sr";
      interrupt = "<leader>ss";
      exit = "<leader>sq";
      clear = "<leader>sc";
    };

    ignore_blank_lines = true;

    config = {
      scratch_repl = true;
      repl_definition = {
        python = {
          command = ["ipython" "--no-autoindent" "--quiet" "--no-banner" "--no-confirm-exit" "--nosep"];
          block_dividers = ["# %%" "#%%"];
        };
        nix = {
          command = ["nix" "repl"];
        };
      };
      repl_open_cmd = "vertical botright 60new";
    };
  };
}

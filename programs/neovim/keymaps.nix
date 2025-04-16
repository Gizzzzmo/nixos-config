[
  {
    mode = "n";
    key = "K";
    action = "i<cr><Esc>";
  }

  {
    mode = "n";
    key = "<leader>fp";
    action = "<cmd>lua require('prox-telescope').proximity_files({})<cr>";
  }

  {
    mode = "n";
    key = "<leader>r";
    action = "<cmd>lua=vim.lsp.buf.rename()<cr>";
  }

  {
    mode = [
      "n"
      "i"
    ];
    key = "<M-K>";
    action = "<cmd>res +1<cr>";
  }

  {
    mode = [
      "n"
      "i"
    ];
    key = "<M-J>";
    action = "<cmd>res -1<cr>";
  }

  {
    mode = [
      "n"
      "i"
    ];
    key = "<M-H>";
    action = "<cmd>vertical:res -1<cr>";
  }

  {
    mode = [
      "n"
      "i"
    ];
    key = "<M-L>";
    action = "<cmd>vertical:res +1<cr>";
  }

  {
    mode = "n";
    key = "<leader>at";
    action = "<cmd>AerialToggle left<cr>";
  }

  {
    mode = "n";
    key = "<leader>zz";
    action = "<cmd>ZenMode<cr>";
  }

  {
    mode = "n";
    key = "<leader>fc";
    action = "<cmd>AdvancedGitSearch<cr>";
  }

  {
    mode = "n";
    key = "<leader>od";
    action = "<cmd>ObsidianToday<cr>";
  }

  {
    mode = "n";
    key = "<leader>on";
    action = "<cmd>ObsidianNew<cr>";
  }

  {
    mode = [
      "n"
      "i"
    ];
    key = "<C-r>";
    action = "<cmd>Explore<cr>";
  }

  {
    mode = [
      "n"
      "i"
    ];
    key = "<M-h>";
    options.silent = false;
    action = "<cmd>lua vim.lsp.buf.hover()<cr>";
  }

  {
    mode = "n";
    key = "<leader>lf";
    action = "<cmd>lua=vim.lsp.buf.code_action({filter=function(a) return a.isPreferred end, apply=true})<cr>";
  }

  {
    mode = "n";
    key = "<leader>ld";
    action = "<cmd>lua=vim.diagnostic.open_float()<cr><cr>";
  }

  {
    mode = [
      "n"
      "i"
    ];
    key = "<C-M-s>";
    options.silent = false;
    action = "<cmd>noautocmd write<cr><esc>";
  }

  {
    mode = [
      "i"
      "n"
    ];
    key = "<C-s>";
    options.silent = false;
    action = "<cmd>write<cr><esc>";
  }

  {
    mode = "n";
    key = "<leader>ff";
    options.silent = false;
    action = "<cmd>lua=require('telescope.builtin').find_files({no_ignore=true})<cr>";
  }

  {
    mode = "n";
    key = "<leader>fe";
    options.silent = false;
    action = "<cmd>Telescope emoji<cr>";
  }

  {
    mode = "n";
    key = "<leader>fg";
    options.silent = false;
    action = "<cmd>Telescope live_grep<cr>";
  }

  {
    mode = "n";
    key = "<leader>fn";
    action = "<cmd>ObsidianSearch<cr>";
  }

  {
    mode = "n";
    key = "<leader>ft";
    action = "<cmd>ObsidianTags<cr>";
  }

  {
    mode = "n";
    key = "<leader>fb";
    options.silent = false;
    action = "<cmd>Telescope buffers<cr>";
  }

  {
    mode = "n";
    key = "<leader>fh";
    options.silent = false;
    action = "<cmd>Telescope help_tags<cr>";
  }

  {
    mode = "n";
    key = "<leader>fo";
    options.silent = false;
    action = "<cmd>lua=require('telescope.builtin').oldfiles({only_cwd=1})<cr>";
  }

  {
    mode = "n";
    key = "<leader>fj";
    options.silent = false;
    action = "<cmd>lua=require('telescope.builtin').jumplist()<cr>";
  }

  {
    mode = [
      "n"
      "i"
    ];
    key = "<M-\\>";
    options.silent = false;
    action = "<cmd>lua=require('telescope.builtin').buffers({sort_mru=1, ignore_current_buffer=1})<cr>";
  }

  {
    mode = "n";
    key = "gr";
    options.silent = false;
    action = "<cmd>Telescope lsp_references<cr>";
  }
]

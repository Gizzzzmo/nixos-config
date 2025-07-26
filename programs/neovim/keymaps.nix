[
  {
    mode = "i";
    key = "<C-m>";
    action.__raw = ''
      function()
        vim.api.nvim_put({"🤣"}, "c", true, true)

        vim.fn.feedkeys('{{', 't')
      end'';
  }

  {
    mode = "i";
    key = "<C-y>";
    action.__raw = ''
      function()
        local luasnip = require("luasnip")
        vim.api.nvim_put({"🤣"}, "c", true, true)

        vim.fn.feedkeys('((', 't')
      end'';
  }

  {
    mode = "i";
    key = "<C-]>";
    action.__raw = ''
      function()
        local luasnip = require("luasnip")
        vim.api.nvim_put({"🤣"}, "c", true, true)

        vim.fn.feedkeys('[[', 't')
        luasnip.expand()
      end'';
  }

  {
    mode = ["n" "i"];
    key = "<M-U>";
    action = "<cmd>redo<cr>";
  }
  # toggle fold
  {
    mode = "n";
    key = "zt";
    action = "za";
  }
  # Ccc
  {
    mode = "n";
    key = "<leader>cc";
    action = "<cmd>CccConvert<cr>";
  }

  {
    mode = "n";
    key = "<leader>cp";
    action = "<cmd>CccPick<cr>";
  }

  # Snippets
  {
    mode = ["i" "x" "n" "s"];
    key = "<C-h>";
    action = "<cmd>lua require('luasnip').jump(-1)<cr>";
  }

  {
    mode = ["i" "x" "n" "s"];
    key = "<C-l>";
    action = "<cmd>lua require('luasnip').jump(1)<cr>";
  }

  {
    mode = ["i" "x"];
    key = "<Tab>";
    action.__raw = ''
      function()
        if require('luasnip').choice_active() then 
          require('luasnip').change_choice(1) 
        else 
          local keys = vim.api.nvim_replace_termcodes('<Tab>', true, false, true)
          vim.fn.feedkeys(keys, 'n') 
        end
      end'';
  }

  # General Movements
  {
    mode = "n";
    key = "K";
    action = "a<cr><Esc>k$";
  }

  # Telescope
  {
    mode = "n";
    key = "<leader>fa";
    action.__raw = "require('ast-grep')";
  }
  {
    mode = "n";
    key = "<leader>fp";
    action = "<cmd>lua require('prox-telescope').proximity_files({})<cr>";
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

  # LSP stuff
  {
    mode = "n";
    key = "<leader>r";
    action = "<cmd>lua=vim.lsp.buf.rename()<cr>";
  }

  {
    mode = "n";
    key = "<leader>lf";
    action = "<cmd>lua=vim.lsp.buf.code_action({filter=function(a) return a.isPreferred end, apply=true})<cr>";
  }

  {
    mode = [
      "n"
      "i"
    ];
    key = "<M-i>";
    options.silent = false;
    action = "<cmd>lua vim.lsp.buf.hover()<cr>";
  }

  # Window stuff
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

  # Aerial
  {
    mode = "n";
    key = "<leader>at";
    action = "<cmd>AerialToggle left<cr>";
  }

  # Zen mode
  {
    mode = "n";
    key = "<leader>zz";
    action = "<cmd>ZenMode<cr>";
  }

  # Obsidian
  {
    mode = "n";
    key = "<leader>or";
    action = "<cmd>ObsidianRename<cr>";
  }

  {
    mode = "n";
    key = "<leader>oy";
    action = "<cmd>Obsidian yesterday<cr>";
  }

  {
    mode = "n";
    key = "<leader>ot";
    action = "<cmd>Obsidian tomorrow<cr>";
  }

  {
    mode = "n";
    key = "<leader>od";
    action = "<cmd>Obsidian today<cr>";
  }

  {
    mode = "n";
    key = "<leader>on";
    action = "<cmd>Obsidian new<cr>";
  }

  {
    mode = "n";
    key = "<leader>ob";
    action = "<cmd>Obsidian backlinks<cr>";
  }

  {
    mode = "n";
    key = "<leader>os";
    action = "<cmd>Obsidian search<cr>";
  }

  {
    mode = "n";
    key = "<leader>of";
    action = "<cmd>Obsidian quick_switch<cr>";
  }

  {
    mode = "n";
    key = "<leader>fn";
    action = "<cmd>Obsidian quick_switch<cr>";
  }

  {
    mode = "n";
    key = "<leader>ft";
    action = "<cmd>Obsidian tags<cr>";
  }

  # Misc
  {
    mode = ["n"];
    key = "-";
    action = "<cmd>Oil<cr>";
  }

  {
    mode = [
      "n"
      "i"
    ];
    key = "<C-r>";
    action = "<cmd>Oil<cr>";
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
    mode = "n";
    key = "<leader>ld";
    action = "<cmd>lua=vim.diagnostic.open_float()<cr><cr>";
  }
]

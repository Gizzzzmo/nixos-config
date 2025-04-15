{...}: {
  enable = true;
  autoEnableSources = true;
  settings = {
    sources = [
      {name = "nvim_lsp";}
      {name = "path";}
      {name = "buffer";}
    ];

    mapping = {
      "<C-Space>" = "cmp.mapping.complete()";
      "<C-a>" = "cmp.mapping.scroll_docs(-4)";
      "<C-e>" = "cmp.mapping.close()";
      "<C-d>" = "cmp.mapping.scroll_docs(4)";
      "<C-f>" = "cmp.mapping.confirm({ select = true })";
      "<C-n>" = "cmp.mapping(cmp.mapping.select_next_item({behavior = cmp.SelectBehavior.Select}), {'i', 's'})";
      "<C-p>" = "cmp.mapping(cmp.mapping.select_prev_item({behavior = cmp.SelectBehavior.Select}), {'i', 's'})";
    };

    formatting = {
      format = ''
        function(entry, vim_item)
          local MAX_LABEL_WIDTH = 25
          local MIN_LABEL_WIDTH = 25
          local MAX_MENU_WIDTH = 15
          local MIN_MENU_WIDTH = 15
          local MAX_KIND_WIDTH = 10
          local MIN_KIND_WIDTH = 10
          local ELLIPSIS_CHAR = '…'
          local label = vim_item.abbr
          local truncated_label = vim.fn.strcharpart(label, 0, MAX_LABEL_WIDTH)
          if truncated_label ~= label then
            vim_item.abbr = truncated_label .. ELLIPSIS_CHAR
          elseif string.len(label) < MIN_LABEL_WIDTH then
            local padding = string.rep(' ', MIN_LABEL_WIDTH - string.len(label))
            vim_item.abbr = label .. padding
          end
          local menu = vim_item.menu;
          local truncated_menu = vim.fn.strcharpart(menu, 0, MAX_MENU_WIDTH)
          if truncated_menu ~= menu then
            vim_item.menu = truncated_menu .. ELLIPSIS_CHAR
          elseif string.len(menu) < MIN_MENU_WIDTH then
            local padding = string.rep(' ', MIN_MENU_WIDTH - string.len(menu))
            vim_item.menu = menu .. padding
          end
          local kind = vim_item.kind;
          local truncated_kind = vim.fn.strcharpart(kind, 0, MAX_KIND_WIDTH)
          if truncated_kind ~= kind then
            vim_item.kind = truncated_kind .. ELLIPSIS_CHAR
          elseif string.len(kind) < MIN_KIND_WIDTH then
            local padding = string.rep(' ', MIN_KIND_WIDTH - string.len(kind))
            vim_item.kind = kind .. padding
          end
          return vim_item
        end
      ''; # todo: abbreviate menu and kind
    };

    experimental = {
      ghost_text = true;
    };

    view = {
      docs.auto_open = true;
    };
  };
}

{...}: {
  enable = true;
  settings = {
    completion = {
      documentation.auto_show = true;

      
      menu = {
        direction_priority = [
          "n" 
          "s"
        ];

        border = [
          "┌"
          "─"
          "┐"
          "│"
          "┘"
          "─"
          "└"
          "│"
        ];
      };
    };

    keymap = {
      "<C-Space>" = [
        "show"
        "fallback"
      ];
      "<C-p>" = [
        "select_prev"
        "fallback"
      ];
      "<C-n>" = [
        "select_next"
        "fallback"
      ];
      "<C-f>" = [
        "select_and_accept"
        "fallback"
      ];
      "<C-d>" = [
        "scroll_documentation_down"
        "fallback"
      ];
      "<C-a>" = [
        "scroll_documentation_up"
        "fallback"
      ];
    };

    snippets.preset = "luasnip";

    sources.default = [
      "snippets"
      "lsp"
      "path"
      "buffer"
    ];
    
    sources.min_keyword_length = 2;

  };
}

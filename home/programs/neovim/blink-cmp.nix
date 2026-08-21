{...}: {
  enable = true;
  settings = {
    completion = {
      accept.auto_brackets.enabled = false;

      documentation.auto_show = true;

      menu = {
        max_height = 4;
        direction_priority = [
          "n"
          "s"
        ];
      };
    };

    keymap = {
      preset = "none";
      "<C-p>" = [
        "select_prev"
        "fallback"
      ];
      "<C-n>" = [
        "select_next"
        "fallback"
      ];
      "<C-f>" = [
        "show"
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
      "<C-e>" = [
        "hide"
        "fallback"
      ];
    };

    cmdline.keymap = {
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
      "<C-e>" = [
        "hide"
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

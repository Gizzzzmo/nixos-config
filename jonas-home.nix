{nixpkgs, config, pkgs, inputs, standalone, username, ... }:

{
  targets.genericLinux.enable = true;
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/home/${username}"; 
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
  
  imports = [ inputs.nixvim.homeManagerModules.nixvim ]; 

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [ 
    inputs.envmux.defaultPackage.${pkgs.system}
    fd
    proximity-sort
    bat
    nodejs
    ncdu
    nh
    keepassxc
    nix-output-monitor
    nvd
    openvpn
    cmus
    wl-clipboard
    wl-clipboard-x11
    python3
    fishPlugins.bass
    fishPlugins.colored-man-pages
    eza
    tree
    ripgrep
    htop
    unzip
    zip
  ] ++ (if standalone then
    [
      wslu
    ]
    else with pkgs; [
      # texpresso
      kitty
      alacritty
      pavucontrol
      vscode
      eog
      obs-studio
      obsidian
      waybar
      firefox
      vlc
      wofi
      discord
      qbittorrent
      grim
      slurp
      foliate
      zathura
      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ]);

  programs.kitty = {
    enable = !standalone;
    font = {
      name = "FiraCode";
    };
    themeFile = "ayu_mirage";
  };

  programs.gitui = {
    enable = true;
    theme = ''
      (
        selected_tab: Some("White"),
        command_fg: Some("White"),
        selection_bg: Some("DarkGray"),
        selection_fg: Some("White"),
        cmdbar_bg: Some("DarkGray"),
        cmdbar_extra_lines_bg: Some("DarkGray"),
        disabled_fg: Some("#666666"),
        diff_line_add: Some("Green"),
        diff_line_delete: Some("Red"),
        diff_file_added: Some("LightGreen"),
        diff_file_removed: Some("LightRed"),
        diff_file_moved: Some("LightMagenta"),
        diff_file_modified: Some("Yellow"),
        commit_hash: Some("Magenta"),
        commit_time: Some("LightCyan"),
        commit_author: Some("Green"),
        danger_fg: Some("Red"),
        push_gauge_bg: Some("Blue"),
        push_gauge_fg: Some("Reset"),
        tag_fg: Some("LightMagenta"),
        branch_fg: Some("LightYellow"),
      )
    '';
    keyConfig = ''
      (
        move_left: Some(( code: Char('h'), modifiers: "")),
        move_right: Some(( code: Char('l'), modifiers: "")),
        move_up: Some(( code: Char('k'), modifiers: "")),
        move_down: Some(( code: Char('j'), modifiers: "")),
        open_help: Some(( code: F(1), modifiers: "")),
        home: Some(( code: Char('g'), modifiers: "")),
        end: Some(( code: Char('G'), modifiers: "SHIFT")),
        diff_hunk_prev: Some(( code: Char('N'), modifiers: "SHIFT"))
      )
    '';
  };

  nixpkgs.config.allowUnfreePredicate = (pkg: true);
  programs.wofi = {
    enable = !standalone;
    style = ''
      /* ::root{ *
      /*     --accent: #5291e2; */
      /*     --dark:   #383C4A; */
      /*     --light:  #7C818C; */
      /*     --ld:     #404552; */
      /*     --dl:     #4B5162 */
      /*     --white:  white; */
      /* } */

      *{
        font-family: FiraCode Nerd Font;
        font-size: 1.04em;
      }

      window{
        background-color: #7C818C;
      }

      #input {
        margin: 5px;
        border-radius: 3px;
        border: none;
        border-bottom: 3px solid grey;
        background-color: #383C4A;
        color: white;
        font-size: 2em;
      }

      /* search icon */
      #input:first-child > :nth-child(1) {
        min-height: 1.25em;
        min-width: 1.25em;
        background-image: -gtk-icontheme('open-menu-symbolic');
      }

      /* clear icon */
      #input:first-child > :nth-child(4){
        min-height: 1.25em;
        min-width: 1.25em;
        background-image: -gtk-icontheme('window-close-symbolic');
      }

      #inner-box {
        background-color: #383C4A;
      }

      #outer-box {
        margin: 2px;
        padding:0px;
        background-color: #383C4A;
      }

      #text {
        padding: 5px;
        color: white;
      }

      #entry:selected {
        background-color: #5291e2;
      }

      #text:selected {
      }

      #scroll {
      }

      #img {
      }

      /* Give color to even items */
      /* #entry:nth-child(even){ */
      /*     background-color: #404552; */
      /* } */
    '';
  };
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    prefix = "C-o";
    keyMode = "vi";
    clock24 = true;
    baseIndex = 1;
    plugins = with pkgs.tmuxPlugins; [
      fingers 
    ];
    extraConfig = ''
      set -s escape-time 0
      set -g mouse on
      set -g status-style bg=colour0,fg=colour15
      set -g mode-style fg=colour15,bg=colour236
      set-window-option -g window-status-current-style bg=colour15,fg=colour0

      # set -g @tokyo-night-tmux_theme storm
      set -g status-left-length 25

      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      bind -r | split-window -h
      bind -r - split-window -v
      
      bind -n M-Left select-pane -L
      bind -n M-Down select-pane -D
      bind -n M-Up select-pane -U
      bind -n M-Right select-pane -R
      
      bind -n M-w last-window
      bind -n M-= select-window -n
      bind -n M-- select-window -p 
      bind -n M-0 select-window -t 0
      bind -n M-1 select-window -t 1 
      bind -n M-2 select-window -t 2 
      bind -n M-3 select-window -t 3 
      bind -n M-4 select-window -t 4 
      bind -n M-5 select-window -t 5 
      bind -n M-6 select-window -t 6 
      bind -n M-7 select-window -t 7 
      bind -n M-8 select-window -t 8 
      bind -n M-9 select-window -t 9

      bind -r r source ~/.config/tmux/tmux.conf
    '';
  };

  programs.git = {
    enable = true;
    userName = "Jonas Beyer";
    userEmail = "reyeb.sanoj@googlemail.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      rerere.enabled = "true";
      core.editor = "nvim";
      commit.gpgsign = true;
    };

    aliases = {
      cbuild = "cd build/$(git rev-parse --abbrev-ref HEAD)";
      dl = "-c diff.external=difft log -p --ext-diff";
      ds = "-c diff.external=difft show --ext-diff";
      dft = "-c diff.external=difft diff";
    };

    includes = [ 
      { 
        path = "~/.config/git/config_siemens"; 
        condition = "gitdir:~/gitprjs/siemens/";
      }
    ];
    lfs.enable = true;
  };

  programs.vscode = {
    enable = !standalone;
    extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
      eamodio.gitlens
      #vscodevim.vim
      jnoortheen.nix-ide
      llvm-vs-code-extensions.vscode-clangd
      ms-vscode.cmake-tools
      enkia.tokyo-night
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # binascii.hexlify(base64.b64decode('8QQmTUIxQZo3owpCNh+5IjtnoNNvd0M1FI3cJrFG5Rg=')).decode("utf-8")
      #
      # codeium tries to download its own language server binary which is incompatible with nix's non-fsh compliant filesystem, and it seems to be impossible to point the extension to another location for the language server binary
      #{
      #  name = "codeium";
      #  publisher = "Codeium";
      #  version = "1.17.4";
      #  sha256 = "bafae9048f2d7143fae122f5dd4400c2da3ee06614d131b4fb7bb79aa4c8869e";
      #}
      {
        name = "cmake-language-support-vscode";
        publisher = "josetr";
        version = "0.0.9";
        sha256 = "2cdb57619eb92e46b5969c5e2a8ccae8b074c9ac408c7b1f56c089f082d7f22a";
      }
    ];
    userSettings = {
      "[nix]"."editor.tabSize" = 2;
      "editor.stickyScroll.enabled" = false;
      "editor.fontFamily" = "FiraCode Nerd Font";
      "editor.fontSize" = 14;
      "extensions.ignoreRecommendations" = true;
      "cmake.showOptionsMovedNotification" = false;
      "cmake.showNotAllDocumentsSavedQuestion" = false;
      "cmake.pinnedCommands"= [
        "workbench.action.tasks.configureTaskRunner"
        "workbench.action.tasks.runTask"
      ];
      "update.mode"= "none";
      "workbench.colorTheme" = "Tokyo Night Pure";
      "window.menuBarVisibility" = "toggle";
    }; # keybindings are in dotfiles/.config/Code/User/keybindings.json
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
  };

  programs.command-not-found.enable = true;

  programs.alacritty = {
    enable = !standalone;
    settings = {
      general.import = [ 
        "/home/jonas/.config/alacritty/tokyo-night.toml"
        #"/home/jonas/.config/alacritty/catppuccin-mocha.toml"
      ];
      window = {
        padding = {
          x = 5;
          y = 5;
        };
        opacity = 0.9;
      };
      font = {
        normal = {
          family = "FiraCode Nerd Font";
          style = "Regular";
        };
        size = 11.3;
      };
    };

  };

  programs.nixvim = {
    enable = true;
    colorschemes.tokyonight.enable = true;
    
    extraConfigLua = '' print("Hi") '';

    extraFiles."lua/prox-telescope.lua" = {
      enable = true;
      source = ./nvim/prox-telescope.lua;
    };

    diagnostics = {
      float = {
        border = "rounded";
      };
    };

    autoCmd = [
      {
        command = ":setlocal commentstring=//\\ %s";
        event = "FileType";
        pattern = "c,cpp";
      }
      {
        command = ":lua=vim.lsp.buf.format()";
        event = "BufWritePre";
        pattern = ["*.c" "*.h" "*.cpp" "*.hpp" "*.cc" "*.hh"];
      }
      {
        command = ":setlocal tabstop=2 shiftwidth=2 expandtab";
        event = "BufEnter"; 
        pattern = "*.nix";
      }
      {
        command = ":ObsidianWorkspace blog";
        event = "BufEnter";
        pattern = "/home/jonas/gitprjs/blog/**";
      }
      {
        command = ":setlocal linebreak breakindent";
        event = "BufEnter";
        pattern = "*.md";
      }
    ];

    clipboard.providers.wl-copy = {
      enable = true;
      package = pkgs.wl-clipboard;
    };

    plugins.nvim-surround = {
      enable = true;
    };

    plugins.aerial = {
      enable = true;
      settings = {
        attach_mode = "global";
        autojump = true;
        layout = {
          min_width = [ 20 ];
          max_width = [ 20 ];
        };
        backends = [
          "lsp"
          "treesitter"
          "markdown"
          "asciidoc"
          "man"
        ];
      };
    };

    plugins.zen-mode = {
      enable = true;
      settings = {
        window = {
          backdrop = 0.7;
          width = 0.8;
        };
        plugins = {
          tmux.enabled = true;
        # alacritty = {
        #     enabled = true;
        #     font = "14.1";
        #   };
        };
        
      };
    };
    
    # plugins.texpresso = {
    #   enable = !standalone;
    # };

    plugins.indent-blankline = {
      enable = true;
      settings = {
        indent = {
          highlight = [ "IblIndent" ];
          char = "│";
        };
        scope = {
          show_start = false;
          show_end = false;
        };
      };
    };

    plugins.fugitive = {
      enable = true;
      package = pkgs.vimPlugins.fugitive;
      gitPackage = pkgs.git;
    };

    plugins.lualine = {
      enable = true;
      gitPackage = pkgs.git;
      package = pkgs.vimPlugins.lualine-nvim;
      settings = {
        options.theme = "palenight";
        sections = {
          lualine_c = [
            {
              __unkeyed-1 = "filename";
              path = 1;
            }
          ];
        };
        inactive_sections = {
          lualine_c = [
            {
              __unkeyed-1 = "filename";
              path = 1;
            }
          ];
        };
      };
    };

    plugins.obsidian = {
      enable = true;
      package = pkgs.vimPlugins.obsidian-nvim;
      settings = {
        note_id_func = ''
          function(title)
            return title
          end
        '';
        note_path_func = ''
          function(spec)
            local path = spec.dir / spec.title
            return path:with_suffix(".md")
          end
        '';
        follow_img_func = ''
          function(url)
            vim.fn.jobstart({"xdg-open", url})
          end
        '';
        follow_url_func = ''
          function(url)
            vim.fn.jobstart({"xdg-open", url})
          end
        '';
        markdown_link_func = ''
          function(opts)
            return string.format("[%s](%s)", opts.label, opts.path)
          end
        '';
        daily_notes = {
          date_format = "%Y-%m-%d";
          folder = "./daily";
        };
        mappings = {
          "<leader>ch" = {
            action = "require('obsidian').util.toggle_checkbox";
            opts = {
              buffer = true;
            };
          };
          gf = {
            action = "require('obsidian').util.gf_passthrough";
            opts = {
              buffer = true;
              expr = true;
              noremap = false;
            };
          };
        };
        ui = {
          checkboxes = {
            " " = {
              char = "󰄱";
              hl_group = "ObsidianTodo";
            };
            ">" = {
              char = "";
              hl_group = "ObsidianRightArrow";
            };
            x = {
              char = "";
              hl_group = "ObsidianDone";
            };
            "~" = {
              char = "󰰱";
              hl_group = "ObsidianTilde";
            };
          };
        };
        completion = {
          min_chars = 2;
          nvim_cmp = true;
        };
        new_notes_location = "current_dir";
        workspaces = [
          {
            name = "main";
            path = "~/notes/notes/";
          }
          # {
          #   name = "blog";
          #   path = "~/gitprjs/blog/content/";
          # }
        ];
      };
    };

    plugins.copilot-lua = {
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
    };

    plugins.copilot-chat = {
      enable = true;
    };

    plugins.lsp = {
      enable = true;
      preConfig = ''
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
          vim.lsp.handlers.hover, {
            border = "single"
          }
        )
      '';
      servers = {
        clangd = {
          enable = true;
          package = null;
          cmd = if standalone
            then [ "clangd" "--resource-dir=/home/jonas/.cmaketoolchains/downloads/clang+llvm-18.1.8-x86_64-linux-gnu-ubuntu-18.04/lib/clang/18" ]
            else [ "clangd" ];
        };
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        }; 
        cmake = {
          enable = true;
          package = pkgs.cmake-language-server;
        };
        pyright = {
          enable = true;
          package = pkgs.pyright;
        };
        typos_lsp = {
          enable = true;
        };
      };
      keymaps = {
        diagnostic = {
          "<leader>j" = "goto_next";
          "<leader>k" = "goto_prev";
        };
        lspBuf = {
          gd = "definition";
          gi = "implementation";
          gt = "type_definition";
        };
      };
    };

    plugins.diffview = {
      enable = true;
    };

    plugins.lean = {
      enable = true;
      package = pkgs.vimPlugins.lean-nvim;
      settings = {
        mappings = true;
        lsp = {
          enable = true;
        };
      };
    };

    plugins.cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
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
              local MAX_LABEL_WIDTH = 35
              local MIN_LABEL_WIDTH = 35
              local MAX_MENU_WIDTH = 10
              local MIN_MENU_WIDTH = 10
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
    };

    plugins.telescope = {
      enable = true;
      extensions = {
        fzf-native.enable = true;
      };
      enabledExtensions = [
        "advanced_git_search"
      ];
      settings.pickers.find_files.hidden = true;
      settings.defaults = {
        file_ignore_patterns = [
          "^.git/"
          ".cache/"
          ".venv/"
        ];
      };
    };

    plugins.web-devicons.enable = true;
    plugins.treesitter = {
        enable = true;
        settings = {
            highlight.enable = true;
            grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
                nix
                make
                json
                bash
                vim
                lua
                toml
                yaml
                cpp
                c
                cmake
                toml
                rust
                markdown
            ];
          incremental_selection = {
            enable = true;
            keymaps = {
              node_incremental = "L";
              node_decremental = "H";
            };
          };
        };
    };

    extraPlugins = with pkgs.vimPlugins; [
      nvim-gdb
      advanced-git-search-nvim
    ];

    highlightOverride = {
      WinSeparator = {
        fg = "#444444";
      };
      Comment = {
        fg = "#ffc244";
      };
    };
    
    opts = {
      diffopt = "vertical";
      number = true;
      relativenumber = true;
      shiftwidth = 4;
      expandtab = true;
      scrolloff = 7;
      signcolumn = "number";
      conceallevel = 1;
      pumheight = 7;
    };

    globals.mapleader = ",";

    keymaps = [
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
        mode = [ "n" "i" ];
        key = "<M-K>";
        action = "<cmd>res +1<cr>";
      }
      {
        mode = [ "n" "i" ];
        key = "<M-J>";
        action = "<cmd>res -1<cr>";
      }
      {
        mode = [ "n" "i" ];
        key = "<M-H>";
        action = "<cmd>vertical:res -1<cr>";
      }
      {
        mode = [ "n" "i" ];
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
        mode = ["n" "i"];
        key = "<C-r>";
        action = "<cmd>Explore<cr>";
      }
      {
        mode = ["n" "i"];
        key = "<M-h>";
        options.silent = false;
        action = "<cmd>lua vim.lsp.buf.hover()<cr>";
      }
      {
        mode = "n";
        key = "<leader>lf";
        action = "<cmd>lua=vim.lsp.buf.code_action({filter=function(a) return a.isPreferred end, apply=true})<cr><cr>";
      }
      {
        mode = "n";
        key = "<leader>ld";
        action = "<cmd>lua=vim.diagnostic.open_float()<cr><cr>";
      }
      {
        mode = "i";
        key = "<C-M-s>";
        options.silent = false;
        action = "<cmd>noautocmd write<cr><esc>";
      }
      {
        mode = "n";
        key = "<C-M-s>";
        options.silent = false;
        action = "<cmd>noautocmd write<cr>";
      }
      {
        mode = "i";
        key = "<C-s>";
        options.silent = false;
        action = "<cmd>write<cr><esc>";
      }
      {
        mode = "n";
        key = "<C-s>";
        options.silent = false;
        action = "<cmd>write<cr>";
      }
      {
        mode = "n";
        key = "<leader>ff";
        options.silent = false;
        action = "<cmd>lua=require('telescope.builtin').find_files({no_ignore=true})<cr>"; 
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
        mode = ["n" "i"];
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
    ];
  };

  programs.fish = {
    enable = true;
    package = pkgs.fish;
    shellAliases = {
      "..." = "cd ../..";
      ".." = "cd ..";
      "ll" = "eza -l";
      "lls" = "eza";
      "la" = "eya -la";
    };

    shellInit = ''
      set fish_greeting
    '';

    shellInitLast = ''
      status --is-interactive; and begin
        if test -z $GPG_TTY
          set -x GPG_TTY (tty)
        end
        if test -z $SSH_AGENT_PID
          bass eval (ssh-agent -s)
          ssh-add | true
        end
      end
    '';
    
    plugins = with pkgs.fishPlugins; [
        {
            name = "bass";
            src = bass;
        }
        {
            name = "colored-man-pages";
            src = colored-man-pages;
        }
    ];
  };

  programs.nushell = {
    enable = true;
  };

  programs.starship = {
    enable = true; 
    enableFishIntegration = true;
    enableNushellIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = ["--cmd cd"];
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.waybar = {
    enable = !standalone;
    systemd.enable = true;
    settings = [{
      layer = "top";
      position = "top"; # Waybar at the bottom of your screen
      height = 24; # Waybar height
      # width= 1366; // Waybar width
      # Choose the order of the modules
      modules-left = ["sway/workspaces" "sway/mode" "custom/spotify"];
      modules-center= ["sway/window"];
      modules-right= ["pulseaudio" "network" "cpu" "memory" "battery" "tray" "clock"];
      "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = false;
          format = "{icon}";
          format-icons = {
              "1:web"= "";
              "2:code" = "";
              "3:term" = "";
              "4:work" = "";
              "5:music" = "";
              "6:docs" = "";
              urgent= "";
              focused= "";
              default= "";
          };
      };
      "sway/mode" = {
          format = "<span style=\italic\>{}</span>";
      };
      tray = {
          # icon-size= 21;
          spacing = 10;
      };
      clock = {
          format-alt = "{=%Y-%m-%d}";
      };
      cpu = {
          format = "{usage}% ";
      };
      memory = {
          format= "{}% ";
      };
      battery = {
          bat = "BAT0";
          states = {
              # good = 95;
              warning = 30;
              critical = 15;
          };
          format = "{capacity}% {icon}";
          # format-good = ; // An empty format will hide the module
          # format-full = ;
          format-icons = ["" "" "" "" ""];
      };
      network = {
          # interface = wlp2s0; // (Optional) To force the use of this interface
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ifname}= {ipaddr}/{cidr} ;";
          format-disconnected = "Disconnected ⚠";
      };
      pulseaudio= {
          #scroll-step = 1;
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon}";
          format-muted = "";
          format-icons = {
              headphones = "";
              handsfree = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" ""];
          };
          on-click = "pavucontrol";
      };
      "custom/spotify" = {
          format = " {}";
          max-length = 40;
          interval = 30; # Remove this if your script is endless and write in loop
          exec = pkgs.writeShellScript "mediaplayer" ''
          player_status=$(playerctl status 2> /dev/null)
          if [ "$player_status" = "Playing" ]; then
              echo "$(playerctl metadata artist) - $(playerctl metadata title)"
          elif [ "$player_status" = "Paused" ]; then
              echo " $(playerctl metadata artist) - $(playerctl metadata title)"
          fi
          '';
          #"$HOME/.config/waybar/mediaplayer.sh 2> /dev/null"; # Script in resources folder
          exec-if = "pgrep spotify";
      };
    }];
    style = ''
* {
    border: none;
    border-radius: 0;
    font-family: "CaskaydiaCove Nerd Font";
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background: transparent;
    color: white;
}

#window {
    font-weight: bold;
    font-family: "CaskaydiaCove Nerd Font";
}
/*
#workspaces {
    padding: 0 5px;
}
*/

#workspaces button {
    padding: 0 5px;
    background: transparent;
    color: white;
    border-top: 2px solid transparent;
}

#workspaces button.focused {
    color: #c9545d;
    border-top: 2px solid #c9545d;
}

#mode {
    background: #64727D;
    border-bottom: 3px solid white;
}

#clock, #battery, #cpu, #memory, #network, #pulseaudio, #custom-spotify, #tray, #mode {
    padding: 0 3px;
    margin: 0 2px;
}

#clock {
    font-weight: bold;
}

#battery {
}

#battery icon {
    color: red;
}

#battery.charging {
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: black;
    }
}

#battery.warning:not(.charging) {
    color: white;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#cpu {
}

#memory {
}

#network {
}

#network.disconnected {
    background: #f53c3c;
}

#pulseaudio {
}

#pulseaudio.muted {
}

#custom-spotify {
    color: rgb(102, 220, 105);
}

#tray {
}
    '';
  };
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".config" = {
      source = dotfiles/.config;
      recursive = true;
    };
    ".XCompose" = {
      source = dotfiles/.XCompose;
    };

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jonas/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "wslview";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

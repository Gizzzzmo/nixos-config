{nixpkgs, config, pkgs, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jonas";
  home.homeDirectory = "/home/jonas";

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
  home.packages = [
    pkgs.vscode
    pkgs.obs-studio
    pkgs.obsidian
    pkgs.git
    pkgs.waybar
    pkgs.gitui
    pkgs.firefox
    pkgs.tree
    pkgs.vlc
    pkgs.discord
    pkgs.zoxide
    pkgs.fzf
    pkgs.ripgrep
    pkgs.starship
    pkgs.nushell
    pkgs.kpcli
    pkgs.home-manager
    pkgs.qbittorrent
    pkgs.openocd
    pkgs.gdb
    pkgs.clang
    pkgs.grim
    pkgs.slurp
    pkgs.tmux
    pkgs.foliate
    pkgs.zathura
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    (pkgs.nerdfonts.override { fonts = ["FiraCode" "CascadiaCode"]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];
  nixpkgs.config.allowUnfreePredicate = (pkg: true);
  programs.git = {
    enable = true;
    userName = "Jonas Beyer";
    userEmail = "reyeb.sanoj@googlemail.com";
    
    extraConfig = {
        init.defaultBranch = "main";
    };
    lfs.enable = true;
  };
  programs.vscode = {
    enable = true;
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
    }; # keybindings are in dotfiles/.config/Code/User/keybindings.json
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
  };

  programs.command-not-found.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "/home/jonas/.config/alacritty/tokyo-night.toml" ];
      window = {
        padding = {
          x = 5;
          y = 5;
        };
        opacity = 0.8;
      };
      font = {
        normal = {
          family = "CaskaydiaCove Nerd Font";
          style = "Regular";
        };
        size = 12.5;
      };
    };

  };

  programs.nixvim = {
    enable = true;
    extraPlugins = with pkgs.vimPlugins; [
      codeium-nvim
    ];
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      "..." = "cd ../..";
      ".." = "cd ..";
    };
    shellInit = "set fish_greeting";
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
    enable = true;
    systemd.enable = true;
    style = ''
	* {
	    font-family: CaskaydiaCove Nerd Font, Roboto, Helvetica, Arial, sans-serif;
	    font-size: 13px;
	}

	#waybar {
	    background-color: #333333;
	    color: #ffffff;
	}

	button {
	    box-shadow: inset 0 -3px transparent;
	    border: none;
	    border-radius: 0;
	    padding: 0 5px;
	}

	#workspaces button {
	    background-color: #5f676a;
	    color: #ffffff;
	}

	#workspaces button:hover {
	    background: rgba(0,0,0,0.2);
	}

	#workspaces button.focused {
	    background-color: #285577;
	}

	#workspaces button.urgent {
	    background-color: #900000;
	}

	#workspaces button.active {
	    background-color: #285577;
	}

	#clock,
	#battery,
	#cpu,
	#memory,
	#pulseaudio,
	#tray,
	#mode,
	#idle_inhibitor,
	#window,
	#workspaces {
	    margin: 0 5px;
	}


	.modules-left > widget:first-child > #workspaces {
	    margin-left: 0;
	}


	.modules-right > widget:last-child > #workspaces {
	    margin-right: 0;
	}

	@keyframes blink {
	    to {
		background-color: #ffffff;
		color: #000000;
	    }
	}

	#battery.critical:not(.charging) {
	    background-color: #f53c3c;
	    color: #ffffff;
	    animation-name: blink;
	    animation-duration: 0.5s;
	    animation-timing-function: linear;
	    animation-iteration-count: infinite;
	    animation-direction: alternate;
	}

	label:focus {
	    background-color: #000000;
	}

	#tray > .passive {
	    -gtk-icon-effect: dim;
	}

	#tray > .needs-attention {
	    -gtk-icon-effect: highlight;
	    background-color: #eb4d4b;
	}

	#idle_inhibitor {
	    font-size: 15px;
	    background-color: #333333;
	    padding: 5px;
	}

	#idle_inhibitor.activated {
	    background-color: #285577;
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
    EDITOR = "code --wait";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

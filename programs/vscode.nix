{pkgs, ...} : {
  enable = true;

  profiles.default = {
    extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
      llvm-vs-code-extensions.vscode-clangd
      christian-kohler.path-intellisense
      vscodevim.vim
      enkia.tokyo-night
    ];
    userSettings = {
      "workbench.editor.showTabs" = false;

      "[nix]"."editor.tabSize" = 2;
      "editor.stickyScroll.enabled" = false;
      "editor.fontFamily" = "FiraCode Nerd Font";
      "editor.fontSize" = 14;
      "extensions.ignoreRecommendations" = true;
      "update.mode" = "none";
      "workbench.colorTheme" = "Tokyo Night Pure";
      "explorer.autoReveal"= false;
      "http.systemCertificates"= false;
      "terminal.integrated.enableMultiLinePasteWarning"= "auto";
      "terminal.integrated.defaultProfile.linux"= "fish";
      "terminal.integrated.defaultProfile.windows"= "Git Bash";
      "liveServer.settings.donotShowInfoMsg"= true;
      "files.associations"= {
        "*.h"= "c";
        ".gdbinit"= "plaintext";
      };
      "explorer.confirmDragAndDrop"= false;
      "terminal.integrated.fontFamily"= "FiraCode";
      "terminal.integrated.fontSize"= 16;
      "security.workspace.trust.untrustedFiles"= "open";
      "github.copilot.enable"= {
        "*"= true;
        "plaintext"= false;
        "markdown"= true;
        "scminput"= false;
      };
      "remote.autoForwardPortsSource"= "hybrid";
      "[cmake]"= {
        "editor.defaultFormatter"= "cheshirekow.cmake-format";
      };
      "cmakeFormat.exePath"= "gersemi.exe";
      "[cpp]"= {
        "editor.defaultFormatter"= "xaver.clang-format";
      };
      "[c]"= {
        "editor.defaultFormatter"= "xaver.clang-format";
      };
      "clang-format.executable"= "clang-format";
      "git.openRepositoryInParentFolders"= "never";
      "editor.minimap.enabled"= false;
      # "remote.SSH.remotePlatform"= {
      #   "192.168.178.70"= "linux";
      # };
      "telemetry.telemetryLevel"= "off";
      "update.enableWindowsBackgroundUpdates"= false;
      "security.allowedUNCHosts"= [
        "wsl.localhost"
      ];
      "editor.formatOnSave"= true;
      "python.analysis.typeCheckingMode"= "standard";
      "zenMode.showTabs"= "none";
      "editor.cursorSurroundingLines"= 7;
      "editor.cursorSurroundingLinesStyle"= "all";
      "vim.smartRelativeLine"= true;
      "vim.normalModeKeyBindingsNonRecursive"= [
      {
        "before"= [
          "u"
        ];
        "after"= [];
        "commands"= [
        {
          "command"= "undo";
          "args"= [];
        }
        ];
      }

      {
        "before"= [
          "<C-r>"
        ];
        "after"= [];
        "commands"= [
        {
          "command"= "redo";
          "args"= [];
        }
        ];
      }
      ];"window.menuBarVisibility" = "toggle";
    };
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
  };
# keybindings are in ../dotfiles/.config/Code/User/keybindings.json
              }

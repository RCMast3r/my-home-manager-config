{ pkgs, ... }:
{
  home-manager = {
    enable = true;
  };
  vscode = {
    mutableExtensionsDir = false;
    enable = true;
    # will at some point include these: https://github.com/RCMast3r/vscode_extensions/blob/master/combined_ext_list.sh
    extensions = [
      pkgs.vscode-extensions.ms-python.vscode-pylance
      pkgs.vscode-extensions.marp-team.marp-vscode
      pkgs.vscode-extensions.ms-python.black-formatter
      pkgs.vscode-extensions.ms-python.python
      pkgs.vscode-extensions.ms-vscode-remote.remote-ssh
      pkgs.vscode-extensions.twxs.cmake
      pkgs.vscode-extensions.ms-vscode.cmake-tools
      pkgs.vscode-extensions.shd101wyy.markdown-preview-enhanced
      pkgs.vscode-extensions.ms-vscode.cpptools
      pkgs.vscode-extensions.jnoortheen.nix-ide
      pkgs.vscode-extensions.vscodevim.vim
      pkgs.vscode-extensions.njpwerner.autodocstring
      pkgs.vscode-extensions.mkhl.direnv
      pkgs.vscode-extensions.mhutchie.git-graph
      pkgs.vscode-extensions.ms-dotnettools.vscode-dotnet-runtime
      pkgs.vscode-extensions.ms-vscode.cmake-tools
      pkgs.vscode-extensions.llvm-vs-code-extensions.vscode-clangd
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "cpp-helper";
        publisher = "amiralizadeh9480";
        version = "0.3.4";
        sha256 = "sha256-TXvKciewjm/Mw6t60Z56C5yjujfONO/gLuijctkvCzg=";
      }
      {
        name = "platformio-ide";
        publisher = "platformio";
        version = "3.3.1";
        sha256 = "sha256-zBZFpOWJ4JEv6qu9XT1u0uspZ+N2wKrpL3joC+/t/zs=";
      }
      {
        name = "cortex-debug";
        publisher = "marus25";
        version = "1.12.1";
        sha256 = "sha256-ioK6gwtkaAcfxn11lqpwhrpILSfft/byeEqoEtJIfM0=";
      }
      {
        name = "debug-tracker-vscode";
        publisher = "mcu-debug";
        version = "0.0.15";
        sha256 = "sha256-2u4Moixrf94vDLBQzz57dToLbqzz7OenQL6G9BMCn3I=";
      }
      {
        name = "memory-view";
        publisher = "mcu-debug";
        version = "0.0.24";
        sha256 = "sha256-SOs+h0MlypaICmueQ2dkqNJYc/J0e14U+SAmGYuJYvk=";
      }
      {
        name = "rtos-views";
        publisher = "mcu-debug";
        version = "0.0.7";
        sha256 = "sha256-VvMAYU7KiFxwLopUrOjvhBmA3ZKz4Zu8mywXZXCEHdo=";
      }
      {
        name = "peripheral-viewer";
        publisher = "mcu-debug";
        version = "1.4.6";
        sha256 = "sha256-flWBK+ugrbgy5pEDmGQeUzk1s2sCMQJRgrS3Ku1Oiag=";
      }
    ];

    userSettings = {
      "files.userSettings" = "on";
      "files.autoSave" = "afterDelay";
      "cmake.configureOnOpen" = false;
      "platformio-ide.autoRebuildAutocompleteIndex" = false;
      "editor.minimap.enabled" = false;
      "cortex-debug.stlinkPath.linux" = "nix/store/j9gj5jhp50qb9hdzg1y7rlx6nilflyfa-stlink-1.7.0/bin/st-util";
      "window.zoomLevel" = 1;
      "[python]" = {
        "editor.defaultFormatter" = "ms-python.black-formatter";
      };
      "[cpp]" = {
        "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
      };
    };
    keybindings = [
      {
        key = "ctrl+shift+x";
        command = "-workbench.view.extensions";
        when = "viewContainer.workbench.view.extensions.enabled";
      }
      {
        key = "ctrl+shift+x";
        command = "workbench.action.closeActiveEditor";
      }
      {
        key = "ctrl+w";
        command = "-workbench.action.closeActiveEditor";
      }
      {
        key = "ctrl+shift+tab";
        command = "-workbench.action.quickOpenNavigatePreviousInEditorPicker";
        when = "inEditorsPicker && inQuickOpen";
      }
      {
        key = "ctrl+shift+tab";
        command = "-workbench.action.quickOpenLeastRecentlyUsedEditorInGroup";
        when = "!activeEditorGroupEmpty";
      }
      {
        key = "ctrl+shift+tab";
        command = "workbench.action.previousEditor";
      }
      {
        key = "ctrl+pageup";
        command = "-workbench.action.previousEditor";
      }
      {
        key = "ctrl+tab";
        command = "workbench.action.nextEditor";
      }
      {
        key = "ctrl+pagedown";
        command = "-workbench.action.nextEditor";
      }
    ];
  };
  direnv = {
    enable = true;
    enableBashIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
  };

  # bash.enable = true; # see note on other shells below
  neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      LazyVim
      vim-cmake
      coc-nvim # For autocompletion
      vim-lsp
    ];

    extraConfig = ''
      lua << EOF
        -- LazyVim setup
        require('lazy').setup({
          {
            'neovim/nvim-lspconfig',  -- C++ LSP
            config = function()
              require'lspconfig'.clangd.setup{}
            end
          },
          'vim-scripts/vim-cmake',  -- CMake support
        })
      EOF
    ''; 
    # lua = pkgs.lua;
  };
  # coc = {
  #   enable = true;
  #   extensions = [
  #     "coc-clangd" # C++ LSP support
  #   ];
  # };

  git = {
    enable = true;
    userEmail = "rcmast3r1@gmail.com";
    userName = "Ben Hall";
  };

}

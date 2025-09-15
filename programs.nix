{ pkgs, ... }:
let
in {
  home-manager = { enable = true; };
  vscode = {
    enable = true;

    # will at some point include these: https://github.com/RCMast3r/vscode_extensions/blob/master/combined_ext_list.sh
    profiles.default.extensions = [
      pkgs.vscode-extensions.eamodio.gitlens
      pkgs.vscode-extensions.ms-python.vscode-pylance
      pkgs.vscode-extensions.marp-team.marp-vscode
      pkgs.vscode-extensions.ms-python.black-formatter
      pkgs.vscode-extensions.ms-python.python
      pkgs.vscode-extensions.ms-vscode-remote.remote-ssh
      pkgs.vscode-extensions.twxs.cmake
      pkgs.vscode-extensions.ms-vscode.cmake-tools
      pkgs.vscode-extensions.shd101wyy.markdown-preview-enhanced
      pkgs.vscode-extensions.llvm-vs-code-extensions.vscode-clangd
      pkgs.vscode-extensions.xaver.clang-format
      pkgs.vscode-extensions.jnoortheen.nix-ide
      pkgs.vscode-extensions.vscodevim.vim
      pkgs.vscode-extensions.rust-lang.rust-analyzer
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "cpp-helper";
        publisher = "amiralizadeh9480";
        version = "0.3.4";
        sha256 = "sha256-TXvKciewjm/Mw6t60Z56C5yjujfONO/gLuijctkvCzg=";
      }
      {
        name = "cmake-language-support-vscode";
        publisher = "josetr";
        version = "0.0.9";
        sha256 = "sha256-LNtXYZ65Lka1lpxeKozK6LB0yaxAjHsfVsCJ8ILX8io=";
      }
      {
        name = "doc-doxygen";
        publisher = "dusartvict";
        version = "0.3.16";
        sha256 = "sha256-33zA0ya0MFfNnusR8Ro75weOwTLv1ksXOtiGp9hArzI=";
      }
    ];

    profiles.default.userSettings = {
      "files.userSettings" = "on";
      "files.autoSave" = "afterDelay";
      "cmake.configureOnOpen" = false;
      "editor.minimap.enabled" = false;
      "window.zoomLevel" = 1;
      "[python]" = { "editor.defaultFormatter" = "ms-python.black-formatter"; };
      "terminal.external.linuxExec" = "/bin/bash";
    };
    profiles.default.keybindings = [
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

  zsh = {
    enable = true;
    oh-my-zsh.enable = true;
    oh-my-zsh.plugins = [
      "branch"
      "colorize"
      "command-not-found"
      "common-aliases"
      "compleat"
      "copybuffer"
      "direnv"
      "dnf"
      "docker"
      "docker-compose"
      "extract"
      "gh"
      "git"
      "git-auto-fetch"
      "git-commit"
      "git-escape-magic"
      "git-extras"
      "gitfast"
      "git-flow"
      "git-flow-avh"
      "github"
      "git-hubflow"
      "gitignore"
      "git-lfs"
      "git-prompt"
      "globalias"
      "gnu-utils"
      "isodate"
      "jsontools"
      "kitty"
      "last-working-dir"
      "magic-enter"
      "nmap"
      "oc"
      "per-directory-history"
      "perms"
      "pip"
      "pipenv"
      "pj"
      "poetry"
      "poetry-env"
      "pre-commit"
      "profiles"
      "pyenv"
      "pylint"
      "python"
      "qrcode"
      "rust"
      "screen"
      "singlechar"
      "ssh"
      "ssh-agent"
      "starship"
      "sudo"
      "systemd"
      "tailscale"
      "tmux"
      "tmux-cssh"
      "tmuxinator"
      "transfer"
      "ufw"
      "universalarchive"
      "urltools"
      "vim-interaction"
      "vi-mode"
      "vscode"
      "zbell"
      "zoxide"
      "zsh-interactive-cd"
      "zsh-navigation-tools"
    ];
  };
  
  git = {
    enable = true;
    userEmail = "rcmast3r1@gmail.com";
    userName = "Ben Hall";
  };

}

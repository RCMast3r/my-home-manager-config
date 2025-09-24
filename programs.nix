{ pkgs, ... }:
let
in {
  home-manager = { enable = true; };
  zsh = {
    enable = false;
    oh-my-zsh.enable = false;
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

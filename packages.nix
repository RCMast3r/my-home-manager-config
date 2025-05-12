{ pkgs }:

let
  nixTools = with pkgs; [
    ack
    cachix
    lorri
    spotify
    nixfmt-classic
    keepassxc
    google-chrome
    discord
    obsidian
    flatbuffers
    protobuf
    slack
    marp-cli
    htop
    element-desktop
    qucs-s
    teams-for-linux
    vscode
    zoxide
    fzf
  ];
in nixTools

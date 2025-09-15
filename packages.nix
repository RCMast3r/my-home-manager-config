{ pkgs }:

let
  nixTools = with pkgs; [
    ack
    cachix
    lorri
    spotify
    nixfmt-classic
    keepassxc
    discord
    obsidian
    flatbuffers
    protobuf
    slack
    marp-cli
    htop
    qucs-s
    vscode
    zoxide
    fzf
  ];
in nixTools

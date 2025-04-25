{ pkgs }:

let
  nixTools = with pkgs; [
    cachix
    lorri
    spotify
    nixpkgs-fmt
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
  ];
in nixTools

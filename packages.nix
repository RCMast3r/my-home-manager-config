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
    freetube
    obsidian
    flatbuffers
    protobuf
    # whatsapp-for-linux
    slack
    marp-cli
    htop
    # jupyter
    # python311Packages.black
    # python311Packages.pip
  ];
in nixTools

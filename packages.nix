{ pkgs }:

let
  nixTools = with pkgs; [
    cachix
    lorri
    # spotify
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
    element-desktop
    teams-for-linux
    dotnetCorePackages.sdk_6_0_1xx # required for vscode because vscode is stupid and dumb
    streamlink-twitch-gui-bin
    clang-tools
    # jupyter
    # python311Packages.black
    # python311Packages.pip
    lua
  ];
in nixTools

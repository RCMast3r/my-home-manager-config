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
  ];
in nixTools

{ pkgs }:

let
  nixTools = with pkgs; [
    cachix
    lorri
    spotify
  ];
in nixTools

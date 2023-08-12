{ pkgs }:

let
  nixTools = with pkgs; [
    cachix
    lorri
    spotify
    nixpkgs-fmt
  ];
in nixTools

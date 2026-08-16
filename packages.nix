{ pkgs }:

let
  nixTools = with pkgs; [
    ack
    cachix
    lorri
    # spotify
    nixfmt-classic
    keepassxc
    discord
    obsidian
    flatbuffers
    slack
    marp-cli
    htop
    qucs-s
    zoxide
    fzf
    rustup
    llama-cpp
    # btop - terminal system monitor
    pkgs.btop
    # Fonts for btop (braille patterns, geometric shapes, box drawing)
    pkgs.terminus_font
    pkgs.dejavu_fonts
    # Emoji and Unicode support - nerd font with emoji
    pkgs.nerd-fonts.dejavu-sans-mono
    pkgs.terminator
    pkgs.clang-tools
    pkgs.attic-client
  ];
in nixTools

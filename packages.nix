{ pkgs }:

# The union of what both machines used to install separately - one list, every
# host. VS Code is deliberately absent: it comes from programs.vscode, wrapped
# in vscode.nix.
let
  nixTools = with pkgs; [
    ack
    attic-client
    btop
    cachix
    clang-tools
    discord
    flatbuffers
    foxglove-studio
    fzf
    htop
    keepassxc
    llama-cpp
    lorri
    marp-cli
    nixd
    nixfmt
    obsidian
    protobuf
    qucs-s
    rustup
    slack
    spotify
    terminator
    zoxide

    # Fonts for btop (braille patterns, geometric shapes, box drawing)
    terminus_font
    dejavu_fonts
    # Emoji and Unicode support - nerd font with emoji
    nerd-fonts.dejavu-sans-mono
  ];
in nixTools

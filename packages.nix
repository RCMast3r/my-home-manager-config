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
    attic-client
    qucs-s

    # Replaces the foxglove-studio snap. That snap renders through the Mesa
    # 20.0.8 bundled in its gnome-3-28-1804 (Ubuntu 18.04) platform snap, which
    # predates this laptop's Raptor Lake iGPU and so cannot create a DRI
    # screen -- "Driver does not support the 0xa720 PCI ID", then a dead GPU
    # process and a blank window. Snap confinement means the host's Mesa 25 is
    # not reachable from inside, and the 18.04 base's glibc 2.27 could not load
    # it anyway, so there is no fixing it in place. This build picks up the
    # Mesa in /run/opengl-driver instead. From a newer nixpkgs; see flake.nix.
    foxglove-studio

    vscode
    zoxide
    fzf
    nixd
  ];
in nixTools

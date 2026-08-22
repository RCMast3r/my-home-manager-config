{ homeDirectory
, pkgs
, stateVersion
, system
, username }:

let
  packages = import ./packages.nix { inherit pkgs; };
in {
  home = {
    inherit homeDirectory packages stateVersion username;
    
    
    
    # NOTE: home.shellAliases is only materialised by the programs.bash /
    # programs.zsh / programs.fish modules. Both are off here and ~/.zshrc is
    # hand-managed, so nothing below actually reaches a shell. Use ./update.sh.
    shellAliases = {
      reload-home-manager-config = "home-manager switch --flake ${builtins.toString ./.}";
    };
  };

  nixpkgs = {
    config = {
      inherit system;
      allowUnfree = true;
      allowUnsupportedSystem = true;
      experimental-features = "nix-command flakes";
    };
  };

  # Puts ~/.nix-profile/share on XDG_DATA_DIRS, via both the shell profile and
  # ~/.config/environment.d (which systemd --user, and so GNOME Shell, reads).
  # GNOME then finds desktop entries and icons directly in the profile, so
  # nothing needs mirroring into ~/.local/share. Also sets XCURSOR_PATH and
  # TERMINFO_DIRS for the same non-NixOS reason.
  # Takes effect on the next full logout/login: environment.d is read at
  # session start.
  targets.genericLinux.enable = true;

  # Building `man home-configuration.nix` runs every Home Manager option
  # through nixpkgs' nixosOptionsDoc, which on this nixpkgs pin serialises them
  # with `builtins.toFile` and warns:
  #   warning: Using 'builtins.toFile' to create a file named 'options.json'
  #   that references the store path ... without a proper context.
  # Current nixpkgs passes the JSON straight to the builder instead and no
  # longer warns, so bumping the nixpkgs input would also settle this. Until
  # then, skip the man page — it also takes a real slice off each build. The
  # same content is at https://nix-community.github.io/home-manager/options.xhtml
  manual.manpages.enable = false;

  programs = import ./programs.nix { inherit pkgs; };
}

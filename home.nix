{ homeDirectory
, pkgs
, stateVersion
, system
, username
}:

let
  nixTools = import ./packages.nix { inherit pkgs; };
in {
  home = {
    inherit homeDirectory stateVersion username;
    packages = nixTools;

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
}

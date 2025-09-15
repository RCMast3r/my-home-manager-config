{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # Values you should modify
      username = "ben"; # $USER
      system = "x86_64-linux";  # x86_64-linux, aarch64-multiplatform, etc.
      stateVersion = "25.05";     # See https://nixos.org/manual/nixpkgs/stable for most recent

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      homeDirPrefix = if pkgs.stdenv.hostPlatform.isDarwin then "/Users" else "/home";
      homeDirectory = "/${homeDirPrefix}/${username}";

      home = (import ./home.nix {
        inherit homeDirectory pkgs stateVersion system username;
      });
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        # lib = nixpkgs.lib;
        inherit pkgs;
        extraSpecialArgs = {
          inherit self;
        };
        modules = [
          home
        ];
      };
    };
}

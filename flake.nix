{
  description = "Home Manager configuration";
  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" "https://cache.nixos-cuda.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-hm.url = "github:RCMast3r/nix-hm";
    nix-hm.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nix-hm, ... }:
    let
      # Values you should modify
      username = "ben"; # $USER
      system = "x86_64-linux";  # x86_64-linux, aarch64-multiplatform, etc.
      stateVersion = "26.05";     # See https://nixos.org/manual/nixpkgs/stable for most recent

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          (final: prev: {
            llama-cpp = prev.llama-cpp.override { cudaSupport = true; };
          })
        ];
      };
  # Qwen/Qwen3.6-27B
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
          nix-hm.homeModules.vscode-settings
          ({ config, ... }: {
            # config to enable from my nix-hm config
            config.vscode-settings.enable = true;
          })
        ];
      };
    };
}

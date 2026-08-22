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

  outputs = inputs@{ self, nixpkgs, home-manager, nix-hm, ... }:
    let
      # Values you should modify
      username = "ben"; # $USER
      system = "x86_64-linux";  # x86_64-linux, aarch64-multiplatform, etc.

      homeDirPrefix =
        if nixpkgs.legacyPackages.${system}.stdenv.hostPlatform.isDarwin
        then "/Users" else "/home";
      homeDirectory = "/${homeDirPrefix}/${username}";

      # One entry per machine this repo is deployed to. Each file returns
      # { stateVersion, nvidiaGpu, nixpkgsConfig, overlays, modules } - see
      # hosts/desktop.nix. update.sh works out which machine it is running on
      # and picks the matching attribute out of homeConfigurations, so adding a
      # host means adding a file here and nothing else.
      #
      # Keep these small: anything both machines should have belongs in
      # home.nix / packages.nix / programs.nix / vscode.nix instead.
      hosts = {
        desktop = ./hosts/desktop.nix;
        laptop = ./hosts/laptop.nix;
      };

      mkHome = hostName: hostFile:
        let
          host = import hostFile { inherit inputs system username; };

          # Built per host: overlays and free-form nixpkgs config differ between
          # machines (CUDA and the NVIDIA licence on the desktop, neither on the
          # laptop). home.nix repeats them through home-manager's nixpkgs.*
          # options, which is what actually takes effect in some evaluation
          # paths - they have to agree.
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            } // (host.nixpkgsConfig or { });
            overlays = host.overlays or [ ];
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit self hostName;
          };
          modules = [
            (import ./home.nix {
              inherit homeDirectory hostName pkgs system username;
              inherit (host) stateVersion nvidiaGpu;
              nixpkgsConfig = host.nixpkgsConfig or { };
              overlays = host.overlays or [ ];
            })

            # Shared on every host: editor setup, git aliases, and the small
            # utility package set.
            nix-hm.homeModules.vscode-settings
            nix-hm.homeModules.git-aliases
            nix-hm.homeModules.default-system-utils
            ({ ... }: {
              config.vscode-settings.enable = true;
              config.git-aliases.enable = true;
              config.default-system-utils.enable = true;
            })
          ] ++ (host.modules or [ ]);
        };
    in
    {
      homeConfigurations = builtins.mapAttrs mkHome hosts;
    };
}

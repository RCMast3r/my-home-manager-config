{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-hm.url = "github:RCMast3r/nix-hm";
    nix-hm.inputs.nixpkgs.follows = "nixpkgs";

    # foxglove-studio entered nixpkgs after the pin above (2025-09-13), which
    # carries only foxglove-cli. Pinned separately, and deliberately NOT
    # following our nixpkgs, so the one package can come from a tree that has
    # it without dragging the rest of this config forward. Fold it back into
    # the main input and delete this once that pin moves past the addition.
    nixpkgs-foxglove.url =
      "github:nixos/nixpkgs/391b592eb44808b3bd0cb80bb71b63a5a118b8bb";

    # Hardware graphics acceleration for Nix-built apps on a non-NixOS distro.
    # NOTE: system-manager deliberately does NOT follow our nixpkgs. It pulls in
    # NixOS modules (userborn) that track its own pin; forcing nixos-unstable
    # here fails with "option `system.activationScripts.hashes' does not exist".
    system-manager.url = "github:numtide/system-manager";
    nix-system-graphics.url = "github:soupglasses/nix-system-graphics";
    nix-system-graphics.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, nixpkgs-foxglove, home-manager, nix-hm, system-manager
    , nix-system-graphics, ... }:
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
        # Graft foxglove-studio in from the newer pin above. Taken as a whole
        # package rather than re-called against our nixpkgs, so it builds
        # against the dependency closure it was actually tested with.
        overlays = [
          (_: _: {
            inherit (import nixpkgs-foxglove {
              inherit system;
              config.allowUnfree = true;  # the desktop app is proprietary
            }) foxglove-studio;
          })
        ];
      };

      homeDirPrefix = if pkgs.stdenv.hostPlatform.isDarwin then "/Users" else "/home";
      homeDirectory = "/${homeDirPrefix}/${username}";

      # system-manager ships wrappers that put nixpkgs' nix first on PATH for
      # every `nix build` / `nix eval` / `nix-env` it shells out to. This
      # machine runs Determinate Nix, whose /etc/nix/nix.conf sets `lazy-trees`
      # — a setting upstream nix does not know, so it prints
      #   warning: unknown setting 'lazy-trees'
      # on every one of those invocations. Hand system-manager the same nix the
      # rest of the machine uses instead. The path is the Determinate installer's
      # default profile, resolved at runtime, so this is deliberately impure.
      # Falls back to nixpkgs' nix when the host profile is not reachable, so
      # this still works inside the build sandbox (system-manager's test suite
      # shells out to nix).
      hostNix = pkgs.symlinkJoin {
        name = "host-nix";
        paths = map
          (bin: pkgs.writeShellScriptBin bin ''
            host=/nix/var/nix/profiles/default/bin/${bin}
            [ -x "$host" ] || host=${pkgs.nix}/bin/${bin}
            exec "$host" "$@"
          '')
          [ "nix" "nix-build" "nix-env" "nix-instantiate" "nix-store" ];
      };

      home = (import ./home.nix {
        inherit homeDirectory pkgs stateVersion system username;
      });
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit self;
        };
        modules = [
          home
          nix-hm.homeModules.vscode-settings
          nix-hm.homeModules.default-system-utils
          (
            { config, ... }: {
              config.vscode-settings.enable = true;
              config.default-system-utils.enable = true;
            }
          )
        ];
      };

      # The system-manager CLI, pinned to our flake.lock. update.sh runs this
      # rather than `nix run github:numtide/system-manager`, which re-resolves
      # the flake and re-downloads its whole closure on every invocation.
      packages.${system}.system-manager =
        system-manager.packages.${system}.default.override { nix = hostNix; };

      # Populates /run/opengl-driver with Mesa so Nix-built GUI apps can reach
      # the GPU. Without it, Electron apps (VS Code) find no DRI driver on
      # Fedora and silently fall back to the SwiftShader CPU rasterizer.
      # Activate separately from home-manager (needs root):
      #   nix run 'github:numtide/system-manager' -- switch --flake '.#default' --sudo
      #
      # Keyed by system rather than the bare `systemConfigs.default` from
      # system-manager's README: given `--flake '.#default'` it evaluates
      # systemConfigs.<system>.default first, so this layout resolves in one
      # eval instead of falling through the misses.
      systemConfigs.${system}.default = system-manager.lib.makeSystemConfig {
        modules = [
          nix-system-graphics.systemModules.default
          (
            { pkgs, ... }: {
              config = {
                nixpkgs.hostPlatform = system;
                # The activation half of system-manager runs the engine from
                # inside this profile, which carries its own nix wrapper, so it
                # needs the same substitution as the CLI above. There is no
                # narrower hook than the overlay, and `nix` is also a check
                # input of the system-manager crate, so this costs a ~4 minute
                # build from source whenever the system-manager or nixpkgs
                # inputs move. Drop this line to get that time back at the price
                # of one `unknown setting 'lazy-trees'` line during activation.
                nixpkgs.overlays = [ (_: _: { nix = hostNix; }) ];
                # Fedora is not one of system-manager's supported distros.
                system-manager.allowAnyDistro = true;
                system-graphics.enable = true;
                # nix-system-graphics still defaults this to `mesa.drivers`,
                # which nixpkgs has folded back into `mesa` and now warns about
                # on every evaluation. Same derivation, no warning.
                system-graphics.package = pkgs.mesa;
                # VA-API video decode for this laptop's Raptor Lake iGPU.
                system-graphics.extraPackages = [ pkgs.intel-media-driver ];

                # All we want from system-manager is the /run/opengl-driver
                # symlink above (an /etc/tmpfiles.d rule). Everything below
                # switches off the rest, which actively breaks a Fedora+GNOME
                # desktop.

                # This file is written with the value
                #   XDG_DATA_DIRS=/etc/profiles/per-user/${USER}/share:...:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}
                # and systemd does NOT expand those placeholders here, so the
                # literal text lands in the session environment and /usr/share
                # drops off XDG_DATA_DIRS. gnome-session then finds zero
                # GSettings schemas, aborts, and GDM misreports the dead
                # session worker as "Authentication error" for both password
                # and fingerprint. Confirmed from the gnome-session coredump.
                environment.etc."environment.d/10-system-manager.conf".enable =
                  false;

                # Same content via /etc/profile.d. It does expand correctly in
                # a shell, but it only serves to put /run/system-manager/sw/bin
                # (bash, sh, nologin from nixpkgs-unstable) ahead of /usr/bin,
                # which we don't want either. Packages come from home-manager.
                environment.etc."profile.d/system-manager-path.sh".enable =
                  false;

                # userborn applies NixOS user semantics to Fedora's account
                # files: it rewrote /etc/passwd and /etc/group, repointed root's
                # shell at a Nix store path, then failed outright on Fedora's
                # pre-existing GID 42/10/65534. We declare no users, so keep it
                # off entirely.
                services.userborn.enable = false;

                # suid-sgid-wrappers.service is declared `After=userborn.service`
                # unconditionally. That dependency alone makes systemd keep a
                # not-found stub for userborn.service in its unit table, and
                # system-manager restarts any userborn.service it can see during
                # activation — which then fails with "Unit userborn.service not
                # found". We declare no security.wrappers, so the service only
                # ever created an empty /run/wrappers anyway.
                security.enableWrappers = false;
              };
            }
          )
        ];
      };
    };
}

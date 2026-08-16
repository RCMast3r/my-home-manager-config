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
      homeDirPrefix = if pkgs.stdenv.hostPlatform.isDarwin then "/Users" else "/home";
      homeDirectory = "/${homeDirPrefix}/${username}";

      # VS Code only learns about home-manager's profiles by reading
      # .userDataProfiles out of globalStorage/storage.json at startup, and it
      # DELETES any User/profiles/<name> directory that file does not mention.
      # home-manager writes that key from an activation script, which loses a
      # race it cannot win: a running VS Code holds storage.json in RAM and
      # flushes its own copy over it on exit, so a switch performed with the
      # editor open is silently undone - the profile never appears in the
      # picker and its symlinks get garbage-collected on the next start.
      #
      # Registering at launch instead removes the race. This runs before the
      # editor process exists, so whatever profile directories home-manager
      # linked are always registered by the time VS Code reads the file. It
      # discovers them from the filesystem rather than taking a hardcoded list,
      # so adding a profile in nix-hm needs no change here.
      registerVscodeProfiles = pkgs.writeShellScript "register-vscode-profiles" ''
        set -u
        PATH=${pkgs.lib.makeBinPath [ pkgs.jq pkgs.coreutils ]}''${PATH:+:}$PATH

        user_dir="$HOME/.config/Code/User"
        storage="$user_dir/globalStorage/storage.json"
        [ -d "$user_dir/profiles" ] || exit 0

        mkdir -p "$(dirname "$storage")"
        [ -s "$storage" ] || echo '{}' > "$storage"

        for dir in "$user_dir/profiles"/*/; do
          [ -d "$dir" ] || continue
          name="$(basename "$dir")"

          if jq -e --arg n "$name" \
               '(.userDataProfiles // []) | any(.name == $n)' \
               "$storage" > /dev/null 2>&1; then
            continue
          fi

          tmp="$(mktemp "$storage.XXXXXX")" || continue
          if jq --arg n "$name" \
               '.userDataProfiles = ((.userDataProfiles // []) + [{ name: $n, location: $n }])' \
               "$storage" > "$tmp" 2>/dev/null; then
            mv -f "$tmp" "$storage"
          else
            rm -f "$tmp"
          fi
        done
      '';

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
          nix-hm.homeModules.git-aliases
          ({ config, ... }: {
            # config to enable from my nix-hm config
            config.vscode-settings.enable = true;
            config.git-aliases.enable = true;

            # nix-built vscode bundles its own ANGLE EGL/GLES libs, which
            # have no RPATH or LD_LIBRARY_PATH entry pointing at
            # /run/opengl-driver - so even with targets.genericLinux.gpu
            # populating that path (see home.nix), vscode's dlopen of the
            # system EGL falls through to software rendering unless we point
            # it there ourselves.
            #
            # LD_LIBRARY_PATH alone is NOT enough, though. Electron 1.119
            # auto-selects the Wayland ozone backend here (no explicit flag -
            # `xlsclients` shows no vscode window on :0), so it drives EGL on
            # the Wayland platform. libEGL_nvidia cannot serve the Wayland or
            # X11 EGL platforms by itself; each needs an "external platform"
            # module, and home-manager's gpu-libs-env ships neither the libs
            # (libnvidia-egl-{wayland,xcb,xlib}.so) nor the
            # share/egl/egl_external_platform.d configs that name them.
            # Without them eglInitialize fails on the NVIDIA vendor, libglvnd
            # falls through to the next vendor (mesa), and mesa has no driver
            # for this card - so we land on llvmpipe and burn CPU compositing
            # the editor. Fedora has these libs in /usr/lib64 but they are
            # unusable from a nix binary, hence the nix builds of the same
            # upstream projects below. Their JSONs carry absolute store paths,
            # so __EGL_EXTERNAL_PLATFORM_CONFIG_DIRS is what actually wires
            # them up; the lib entries just keep their transitive deps
            # resolvable. Verified with eglinfo: Wayland and X11 platforms
            # both report the NVIDIA renderer instead of llvmpipe.
            #
            # GLX and Vulkan were always fine on this setup - only the EGL
            # path was broken - which is why nvidia-smi showed no vscode
            # process while a renderer sat at 300%+ CPU.
            config.programs.vscode.package = pkgs.symlinkJoin {
              name = "vscode-hw-accel";
              paths = [ pkgs.vscode ];
              nativeBuildInputs = [ pkgs.makeWrapper ];
              postBuild = ''
                wrapProgram $out/bin/code \
                  --run ${registerVscodeProfiles} \
                  --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib:${pkgs.egl-wayland}/lib:${pkgs.egl-x11}/lib \
                  --set __EGL_EXTERNAL_PLATFORM_CONFIG_DIRS ${pkgs.egl-wayland}/share/egl/egl_external_platform.d:${pkgs.egl-x11}/share/egl/egl_external_platform.d
              '';
              meta.mainProgram = "code";
            };
          })
        ];
      };
    };
}

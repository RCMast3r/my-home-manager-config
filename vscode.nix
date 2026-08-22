{ pkgs
, # The host's NVIDIA driver pin, or null on machines without one. Only the
  # EGL external-platform wiring below depends on it; everything else is
  # identical on every machine.
  nvidiaGpu ? null
}:

# Shared VS Code setup. Extensions, settings, keybindings and profiles come
# from nix-hm's vscode-settings module (which also sets programs.vscode.enable);
# what this file owns is the package those run in.

let
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

  # nix-built vscode bundles its own ANGLE EGL/GLES libs, which have no RPATH
  # or LD_LIBRARY_PATH entry pointing at /run/opengl-driver - so even with
  # targets.genericLinux.gpu populating that path (see home.nix), vscode's
  # dlopen of the system EGL falls through to software rendering unless we
  # point it there ourselves. Mesa hosts need nothing beyond this.
  gpuLibPath = [ "/run/opengl-driver/lib" ];

  # On NVIDIA, LD_LIBRARY_PATH alone is NOT enough. Electron 1.119 auto-selects
  # the Wayland ozone backend here (no explicit flag - `xlsclients` shows no
  # vscode window on :0), so it drives EGL on the Wayland platform.
  # libEGL_nvidia cannot serve the Wayland or X11 EGL platforms by itself; each
  # needs an "external platform" module, and home-manager's gpu-libs-env ships
  # neither the libs (libnvidia-egl-{wayland,xcb,xlib}.so) nor the
  # share/egl/egl_external_platform.d configs that name them. Without them
  # eglInitialize fails on the NVIDIA vendor, libglvnd falls through to the next
  # vendor (mesa), and mesa has no driver for that card - so we land on llvmpipe
  # and burn CPU compositing the editor. Fedora has these libs in /usr/lib64 but
  # they are unusable from a nix binary, hence the nix builds of the same
  # upstream projects below. Their JSONs carry absolute store paths, so
  # __EGL_EXTERNAL_PLATFORM_CONFIG_DIRS is what actually wires them up; the lib
  # entries just keep their transitive deps resolvable. Verified with eglinfo:
  # Wayland and X11 platforms both report the NVIDIA renderer instead of
  # llvmpipe.
  #
  # GLX and Vulkan were always fine on that setup - only the EGL path was broken
  # - which is why nvidia-smi showed no vscode process while a renderer sat at
  # 300%+ CPU.
  eglExternalPlatforms = [ pkgs.egl-wayland pkgs.egl-x11 ];
  useNvidia = nvidiaGpu != null;

  libPath = pkgs.lib.concatStringsSep ":"
    (gpuLibPath ++ pkgs.lib.optionals useNvidia (map (p: "${p}/lib") eglExternalPlatforms));

  platformConfigDirs = pkgs.lib.concatStringsSep ":"
    (map (p: "${p}/share/egl/egl_external_platform.d") eglExternalPlatforms);
in
{
  programs.vscode.package = pkgs.symlinkJoin {
    name = "vscode-hw-accel";
    paths = [ pkgs.vscode ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/code \
        --run ${registerVscodeProfiles} \
        --prefix LD_LIBRARY_PATH : ${libPath} \
        ${pkgs.lib.optionalString useNvidia
          "--set __EGL_EXTERNAL_PLATFORM_CONFIG_DIRS ${platformConfigDirs}"}
    '';
    meta.mainProgram = "code";
  };
}

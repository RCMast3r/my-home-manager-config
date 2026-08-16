{ homeDirectory
, pkgs
, stateVersion
, system
, username
}:

let
  nixTools = import ./packages.nix { inherit pkgs; };
  nvidiaPin = import ./nvidia-driver-pin.nix;
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
      nvidia.acceptLicense = true;
    };
  };

  # Fedora ships its own OpenGL/Vulkan drivers, but Nix-built GUI apps (all
  # our home-manager packages) can't see them - only /run/opengl-driver,
  # which Fedora doesn't populate. targets.genericLinux.gpu builds NVIDIA's
  # userspace libs for the exact driver version update.sh pinned in
  # nvidia-driver-pin.nix (mismatched kernel/userspace versions segfault
  # instead of rendering) and symlinks them into /run/opengl-driver via a
  # one-time `sudo <setup script>` that home-manager prints whenever the
  # pinned version changes - no persistent root-level service framework
  # needed. We previously used system-manager + nix-system-graphics for
  # this, but abandoned it: it fought Fedora's SELinux policy over
  # /nix/store unit files (see git history) and force-enabled a
  # declarative user-management service with reports of corrupting
  # /etc/shadow permissions (numtide/system-manager#350).
  targets.genericLinux.gpu = {
    enable = true;
    nvidia = {
      enable = true;
      inherit (nvidiaPin) version sha256;
    };
  };
}

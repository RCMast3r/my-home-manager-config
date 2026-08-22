{ homeDirectory
, hostName
, nixpkgsConfig ? { }
, nvidiaGpu ? null
, overlays ? [ ]
, pkgs
, stateVersion
, system
, username
}:

let
  nixTools = import ./packages.nix { inherit pkgs; };
  vscode = import ./vscode.nix { inherit nvidiaGpu pkgs; };
  inherit (pkgs) lib;
in {
  home = {
    inherit homeDirectory stateVersion username;
    packages = nixTools;

    # NOTE: home.shellAliases is only materialised by the programs.bash /
    # programs.zsh / programs.fish modules. Both are off here and ~/.bashrc is
    # hand-managed, so nothing below actually reaches a shell. Use ./update.sh.
    shellAliases = {
      reload-home-manager-config =
        "home-manager switch --flake ${builtins.toString ./.}#${hostName}";
    };
  };

  # Mirrors what flake.nix already baked into pkgs. home-manager re-imports
  # nixpkgs from these options in some evaluation paths, so leaving them out
  # here silently drops the host's overlays and config (an unfree/licence
  # refusal, or a package built without CUDA) depending on which pkgs wins.
  nixpkgs = {
    config = {
      inherit system;
      allowUnfree = true;
      allowUnsupportedSystem = true;
      experimental-features = "nix-command flakes";
    } // nixpkgsConfig;
    inherit overlays;
  };

  # Puts ~/.nix-profile/share on XDG_DATA_DIRS, via both the shell profile and
  # ~/.config/environment.d (which systemd --user, and so GNOME Shell, reads).
  # GNOME then finds desktop entries and icons directly in the profile, so
  # nothing needs mirroring into ~/.local/share. Also sets XCURSOR_PATH and
  # TERMINFO_DIRS for the same non-NixOS reason.
  # Takes effect on the next full logout/login: environment.d is read at
  # session start. update.sh keeps mirroring launchers by hand until it sees
  # that has happened.
  targets.genericLinux.enable = true;

  # Fedora ships its own OpenGL/Vulkan drivers, but Nix-built GUI apps (all
  # our home-manager packages) can't see them - only /run/opengl-driver,
  # which Fedora doesn't populate. targets.genericLinux.gpu builds the
  # userspace driver libs and symlinks them into /run/opengl-driver via a
  # one-time `sudo <setup script>`, which update.sh runs whenever the store
  # path changes - no persistent root-level service framework needed. It is
  # enabled implicitly by targets.genericLinux.enable above; the mesa +
  # libvdpau-va-gl + intel-media-driver set it builds by default is all a
  # machine on integrated graphics needs.
  #
  # Hosts with a discrete NVIDIA card pass their driver pin instead, and get
  # the proprietary userspace on top. The version must match the kernel module
  # the host has loaded - mismatched kernel/userspace versions segfault instead
  # of rendering - so update.sh re-pins nvidia-driver-pin.nix from
  # /proc/driver/nvidia/version before every build.
  #
  # The laptop previously used system-manager + nix-system-graphics for this.
  # That was abandoned on both machines: it fought Fedora's SELinux policy
  # over /nix/store unit files, needed userborn/wrappers/environment.d all
  # explicitly disabled to keep from breaking a Fedora+GNOME session, and
  # force-enabled a declarative user-management service with reports of
  # corrupting /etc/shadow permissions (numtide/system-manager#350).
  targets.genericLinux.gpu = lib.mkIf (nvidiaGpu != null) {
    nvidia = {
      enable = true;
      inherit (nvidiaGpu) version sha256;
    };
  };

  # Building `man home-configuration.nix` runs every Home Manager option
  # through nixpkgs' nixosOptionsDoc, which takes a real slice off each build
  # for a page also published at
  # https://nix-community.github.io/home-manager/options.xhtml
  manual.manpages.enable = false;

  programs = (import ./programs.nix { inherit pkgs; }) // vscode.programs;
}

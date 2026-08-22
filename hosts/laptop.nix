# Fedora laptop, Raptor Lake integrated graphics, no discrete GPU.
{ inputs, system, username }:

{
  # Deliberately older than the desktop's. home-manager's stateVersion tracks
  # the release this machine's dotfiles were first laid out under, not the
  # nixpkgs it builds against, so it stays where it is even though this host
  # now shares the desktop's 26.05 pin.
  stateVersion = "25.05";

  # No discrete card: targets.genericLinux.gpu falls back to its default driver
  # set (mesa + libvdpau-va-gl + intel-media-driver), which is exactly what the
  # system-manager configuration this replaced used to request.
  nvidiaGpu = null;

  # No overlays. foxglove-studio used to come from a separate pinned nixpkgs
  # because the tree this host tracked (2025-09-13) predated the package; the
  # shared nixos-26.05 pin carries it directly.
  modules = [ ];
}
